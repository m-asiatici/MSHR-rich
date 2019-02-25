package fpgamshr.reqhandler.cuckoo

import chisel3._
import chisel3.util._
import fpgamshr.interfaces._
import fpgamshr.util._
import fpgamshr.profiling._
import chisel3.core.dontTouch

import java.io._ // To generate the BRAM initialization files

object MSHR {
    val addrWidth = 30 /* Excluding the part that is always 0, i.e. the log2Ceil(reqDataWidth) least significant bits, and the req handler address (log2Ceil(numReqHandlers)) */
    val idWidth = 8
    val memDataWidth = 512
    val memDataBurstLength = 4
    val ldBufRowAddrWidth = 8
    val reqDataWidth = 32
    val MSHRAlmostFullMargin = 8

    val numHashTables = 2
    val numMSHRPerHashTable = 64
    val assocMemorySize = 4

    val bramLatency = 2
    val pipelineLatency = 4
    val maxMultConstWidth = 17 // If larger, the hash function will not be entirely mapped to a DSP48, failing timing

    val numControlRegisters = 2
    /* axiControl */
    val axiControlDataWidth = 32
    val axiControlAddrWidth = log2Ceil(MSHR.numControlRegisters)
    /* Register map of axiControl */
    val offendingTagAddr = 0
    val offendingBranchAddr = 1

    val offsetWidth = log2Ceil(memDataWidth / reqDataWidth)
    val tagWidth = addrWidth - offsetWidth
}

class CuckooMSHR(addrWidth: Int=MSHR.addrWidth, numMSHRPerHashTable: Int=MSHR.numMSHRPerHashTable, numHashTables: Int=MSHR.numHashTables, idWidth: Int=MSHR.idWidth, memDataWidth: Int=MSHR.memDataWidth, /*memDataBurstLength: Int=MSHR.memDataBurstLength, */reqDataWidth: Int=MSHR.reqDataWidth, ldBufRowAddrWidth: Int=MSHR.ldBufRowAddrWidth, MSHRAlmostFullMargin: Int=MSHR.MSHRAlmostFullMargin, assocMemorySize: Int=MSHR.assocMemorySize, sameHashFunction: Boolean=false) extends Module {
  require(isPow2(memDataWidth / reqDataWidth))
  require(isPow2(numMSHRPerHashTable))
  //require(isPow2(memDataBurstLength))
  val offsetWidth = log2Ceil(memDataWidth / reqDataWidth)
  //val burstOffsetWidth = log2Ceil(memDataBurstLength)
  //val tagWidth = addrWidth - burstOffsetWidth - offsetWidth
  val tagWidth = addrWidth - offsetWidth
  val numMSHRTotal = numMSHRPerHashTable * numHashTables
  //val extMemQueueAddrWidth = log2Ceil(numMSHRTotal)
  //val memType = new MSHREntryValid(tagWidth, ldBufRowAddrWidth, extMemQueueAddrWidth, burstOffsetWidth)
  val memType = new MSHREntryValid(tagWidth, ldBufRowAddrWidth)
  val memWidth = memType.getWidth
  //val entryType = new MSHREntry(tagWidth, ldBufRowAddrWidth, extMemQueueAddrWidth, burstOffsetWidth)
  val entryType = new MSHREntry(tagWidth, ldBufRowAddrWidth)
  val hashTableAddrWidth = log2Ceil(numMSHRPerHashTable)
  val hashMultConstWidth = if (tagWidth > MSHR.maxMultConstWidth) MSHR.maxMultConstWidth else tagWidth
  /*
   * a = positive odd integer on addr.getWidth bits
  https://en.wikipedia.org/wiki/Universal_hashing#Avoiding_modular_arithmetic */
  // def hash(aExponent: Int, b: Int, tag: UInt): UInt = ((tag << aExponent) + tag + b.U)(tagWidth - 1, tagWidth - hashTableAddrWidth)=
  // println(s"tagWidth=$tagWidth, hashTableAddrWidth=$hashTableAddrWidth")
  //def hash(a: Int, b: Int, tag: UInt): UInt = (a.U(hashMultConstWidth.W) * tag + b.U((tagWidth-hashTableAddrWidth).W))(tagWidth - 1, tagWidth - hashTableAddrWidth)
  /* The way the hash was computed, b was useless anyway, so we can remove it altogether. */
  def hash(a: Int, tag: UInt): UInt = (a.U(hashMultConstWidth.W) * tag)(tagWidth - 1, tagWidth - hashTableAddrWidth)
  //def hash2(a1: Int, a2: Int, tag: UInt): UInt = (tag + (tag << a1.U) + (tag << a2.U))(tagWidth - 1, tagWidth - hashTableAddrWidth)
  def getTag(addr: UInt): UInt = addr(addrWidth - 1, addrWidth - tagWidth)
  def getOffset(addr: UInt): UInt = addr(offsetWidth - 1, 0)

  // def connectWithEnable[T <: Data](d1: DecoupledIO[T], d2: DecoupledIO[T], enable: Bool) = {
  //   d1.valid := d2.valid & enable
  //   d1.bits  := d2.bits
  //   d2.ready := d1.ready & enable
  // }

  val io = IO(new Bundle{
    val allocIn = DecoupledIO(new AddrIdIO(addrWidth, idWidth)).flip
    val deallocIn = DecoupledIO(new AddrDataIO(addrWidth, memDataWidth)).flip
    /* FRQ = free (load buffer) row queue */
    val frqIn = DecoupledIO(UInt(ldBufRowAddrWidth.W)).flip
    /* Output to the load buffer unit */
    val outLdBuf = DecoupledIO(new MSHRToLdBufIO(offsetWidth, idWidth, dataWidth=memDataWidth, rowAddrWidth=ldBufRowAddrWidth))
    /* Raised by the load buffer unit when the FRQ is empty and allocations
     * need to be stalled. */
    val stopAllocFromLdBuf = Input(Bool())
    /* Interface to memory arbiter, with burst requests to be sent to DDR */
    val outMem = DecoupledIO(UInt(tagWidth.W))
    val axiProfiling = new AXI4LiteReadOnlyProfiling(Profiling.dataWidth, Profiling.regAddrWidth)
    /* MSHR will stop accepting allocations when we reach this number of MSHRs. By making this Value
     * configurable at runtime, we can quickly explore the impact of reducing the number of MSHRs without
     * recompiling the design. */
    val maxAllowedMSHRs = Input(UInt(log2Ceil(numMSHRTotal + 1).W))
  })

  val pipelineReady = Wire(Bool())

  /* Input logic */
  val inputArbiter = Module(new Arbiter(new AddrDataIdIO(addrWidth, memDataWidth, idWidth), 2))
  val stopAllocs = Wire(Bool())
  val stopDeallocs = Wire(Bool())
  val stallOnlyAllocs = Wire(Bool())

  // connectWithEnable(inputArbiter.io.in(0), io.deallocIn, ~stopDeallocs)
  // inputArbiter.io.in(0).connectWithEnable(io.deallocIn, ~stopDeallocs)

  inputArbiter.io.in(0).valid      := io.deallocIn.valid & ~stopDeallocs
  inputArbiter.io.in(0).bits.addr  := io.deallocIn.bits.addr
  inputArbiter.io.in(0).bits.data  := io.deallocIn.bits.data
  io.deallocIn.ready := inputArbiter.io.in(0).ready & ~stopDeallocs

  inputArbiter.io.in(1).valid      := io.allocIn.valid & ~stopAllocs
  inputArbiter.io.in(1).bits.addr  := io.allocIn.bits.addr
  inputArbiter.io.in(1).bits.id    := io.allocIn.bits.id
  io.allocIn.ready   := inputArbiter.io.in(1).ready & ~stopAllocs

  /* Arbiter between input and stash. Input has higher priority: we try to put back
   * entries in the tables "in the background". */
  val stashArbiter = Module(new Arbiter(new AddrDataIdAllocLdBufPtrLastTableIO(addrWidth, memDataWidth, idWidth, ldBufRowAddrWidth, log2Ceil(numHashTables)), 2))
  /* Queue containing entries that have been kicked out from the hash tables, and that we will try
   * to put back in one of their other possible locations. */
  val stash = Module(new MSHRStash(tagWidth, ldBufRowAddrWidth, assocMemorySize, log2Ceil(numHashTables)))
  stashArbiter.io.in(0).valid := inputArbiter.io.out.valid
  stashArbiter.io.in(0).bits := DontCare
  stashArbiter.io.in(0).bits.addr := inputArbiter.io.out.bits.addr
  stashArbiter.io.in(0).bits.data := inputArbiter.io.out.bits.data
  stashArbiter.io.in(0).bits.id := inputArbiter.io.out.bits.id
  stashArbiter.io.in(0).bits.isAlloc := inputArbiter.io.chosen === 1.U
  // stashArbiter.io.in(0).bits.ldBufPtr := DontCare
  // stashArbiter.io.in(0).bits.lastTableIdx := DontCare
  //stashArbiter.io.in(0).bits.
  inputArbiter.io.out.ready := stashArbiter.io.in(0).ready
  stashArbiter.io.in(1).valid := stash.io.deq.valid
  stashArbiter.io.in(1).bits := DontCare
  stashArbiter.io.in(1).bits.addr := Cat(stash.io.deq.bits.tag, 0.U(offsetWidth.W))
  stashArbiter.io.in(1).bits.isAlloc := true.B
  stashArbiter.io.in(1).bits.ldBufPtr := stash.io.deq.bits.ldBufPtr
  stashArbiter.io.in(1).bits.lastTableIdx := stash.io.deq.bits.lastTableIdx
  stash.io.deq.ready := stashArbiter.io.in(1).ready
  stashArbiter.io.out.ready := pipelineReady

  /* Pipeline */
  /* stashArbiter.io.out -> register -> hash computation -> memory read address and register -> register -> data coming back from memory */
  val delayedRequest = Wire(Vec(MSHR.pipelineLatency, ValidIO(stashArbiter.io.out.bits.cloneType)))
  /* One entry per pipeline stage; whether the entry in that pipeline stage is from stash or not
   * Entries from the stash behave like allocations but they do not generate a new read to memory
   * nor a new allocation to the load buffer if they do not hit. */
  val delayedIsFromStash = Wire(Vec(MSHR.pipelineLatency, Bool()))
  /* One bool per pipeline stage, true if the entry in that pipeline stage comes from the stash
   * and delayedRequest is a corresponding deallocation for it. */
  val deallocPipelineEntries = delayedRequest.zip(delayedIsFromStash).dropRight(1).map(x => (getTag(x._1.bits.addr) === getTag(delayedRequest.last.bits.addr)) & delayedRequest.last.valid & ~delayedRequest.last.bits.isAlloc & x._2)
  val isDelayedAlloc = delayedRequest.last.bits.isAlloc & delayedRequest.last.valid
  val isDelayedDealloc = ~delayedRequest.last.bits.isAlloc & delayedRequest.last.valid
  val isDelayedFromStash = delayedIsFromStash.last
  delayedRequest(0).bits := RegEnable(stashArbiter.io.out.bits, enable=pipelineReady)
  delayedRequest(0).valid := RegEnable(stashArbiter.io.out.valid, enable=pipelineReady, init=false.B)
  delayedIsFromStash(0) := RegEnable(stashArbiter.io.chosen === 1.U, enable=pipelineReady)
  for(i <- 1 until MSHR.pipelineLatency) {
    delayedRequest(i).bits := RegEnable(delayedRequest(i-1).bits, enable=pipelineReady)
    /* Implement in-flight deallocation of entries from the stash if delayedRequest is the corresponding deallocation. */
    delayedRequest(i).valid := RegEnable(delayedRequest(i-1).valid & ~deallocPipelineEntries(i-1), enable=pipelineReady, init=false.B)
    delayedIsFromStash(i) := RegEnable(delayedIsFromStash(i-1), enable=pipelineReady)
  }

  /* Address hashing */
  val r = new scala.util.Random(42)
  val a = (0 until numHashTables).map(_ => r.nextInt(1 << hashMultConstWidth))
  //val b = (0 until numHashTables).map(_ => r.nextInt(1 << (tagWidth - hashTableAddrWidth)))
  val hashedTags = (0 until numHashTables).map(i => if(sameHashFunction) hash(a(0), getTag(delayedRequest(0).bits.addr)) else hash(a(i), getTag(delayedRequest(0).bits.addr)))
  //a.indices.foreach(i => println(s"a($i)=${a(i)}"))
  /* Uncomment to print out hashing parameters a and b */
  // a.indices.foreach(i => println(s"a($i)=${a(i)} b($i)=${b(i)}"))

  /* Memories instantiation and interconnection */
  /* Memories are initialized with all zeros, which is fine for us since all the valids will be false */
  val memories = Array.fill(numHashTables)(Module(new XilinxSimpleDualPortNoChangeBRAM(width=memWidth, depth=numMSHRPerHashTable)).io)
  val storeToLoads = Array.fill(numHashTables)(Module(new StoreToLoadForwardingTwoStages(memType, hashTableAddrWidth)).io)
  for (i <- 0 until numHashTables) {
    memories(i).clock := clock
    memories(i).reset := reset
    memories(i).addrb := RegEnable(hashedTags(i), enable=pipelineReady)
    storeToLoads(i).rdAddr := RegEnable(hashedTags(i), enable=pipelineReady)

    memories(i).enb := pipelineReady
    memories(i).regceb := pipelineReady
    storeToLoads(i).pipelineReady := pipelineReady
    storeToLoads(i).dataInFromMem := memType.fromBits(memories(i).doutb)
  }
  val dataRead = storeToLoads.map(x => x.dataInFixed)
  /* Matching and stash deallocation logic */
  val hashTableMatches = dataRead.map(x => x.valid & x.tag === getTag(delayedRequest.last.bits.addr))
  val pipelineMatches = delayedRequest.zip(delayedIsFromStash).dropRight(1).map(x => (getTag(x._1.bits.addr) === getTag(delayedRequest.last.bits.addr)) & x._1.valid & x._2)
  stash.io.lookupTag.bits := getTag(delayedRequest.last.bits.addr)
  stash.io.lookupTag.valid := delayedRequest.last.valid
  stash.io.deallocMatchingEntry := delayedRequest.last.valid & ~delayedRequest.last.bits.isAlloc
  stash.io.pipelineReady := pipelineReady
  val allMatches = hashTableMatches ++ pipelineMatches ++ Array(stash.io.matchingLdBufPtr.valid)
  val selectedLdBufPtr = Mux1H(allMatches, dataRead.map(x => x.ldBufPtr) ++ delayedRequest.dropRight(1).map(x => x.bits.ldBufPtr) ++ Array(stash.io.matchingLdBufPtr.bits))
  val hit = Vec(allMatches).asUInt.orR
  val allFull = Vec(dataRead.map(x => x.valid)).asUInt.andR /* all = all hash tables */

  /* Update logic */
  val updatedData = Wire(memType)
  updatedData.valid := isDelayedAlloc
  updatedData.tag := getTag(delayedRequest.last.bits.addr)
  updatedData.ldBufPtr := Mux(isDelayedFromStash, delayedRequest.last.bits.ldBufPtr, io.frqIn.bits)
  /* When a tag appears for the first time, we allocate an entry in one of the hash tables (HT).
   * To better spread the entries among HTs, we want all HTs to have the same priority; however, we can only choose
   * a hash table for which the entry corresponding to the new tag is free. We use a RRArbiter to implement this functionality, where we
   * do not care about the value to arbitrate and we use ~entry.valid as valid signal for the arbiter. */
  val fakeRRArbiterForSelect = Module(new ResettableRRArbiter(Bool(), numHashTables))
  for(i <- 0 until numHashTables) fakeRRArbiterForSelect.io.in(i).valid := ~dataRead(i).valid
  val hashTableToUpdate = UIntToOH(fakeRRArbiterForSelect.io.chosen).toBools

  /* Eviction logic */
  /* If the entry has been kicked out from HT i, we will try put it in HT i+1 mod HT_count.
   * We use a round-robin policy also for the first eviction: the index of the last hash
   * table from which we evicted is stored in evictTableForFirstAttempt.
   * This round-robin policy is simpler and works better than using an LFSR16. */
  val evictCounterEnable = Wire(Bool())
  val evictTableForFirstAttempt = Counter(evictCounterEnable, numHashTables)
  /* To support non-power-of-two number of tables, we need to implement the wrapping logic manually. */
  val evictTableForEntryFromStash = Mux(delayedRequest.last.bits.lastTableIdx === (numHashTables - 1).U, 0.U, delayedRequest.last.bits.lastTableIdx + 1.U)
  val evictTable = Mux(isDelayedFromStash, evictTableForEntryFromStash, evictTableForFirstAttempt._1)
  val evictOH = UIntToOH(evictTable)
  stash.io.enq.bits.tag := Mux1H(evictOH, dataRead.map(x => x.tag))
  stash.io.enq.bits.ldBufPtr := Mux1H(evictOH, dataRead.map(x => x.ldBufPtr))
  stash.io.enq.bits.lastTableIdx := evictTable
  stash.io.enq.valid := isDelayedAlloc & !hit & allFull & pipelineReady
  evictCounterEnable := stash.io.enq.valid

  /* Memory write port */
  for (i <- 0 until numHashTables) {
    memories(i).addra := storeToLoads(i).wrAddr
    memories(i).wea := Mux(isDelayedFromStash, delayedRequest.last.valid & Mux(allFull, evictOH(i), hashTableToUpdate(i)), (isDelayedAlloc & !hit & Mux(allFull, evictOH(i), hashTableToUpdate(i))) | (isDelayedDealloc & hashTableMatches(i)))
    storeToLoads(i).wrEn := memories(i).wea
    memories(i).dina := updatedData.asUInt
    storeToLoads(i).dataOutToMem := updatedData
  }
  io.frqIn.ready := isDelayedAlloc & !hit & pipelineReady & ~isDelayedFromStash
  fakeRRArbiterForSelect.io.out.ready := io.frqIn.ready

  // val allocatedMSHRCounter = Module(new SimultaneousUpDownSaturatingCounter(numMSHRTotal, 0))
  // allocatedMSHRCounter.io.load := false.B
  // allocatedMSHRCounter.io.loadValue := DontCare
  // allocatedMSHRCounter.io.increment := io.frqIn.ready
  // allocatedMSHRCounter.io.decrement := isDelayedDealloc & pipelineReady
  val allocatedMSHRCounter = SimultaneousUpDownSaturatingCounter(numMSHRTotal,
    increment=io.frqIn.ready,
    decrement=isDelayedDealloc & pipelineReady)
  /* The number of allocations + kicked out entries in flight must be limited to the number of slots in the stash since, in the worst case,
   * all of them will give rise to a kick out and must be stored in the stash if the pipeline gets filled with deallocations. */
  // val allocsInFlight = Module(new SimultaneousUpDownSaturatingCounter(2* assocMemorySize, 0))
  /* One allocation ceases to be in flight if:
  - it can be put in the hash table without kicking out another entry (hit | ~allFull)
  - an entry from the stash can be put in an hash table without more kickouts
  - an allocation or a kicked out entry in flight is deallocated */
  val allocsInFlight = SimultaneousUpDownSaturatingCounter(assocMemorySize+1,
    increment=inputArbiter.io.in(1).valid & inputArbiter.io.in(1).ready & pipelineReady,
    decrement=(isDelayedAlloc & pipelineReady & (hit | ~allFull)) | (isDelayedDealloc & pipelineReady & (Vec(pipelineMatches).asUInt.orR | stash.io.matchingLdBufPtr.valid))
  )
  // allocsInFlight.io.load := false.B
  // allocsInFlight.io.loadValue := DontCare
  // allocsInFlight.io.increment := inputArbiter.io.in(1).valid & inputArbiter.io.in(1).ready & pipelineReady
  // allocsInFlight.io.decrement := (isDelayedAlloc & pipelineReady & (hit | ~allFull)) | (isDelayedDealloc & pipelineReady & (Vec(pipelineMatches).asUInt.orR | stash.io.matchingLdBufPtr.valid))
  stallOnlyAllocs := allocsInFlight >= assocMemorySize.U
  // val MSHRAlmostFull = allocatedMSHRCounter.io.currValue >= (io.maxAllowedMSHRs - MSHRAlmostFullMargin.U)
  val MSHRAlmostFull = allocatedMSHRCounter >= (io.maxAllowedMSHRs - MSHRAlmostFullMargin.U)

  stopAllocs := MSHRAlmostFull | io.stopAllocFromLdBuf | stallOnlyAllocs
  stopDeallocs := false.B

  /* outLdBuf */
  io.outLdBuf.bits.rowAddr := Mux(hit, selectedLdBufPtr, io.frqIn.bits)
  io.outLdBuf.bits.entry.offset := getOffset(delayedRequest.last.bits.addr)
  io.outLdBuf.bits.entry.id := delayedRequest.last.bits.id
  io.outLdBuf.bits.data := delayedRequest.last.bits.data
  io.outLdBuf.bits.opType.allocateRow := isDelayedAlloc & !hit & ~isDelayedFromStash
  io.outLdBuf.bits.opType.allocateEntry := isDelayedAlloc
  io.outLdBuf.valid := delayedRequest.last.valid & ~isDelayedFromStash

  /* Queue and interface to external memory arbiter */
  val externalMemoryQueue = Module(new BRAMQueue(tagWidth, numMSHRTotal))
  externalMemoryQueue.io.deq <> io.outMem
  externalMemoryQueue.io.enq.valid := io.frqIn.ready
  externalMemoryQueue.io.enq.bits := getTag(delayedRequest.last.bits.addr)

  pipelineReady := io.outLdBuf.ready | ~io.outLdBuf.valid | isDelayedFromStash

  /* Profiling interface */
  if(Profiling.enable) {
    /* The order by which registers are appended to profilingRegisters defines the register map */
    val profilingRegisters = scala.collection.mutable.ListBuffer[UInt]()
    val currentlyUsedMSHR = RegEnable(allocatedMSHRCounter, enable=io.axiProfiling.snapshot)
    profilingRegisters += currentlyUsedMSHR
    val maxUsedMSHR = ProfilingMax(allocatedMSHRCounter, io.axiProfiling)
    profilingRegisters += maxUsedMSHR
    val collisionCount = ProfilingCounter(isDelayedAlloc & !hit & allFull & pipelineReady & ~isDelayedFromStash, io.axiProfiling)
    profilingRegisters += collisionCount
    val cyclesSpentResolvingCollisions = ProfilingCounter(isDelayedFromStash & delayedRequest.last.valid & pipelineReady, io.axiProfiling)
    profilingRegisters += cyclesSpentResolvingCollisions
    val stallTriggerCount = ProfilingCounter(stallOnlyAllocs & ~RegNext(stallOnlyAllocs), io.axiProfiling)
    profilingRegisters += stallTriggerCount
    val cyclesSpentStalling = ProfilingCounter(stallOnlyAllocs & io.allocIn.valid, io.axiProfiling)
    profilingRegisters += cyclesSpentStalling
    val acceptedAllocsCount = ProfilingCounter(io.outLdBuf.bits.opType.allocateEntry & io.outLdBuf.valid & io.outLdBuf.ready, io.axiProfiling)
    profilingRegisters += acceptedAllocsCount
    val acceptedDeallocsCount = ProfilingCounter(~io.outLdBuf.bits.opType.allocateEntry & io.outLdBuf.valid & io.outLdBuf.ready, io.axiProfiling)
    profilingRegisters += acceptedDeallocsCount
    val cyclesAllocsStalled = ProfilingCounter(io.allocIn.valid & ~io.allocIn.ready, io.axiProfiling)
    profilingRegisters += cyclesAllocsStalled
    val cyclesDeallocsStalled = ProfilingCounter(io.deallocIn.valid & ~io.deallocIn.ready, io.axiProfiling)
    profilingRegisters += cyclesDeallocsStalled
    val enqueuedMemReqsCount = ProfilingCounter(externalMemoryQueue.io.enq.valid, io.axiProfiling)
    profilingRegisters += enqueuedMemReqsCount
    // val dequeuedMemReqsCount = ProfilingCounter(externalMemoryQueue.io.deq.valid, io.axiProfiling)
    // profilingRegisters += dequeuedMemReqsCount
    val cyclesOutLdBufNotReady = ProfilingCounter(io.outLdBuf.valid & ~io.outLdBuf.ready, io.axiProfiling)
    profilingRegisters += cyclesOutLdBufNotReady
    // This is a very ugly hack to prevent sign extension when converting currValue to signed int, since asSInt does not accept a width as a parameter
    val accumUsedMSHR = ProfilingArbitraryIncrementCounter(Array((true.B -> (allocatedMSHRCounter + 0.U((allocatedMSHRCounter.getWidth+1).W)).asSInt)), io.axiProfiling)
    profilingRegisters += accumUsedMSHR._1
    val cyclesStallAllocFromLdBuf = ProfilingCounter(io.allocIn.valid & io.stopAllocFromLdBuf, io.axiProfiling)
    profilingRegisters += cyclesStallAllocFromLdBuf
    // readLine.validCount, writeLine.validCount, wrEn
    if(Profiling.enableHistograms) {
      val currentlyUsedMSHRHistogram = (0 until log2Ceil(numMSHRTotal)).map(i => ProfilingCounter(allocatedMSHRCounter >= (1 << i).U, io.axiProfiling))
      profilingRegisters ++= currentlyUsedMSHRHistogram
    }
    require(Profiling.regAddrWidth >= log2Ceil(profilingRegisters.length))
    val profilingInterface = ProfilingInterface(io.axiProfiling.axi, Vec(profilingRegisters))
    io.axiProfiling.axi.RDATA := profilingInterface.bits
    io.axiProfiling.axi.RVALID := profilingInterface.valid
    profilingInterface.ready := io.axiProfiling.axi.RREADY
    io.axiProfiling.axi.RRESP := 0.U
  } else {
    io.axiProfiling.axi.ARREADY := false.B
    io.axiProfiling.axi.RVALID := false.B
    io.axiProfiling.axi.RDATA := DontCare
    io.axiProfiling.axi.RRESP := DontCare
  }

}

class MSHRStash(tagWidth: Int, ldBufRowAddrWidth: Int, numEntries: Int, lastTableIdxWidth: Int) extends Module {
  val entryWithValidType = new MSHREntryValidLastTable(tagWidth, ldBufRowAddrWidth, lastTableIdxWidth)
  val entryType = new MSHREntryLastTable(tagWidth, ldBufRowAddrWidth, lastTableIdxWidth)
  val io = IO(new Bundle{
    val enq = DecoupledIO(entryType).flip
    val deq = DecoupledIO(entryType)
    val pipelineReady = Input(Bool())
    val lookupTag = ValidIO(UInt(tagWidth.W)).flip
    val matchingLdBufPtr = ValidIO(UInt(ldBufRowAddrWidth.W))
    val deallocMatchingEntry = Input(Bool())
  })

  // val invalidMemoryEntry = Wire(entryWithValidType)
  // invalidMemoryEntry.valid := false.B
  // invalidMemoryEntry.tag := DontCare
  // invalidMemoryEntry.ldBufPtr := DontCare
  // invalidMemoryEntry.lastTableIdx := DontCare
  val invalidMemoryEntry = entryWithValidType.getInvalidEntry()
  val memory = RegInit(Vec(Seq.fill(numEntries)(invalidMemoryEntry)))
  val emptyEntrySelect = PriorityEncoderOH(memory.map(x => ~x.valid))
  val full = Vec(memory.map(x => x.valid)).asUInt.andR
  val almostFull = PopCount(memory.map(x => x.valid)) >= 1.U // number of pipeline stages - 1 ?
  io.enq.ready := ~almostFull & ~full
  val outputArbiter = Module(new ResettableRRArbiter(entryType, numEntries))
  //val matchWithIncomingValue = (io.enq.bits.tag === io.lookupTag.bits) & io.lookupTag.valid & io.enq.valid
  val matches = memory.map(x => (x.tag === io.lookupTag.bits) & io.lookupTag.valid & x.valid)/* ++ Array(matchWithIncomingValue)*/
  for(i <- 0 until numEntries) {
    // insertion
    when(io.enq.valid & io.pipelineReady & /*~(matchWithIncomingValue & io.deallocMatchingEntry) &*/ Mux(io.deq.ready & io.deq.valid, outputArbiter.io.in(i).ready & outputArbiter.io.in(i).valid, emptyEntrySelect(i))) {
      //memory(i).valid := true.B
      memory(i).setValid()
      memory(i).tag := io.enq.bits.tag
      memory(i).ldBufPtr := io.enq.bits.ldBufPtr
      memory(i).lastTableIdx := io.enq.bits.lastTableIdx
    } .elsewhen(io.pipelineReady & (outputArbiter.io.in(i).ready | (matches(i) & io.deallocMatchingEntry))) { // value consumed or deallocated
      //memory(i).valid := false.B
      memory(i).invalidate()
    }
    outputArbiter.io.in(i).valid := memory(i).valid & ~(matches(i) & io.deallocMatchingEntry)
    outputArbiter.io.in(i).bits.tag := memory(i).tag
    outputArbiter.io.in(i).bits.ldBufPtr := memory(i).ldBufPtr
    outputArbiter.io.in(i).bits.lastTableIdx := memory(i).lastTableIdx
  }
  outputArbiter.io.out <> io.deq
  io.matchingLdBufPtr.bits := Mux1H(matches, memory.map(x => x.ldBufPtr) ++ Array(io.enq.bits.ldBufPtr))
  io.matchingLdBufPtr.valid := Vec(matches).asUInt.orR
  val DEBUG_dataLost = io.enq.valid & full & ~io.deq.ready
  dontTouch(DEBUG_dataLost)
}

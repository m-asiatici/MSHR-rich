package fpgamshr.util

import chisel3._
import chisel3.util._
import fpgamshr.interfaces._
import fpgamshr.profiling._

import java.io._ // To generate the BRAM initialization files

object Cache {
    val addrWidth = 32
    val reqDataWidth = 32
    val memDataWidth = 512
    val idWidth = 8
    val numWays = 4
    val sizeBytes = 4096
    val sizeReductionWidth = 0
    val numSets = sizeBytes / (memDataWidth / 8) / numWays
}

class Cache(addrWidth: Int=Cache.addrWidth, idWidth: Int=Cache.idWidth, reqDataWidth: Int=Cache.reqDataWidth, memDataWidth: Int=Cache.memDataWidth, sizeReductionWidth: Int=Cache.sizeReductionWidth) extends Module {
    val io = IO(new CacheIO(addrWidth, idWidth, reqDataWidth, memDataWidth, sizeReductionWidth))
}

class DummyCache(addrWidth: Int=Cache.addrWidth, idWidth: Int=Cache.idWidth, reqDataWidth: Int=Cache.reqDataWidth, memDataWidth: Int=Cache.memDataWidth, sizeReductionWidth: Int=Cache.sizeReductionWidth) extends Cache(addrWidth, idWidth, reqDataWidth, memDataWidth, sizeReductionWidth) {
    io.outMisses <> io.inReq
    io.outData.valid := false.B
    io.outData.bits := DontCare
    io.inData.ready := true.B
    if(Profiling.enable) {
      val receivedRequestsCount = ProfilingCounter(io.inReq.valid & io.inReq.ready, io.axiProfiling)
      val hitCount = 0.U(Profiling.dataWidth.W)
      val cyclesOutMissesStall = ProfilingCounter(io.outMisses.valid & ~io.outMisses.ready, io.axiProfiling)
      val cyclesOutDataStall = 0.U(Profiling.dataWidth.W)
      val profilingRegisters = Array(receivedRequestsCount, hitCount, cyclesOutMissesStall, cyclesOutDataStall)
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

class RRCache(addrWidth: Int=Cache.addrWidth, idWidth: Int=Cache.idWidth, reqDataWidth: Int=Cache.reqDataWidth, memDataWidth: Int=Cache.memDataWidth, numWays: Int=Cache.numWays, sizeBytes: Int=Cache.sizeBytes, sizeReductionWidth: Int=Cache.sizeReductionWidth) extends Cache(addrWidth, idWidth, reqDataWidth, memDataWidth, sizeReductionWidth) {
    require(isPow2(reqDataWidth))
    require(isPow2(memDataWidth))
    require(isPow2(numWays))
    require(isPow2(sizeBytes))

    val numSets = sizeBytes / (memDataWidth / 8) / numWays
    val offsetWidth = log2Ceil(memDataWidth / reqDataWidth)
    val setWidth = log2Ceil(numSets)
    val tagWidth = addrWidth - offsetWidth - setWidth
    val maxSizeReduction = (1 << sizeReductionWidth)
    val minSetWidth = setWidth - maxSizeReduction
    val maxTagWidth = addrWidth - offsetWidth - minSetWidth
    val cacheLineType = new CacheLineNoValid(maxTagWidth, memDataWidth)
    val memWidth = cacheLineType.getWidth
    def getSet(input: UInt, setWidth: Int): UInt = input(offsetWidth + setWidth - 1, offsetWidth)
    def getSet(input: UInt, log2SizeReduction: UInt, setWidth: Int=setWidth): UInt = MuxLookup(log2SizeReduction, getSet(input, setWidth), (0 until (1 << log2SizeReduction.getWidth)).map(i => (i.U -> getSet(input, setWidth - i))))
    def getTag(input: UInt, tagWidth: Int=tagWidth, addrWidth: Int=addrWidth): UInt = input(addrWidth - 1, addrWidth - tagWidth)
    def getOffset(input: UInt, offsetWidth: Int=offsetWidth): UInt = input(offsetWidth - 1, 0)

    // BRAMs are initialized with zeros by default
    val dataMemories = Array.fill(numWays)(Module(new XilinxSimpleDualPortNoChangeBRAM(width=memWidth, depth=numSets)).io)
    // val validMemories = Array.fill(numWays)(Module(new XilinxDoublePumped2W2RSDPBRAM(width=1, depth=numSets, initFile=initFilePath)).io)
    val validMemories = Array.fill(numWays)(Module(new XilinxTrueDualPortReadFirstBRAM(width=1, depth=numSets)).io)
    val invalidating = Wire(Bool()) /* Enabled while the cache is being invalidated */

    /* inReq delay network */
    val inReqPipelineReady = Wire(Bool())
    val delayedRequestThreeCycles = Wire(ValidIO(io.inReq.bits.cloneType))
    val delayedRequestTwoCycles = Wire(ValidIO(io.inReq.bits.cloneType))
    delayedRequestTwoCycles.bits := RegEnable(RegEnable(io.inReq.bits, enable=inReqPipelineReady), enable=inReqPipelineReady)
    delayedRequestTwoCycles.valid := RegEnable(RegEnable(io.inReq.valid & ~invalidating, init=false.B, enable=inReqPipelineReady), init=false.B, enable=inReqPipelineReady)
    delayedRequestThreeCycles.bits := RegEnable(delayedRequestTwoCycles.bits, enable=inReqPipelineReady)
    delayedRequestThreeCycles.valid := RegEnable(delayedRequestTwoCycles.valid, init=false.B, enable=inReqPipelineReady)
    io.inReq.ready := inReqPipelineReady & ~invalidating

    val cacheLines = Wire(Vec(numWays, cacheLineType))
    val valids = Wire(Vec(numWays, Bool()))
    /* b channel of memories: serve requests (read-only) */
    for(i <- 0 until numWays) {
        dataMemories(i).clock := clock
        dataMemories(i).reset := reset
        dataMemories(i).addrb := getSet(io.inReq.bits.addr, io.log2SizeReduction)
        dataMemories(i).enb := inReqPipelineReady
        dataMemories(i).regceb := inReqPipelineReady
        cacheLines(i) := cacheLineType.fromBits(dataMemories(i).doutb)

        //validMemories(i).clock2x := io.clock2x
        //validMemories(i).rdaddrb := getSet(io.inReq.bits.addr, io.log2SizeReduction)
        validMemories(i).clock := clock
        validMemories(i).reset := reset
        validMemories(i).addrb := getSet(io.inReq.bits.addr, io.log2SizeReduction)
        validMemories(i).regceb := inReqPipelineReady
        validMemories(i).enb := inReqPipelineReady
        valids(i) := validMemories(i).doutb === 1.U
    }
    val hits = (0 until numWays).map(
      i => valids(i) & MuxLookup(
        io.log2SizeReduction,
        cacheLines(i).tag === getTag(delayedRequestTwoCycles.bits.addr),
        (0 until maxSizeReduction).map(
          j => (j.U -> (cacheLines(i).tag(maxTagWidth-1, maxSizeReduction-j) === getTag(delayedRequestTwoCycles.bits.addr, tagWidth+j)))
        )
      )
    )

    val hit = RegEnable(Vec(hits).asUInt.orR, enable=inReqPipelineReady, init=false.B) & io.enabled
    val selectedLine = RegEnable(Mux1H(hits, cacheLines), enable=inReqPipelineReady)
    val delayedOffset = getOffset(delayedRequestThreeCycles.bits.addr)
    val selectedData = MuxLookup(delayedOffset, selectedLine.data(reqDataWidth-1, 0), (0 until memDataWidth by reqDataWidth).map(i => (i/reqDataWidth).U -> selectedLine.data(i+reqDataWidth-1, i)))

    /* outData EB and connections to output */
    val outDataEb = Module(new ElasticBuffer(io.outData.bits.cloneType))
    outDataEb.io.out <> io.outData
    outDataEb.io.in.valid := delayedRequestThreeCycles.valid & hit
    outDataEb.io.in.bits.id := delayedRequestThreeCycles.bits.id
    outDataEb.io.in.bits.data := selectedData

    /* outMisses EB and connections to output */
    val outMissesEb = Module(new ElasticBuffer(io.outMisses.bits.cloneType))
    outMissesEb.io.out <> io.outMisses
    outMissesEb.io.in.valid := delayedRequestThreeCycles.valid & ~hit
    outMissesEb.io.in.bits := delayedRequestThreeCycles.bits

    /* inReqPipelineReady */
    inReqPipelineReady := MuxCase(true.B, Array(outDataEb.io.in.valid -> outDataEb.io.in.ready, outMissesEb.io.in.valid -> outMissesEb.io.in.ready))

    /* inData (cache update) delay network */
    /* First, we read all the sets to figure out which ones are free. Then, we select one that is free. If they are all full, choose (pseudo)randomly. */
    val delayedData = Wire(ValidIO(io.inData.bits.cloneType))
    delayedData.bits := RegNext(RegNext(io.inData.bits))
    delayedData.valid := RegNext(RegNext(io.inData.valid & io.inData.ready, init=false.B), init=false.B)
    /* a channels of data memory, d channel of valid memories: cache update (read/write) and invalidation */
    /* By writing on the d channel, all read channels still see the old data when reading
     * and writing the same address in the same cycle. */
    val newCacheLine = Wire(cacheLineType)
    newCacheLine.tag := getTag(delayedData.bits.addr, maxTagWidth)
    newCacheLine.data := delayedData.bits.data
    val availableWaySelectionArbiter = Module(new Arbiter(Bool(), numWays))
    val wayToUpdateSelect = Wire(Vec(numWays, Bool()))
    val invalidationAddressEn = Wire(Bool())
    val invalidationAddress = Counter(invalidationAddressEn, numSets)
    for(i <- 0 until numWays) {

        // validMemories(i).wraddrd := Mux(invalidating, invalidationAddress._1, getSet(delayedData.bits.addr, io.log2SizeReduction))
        // validMemories(i).wed := (delayedData.valid & wayToUpdateSelect(i)) | invalidating
        // validMemories(i).dind := ~invalidating
        // dataMemories(i).wea := validMemories(i).wed
        //validMemories(i).rdaddra := io.inData.bits.addr
        validMemories(i).addra := Mux(invalidating, invalidationAddress._1, getSet(Mux(delayedData.valid, delayedData.bits.addr, io.inData.bits.addr), io.log2SizeReduction))
        validMemories(i).regcea := true.B
        validMemories(i).ena := true.B
        validMemories(i).wea := (delayedData.valid & wayToUpdateSelect(i)) | invalidating
        validMemories(i).dina := ~invalidating
        dataMemories(i).addra := getSet(delayedData.bits.addr, io.log2SizeReduction)
        dataMemories(i).dina := newCacheLine.asUInt
        dataMemories(i).wea := validMemories(i).wea
        availableWaySelectionArbiter.io.in(i).valid := validMemories(i).douta === 0.U
    }
    val lfsr = LFSR16(delayedData.valid)
    if (numWays > 1)
        wayToUpdateSelect := UIntToOH(Mux(availableWaySelectionArbiter.io.out.valid, availableWaySelectionArbiter.io.chosen, lfsr(log2Ceil(numWays)-1, 0))).toBools
    else
        wayToUpdateSelect(0) := true.B
    // io.inData.ready := true.B // ~delayedData.valid
    io.inData.ready := ~delayedData.valid

    /* Invalidation FSM */
    val sNormal :: sInvalidating :: Nil = Enum(2)
    val state = RegInit(init=sNormal)

    invalidating := false.B
    invalidationAddressEn := false.B
    switch(state) {
      is (sNormal) {
        when(io.invalidate) {
          state := sInvalidating
        }
      }
      is (sInvalidating) {
        invalidating := true.B
        invalidationAddressEn := true.B
        when(invalidationAddress._2) {
          state := sNormal
        }
      }
    }


    if(Profiling.enable) {
      val receivedRequestsCount = ProfilingCounter(io.inReq.valid & io.inReq.ready, io.axiProfiling)
      val hitCount = ProfilingCounter(outDataEb.io.in.valid & outDataEb.io.in.ready, io.axiProfiling)
      val cyclesOutMissesStall = ProfilingCounter(io.outMisses.valid & ~io.outMisses.ready, io.axiProfiling)
      val cyclesOutDataStall = ProfilingCounter(io.outData.valid & ~io.outData.ready, io.axiProfiling)
      val profilingRegisters = Array(receivedRequestsCount, hitCount, cyclesOutMissesStall, cyclesOutDataStall)
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

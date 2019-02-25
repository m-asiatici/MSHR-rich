package fpgamshr.reqhandler.traditional

import chisel3._
import fpgamshr.interfaces._
import fpgamshr.util._
import chisel3.util._
import fpgamshr.profiling._
import fpgamshr.reqhandler.ResponseGeneratorOneOutputArbitraryEntriesPerRow

object MSHRTraditional {
    val addrWidth = 30 /* Excluding the part that is always 0, i.e. the log2Ceil(reqDataWidth) least significant bits, and the req handler address (log2Ceil(numReqHandlers)) */
    val idWidth = 8
    val memDataWidth = 512
    val reqDataWidth = 32

    val numSubentriesPerRow = 3
    val pipelineLength = 1
    val numMSHR = 16
}


class MSHRTraditional(addrWidth: Int=MSHRTraditional.addrWidth, numMSHR: Int=MSHRTraditional.numMSHR, numSubentriesPerRow: Int=MSHRTraditional.numSubentriesPerRow, idWidth: Int=MSHRTraditional.idWidth, memDataWidth: Int=MSHRTraditional.memDataWidth, reqDataWidth: Int=MSHRTraditional.reqDataWidth) extends Module {
    require(isPow2(memDataWidth / reqDataWidth))
    val offsetWidth = log2Ceil(memDataWidth / reqDataWidth)
    /* tagWidth has the same role as splWidth in the LevelComparator: it is the high part of the address,
     * excluding the offset within the cache line. */
    val tagWidth = addrWidth - offsetWidth
    // val memWidth = new MSHRRow(tagWidth, ldBufRowAddrWidth, numMSHRPerRow).getWidth // numMSHRPerRow * (tagWidth + ldBufRowAddrWidth) + log2Ceil(numMSHRPerRow)
    val ldBufRowAddrWidth = log2Ceil(numMSHR)
    val ldBufEntryIdxWidth = log2Ceil(numSubentriesPerRow - 1)
    val io = IO(new Bundle{
        /* Incoming requests */
        val allocIn = DecoupledIO(new AddrIdIO(addrWidth, idWidth)).flip
        val deallocIn = DecoupledIO(new AddrDataIO(addrWidth, memDataWidth)).flip
        /* Output to the load buffer unit */
        val outLdBuf = DecoupledIO(new TraditionalMSHRToLdBufIO(offsetWidth, idWidth, dataWidth=memDataWidth, rowAddrWidth=ldBufRowAddrWidth, ldBufEntryIdxWidth))
        /* Interface to memory arbiter, with burst requests to be sent to DDR */
        val outMem = DecoupledIO(UInt(tagWidth.W))

        val axiProfiling = new AXI4LiteReadOnlyProfiling(Profiling.dataWidth, Profiling.regAddrWidth)
    })

    def getTag(input: UInt, addrWidth: Int=addrWidth, tagWidth: Int=tagWidth): UInt = input(addrWidth - 1, addrWidth - tagWidth)
    def getOffset(input: UInt, offsetWidth: Int=offsetWidth): UInt = input(offsetWidth - 1, 0)

    /* Input selection */
    /* inputArbiter selects between allocations and deallocations. Only the address is selected:
     * the request-specific fields (data and ID) are taken directly from the respective input
     * when it is selected. */
    val inputArbiter = Module(new Arbiter(new AddrDataIdIO(addrWidth, memDataWidth, idWidth), 2))
    inputArbiter.io.in(0).bits.addr := io.deallocIn.bits.addr
    inputArbiter.io.in(0).bits.data := io.deallocIn.bits.data
    inputArbiter.io.in(0).bits.id := DontCare
    inputArbiter.io.in(0).valid := io.deallocIn.valid
    io.deallocIn.ready := inputArbiter.io.in(0).ready

    /* inputAllocArbiter selects between a new allocation and the one that caused the stall, if it exists. */
    val inputAllocArbiter = Module(new Arbiter(io.allocIn.bits.cloneType, 2))
    val stallAddress = Reg(UInt(addrWidth.W))
    val stallId = Reg(UInt(idWidth.W))
    val stallValid = RegInit(false.B) /* stallAddress and stallId are valid */
    val stall = RegInit(false.B) /* Whether we are in stall or not */
    val stallTrigger = Wire(Bool())

    inputAllocArbiter.io.in(0).bits.addr := stallAddress
    inputAllocArbiter.io.in(0).bits.id := stallId
    inputAllocArbiter.io.in(0).valid := stallValid
    inputAllocArbiter.io.in(1).bits := io.allocIn.bits
    inputAllocArbiter.io.in(1).valid := io.allocIn.valid
    io.allocIn.ready := inputAllocArbiter.io.in(1).ready

    inputArbiter.io.in(1).bits.addr := inputAllocArbiter.io.out.bits.addr
    inputArbiter.io.in(1).bits.id := inputAllocArbiter.io.out.bits.id
    inputArbiter.io.in(1).bits.data := DontCare
    inputArbiter.io.in(1).valid := inputAllocArbiter.io.out.valid & ~(stall | stallTrigger)
    inputAllocArbiter.io.out.ready := (inputArbiter.io.in(1).ready & ~(stall | stallTrigger)) // | (stallClear & stall & stallBecauseLdBufRowFull)

    /* Current request */
    val pipelineReady = Wire(Bool())
    val emptyRequest = Wire(ValidIO(new AddrDataIdAllocIO(addrWidth, memDataWidth, idWidth)))
    emptyRequest.valid := false.B
    emptyRequest.bits := DontCare
    val delayedRequest = RegInit(emptyRequest)
    when(pipelineReady) {
      delayedRequest.bits.addr := inputArbiter.io.out.bits.addr
      delayedRequest.bits.data := inputArbiter.io.out.bits.data
      delayedRequest.bits.id := inputArbiter.io.out.bits.id
      delayedRequest.valid := inputArbiter.io.out.valid
      delayedRequest.bits.isAlloc := inputArbiter.io.chosen === 1.U
    }
    inputArbiter.io.out.ready := pipelineReady

    val currAddress = delayedRequest.bits.addr
    val currTag = getTag(currAddress)
    val currOffset = getOffset(currAddress)
    val currId = delayedRequest.bits.id
    val currData = delayedRequest.bits.data
    val isCurrAlloc = delayedRequest.valid & delayedRequest.bits.isAlloc
    val isCurrDealloc = delayedRequest.valid & ~delayedRequest.bits.isAlloc

    // val mshrs = Reg(Vec(Array.fill(numMSHR)(TraditionalMSHREntry(tagWidth, log2Ceil(numSubentriesPerRow)))))
    val defaultEntry = Wire(new TraditionalMSHREntry(tagWidth, ldBufEntryIdxWidth))
    defaultEntry.valid := false.B
    defaultEntry.tag := DontCare
    defaultEntry.ldBufLastValidIdx := DontCare
    val mshrs = Reg(init = Vec(Seq.fill(numMSHR)(defaultEntry)))

    /* Comparison logic */
    val entrySelection = mshrs.map(m => m.tag === currTag & m.valid)
    val hit = Vec(entrySelection).asUInt.orR
    val mshrFull = Vec(mshrs.map(_.valid)).asUInt.andR
    val currLdBufRowFull = Mux1H(entrySelection, mshrs.map(_.ldBufLastValidIdx)) === (numSubentriesPerRow - 1).U
    // val newEntrySelectionOH = PriorityMux((0 until numMSHR).map(i => ~mshrs(i).valid -> (1 << i).U))
    val newEntrySelectionOH = PriorityEncoderOH((0 until numMSHR).map(i => ~mshrs(i).valid))

    /* MSHR update */
    /* mshrs is a register, so if we don't assign anything, it will retain the previous value. */
    for(i <- 0 until numMSHR) {
        when(isCurrAlloc & newEntrySelectionOH(i) & ~hit & ~mshrFull & pipelineReady) {
            mshrs(i).tag := currTag
            mshrs(i).valid := true.B
        } .elsewhen(isCurrDealloc & entrySelection(i) & pipelineReady) {
            mshrs(i).valid := false.B
        }
        when(entrySelection(i)) {
            when(isCurrAlloc & ~currLdBufRowFull & pipelineReady) {
                when(hit) {
                    mshrs(i).ldBufLastValidIdx := mshrs(i).ldBufLastValidIdx + 1.U
                } .otherwise {
                    mshrs(i).ldBufLastValidIdx := 0.U
                }
            } .elsewhen(isCurrDealloc & pipelineReady) {
                mshrs(i).ldBufLastValidIdx := 0.U
            }
        }
    }

    /* Stall logic */
    /* Two possible reasons for stalling:
     * 1) there is no hit and we don't have any empty MSHR. Cleared on any deallocation,
     *    the request that caused it will miss again even after receiving the new data
     *    as they have nothing to do with each other.
     * 2) there is a hit and there are no more load buffers for that entry. Cleared
     *    on a deallocation with the same tag as the offending request; the offending
     *    request can be immediately serviced with the data that just arrived.
     */
    val stallTriggerLdBufRowFull = isCurrAlloc & hit & currLdBufRowFull
    val stallTriggerMSHRFull = isCurrAlloc & ~hit & mshrFull
    stallTrigger := stallTriggerLdBufRowFull | stallTriggerMSHRFull
    val stallClear = Wire(Bool())
    val stallBecauseLdBufRowFull = RegInit(false.B)

    when(stallTrigger) {
        stall := true.B
    } .elsewhen(stallClear) {
        stall := false.B
    }

    when(stallTriggerLdBufRowFull) {
        stallBecauseLdBufRowFull := true.B
    } .elsewhen(stallTriggerMSHRFull) {
        stallBecauseLdBufRowFull := false.B
    }
    stallClear := isCurrDealloc & (~stallBecauseLdBufRowFull | (getTag(stallAddress) === currTag))
    when(stallTrigger & ~stall) {
        stallAddress := currAddress
        stallId := currId
    }

    when(stallTriggerMSHRFull & ~stall) {
        stallValid := true.B
    } .elsewhen(inputAllocArbiter.io.in(0).ready) {
        stallValid := false.B
    }


    /* Output to memory */
    val externalMemoryQueue = Module(new BRAMQueue(tagWidth, numMSHR))
    externalMemoryQueue.io.deq <> io.outMem
    externalMemoryQueue.io.enq.valid := isCurrAlloc & ~hit & ~mshrFull & pipelineReady
    externalMemoryQueue.io.enq.bits := currTag

    /* Output to load buffer */
    /* When we clear the stall due to a full load buffer, we send the entry that caused the stall
     * to the load buffer in the same transaction as the deallocation that resolved the stall.
     * To tell the load buffer that it must consider entry even if it is a deallocation, additionalEntryValid is set.
     * This additional entry will be appended to the others when it will be sent to the response generator.
     * This was easier than recirculating the entry through the cache, as it was difficult to ensure that the
     * moment the cache it receives the entry, the respective cacheline has been already written (the write takes
     * 3 cycles). */
    io.outLdBuf.valid := delayedRequest.valid & ~stallTrigger
    io.outLdBuf.bits.entry.offset := Mux(isCurrDealloc, getOffset(stallAddress), currOffset)
    io.outLdBuf.bits.entry.id := Mux(isCurrDealloc, stallId, currId)
    io.outLdBuf.bits.data := currData
    io.outLdBuf.bits.rowAddr := Mux(hit, PriorityEncoder(Vec(entrySelection).asUInt), PriorityEncoder(mshrs.map(~_.valid)))
    io.outLdBuf.bits.opType.allocateEntry := isCurrAlloc
    io.outLdBuf.bits.opType.allocateRow := isCurrAlloc & ~hit
    io.outLdBuf.bits.lastValidIdx := Mux(hit, Mux1H(entrySelection, mshrs.map(_.ldBufLastValidIdx)), 0.U)
    val additionalEntryValid = RegInit(false.B)
    when(io.outLdBuf.ready) {
        additionalEntryValid := false.B
    } .elsewhen(stallClear & stallBecauseLdBufRowFull & stall) {
        additionalEntryValid := true.B
    }

    io.outLdBuf.bits.additionalEntryValid := additionalEntryValid | (stallClear & stallBecauseLdBufRowFull & stall)
    pipelineReady := io.outLdBuf.ready | stallTrigger

    if(Profiling.enable) {
      /* The order by which registers are appended to profilingRegisters defines the register map */
      val profilingRegisters = scala.collection.mutable.ListBuffer[UInt]()
      val usedMSHRCounter = PopCount(mshrs.map(m => m.valid))
      val currentlyUsedMSHR = RegEnable(usedMSHRCounter, enable=io.axiProfiling.snapshot)
/* 0*/profilingRegisters += currentlyUsedMSHR
      val maxUsedMSHR = ProfilingMax(usedMSHRCounter, io.axiProfiling)
/* 1*/profilingRegisters += maxUsedMSHR
      val cyclesMSHRFull = ProfilingCounter(stall & ~stallBecauseLdBufRowFull, io.axiProfiling)
/* 2*/profilingRegisters += cyclesMSHRFull
      val cyclesLdBufFull = ProfilingCounter(stall & stallBecauseLdBufRowFull, io.axiProfiling)
/* 3*/profilingRegisters += cyclesLdBufFull
      val stallTriggerCount = 0.U
/* 4*/profilingRegisters += stallTriggerCount
      val cyclesSpentStalling = 0.U
/* 5*/profilingRegisters += cyclesSpentStalling
      val acceptedAllocsCount = ProfilingCounter(io.outLdBuf.bits.opType.allocateEntry & io.outLdBuf.valid & io.outLdBuf.ready, io.axiProfiling)
/* 6*/profilingRegisters += acceptedAllocsCount
      val acceptedDeallocsCount = ProfilingCounter(~io.outLdBuf.bits.opType.allocateEntry & io.outLdBuf.valid & io.outLdBuf.ready, io.axiProfiling)
/* 7*/profilingRegisters += acceptedDeallocsCount
      val cyclesAllocsStalled = ProfilingCounter(io.allocIn.valid & ~io.allocIn.ready, io.axiProfiling)
/* 8*/profilingRegisters += cyclesAllocsStalled
      val cyclesDeallocsStalled = ProfilingCounter(io.deallocIn.valid & ~io.deallocIn.ready, io.axiProfiling)
/* 9*/profilingRegisters += cyclesDeallocsStalled
      val enqueuedMemReqsCount = ProfilingCounter(externalMemoryQueue.io.enq.valid, io.axiProfiling)
/*10*/profilingRegisters += enqueuedMemReqsCount
      val cyclesOutLdBufNotReady = ProfilingCounter(io.outLdBuf.valid & ~io.outLdBuf.ready, io.axiProfiling)
/*11*/profilingRegisters += cyclesOutLdBufNotReady
      // readLine.validCount, writeLine.validCount, wrEn
      if(Profiling.enableHistograms) {
        val currentlyUsedMSHRHistogram = (0 until log2Ceil(numMSHR)).map(i => ProfilingCounter(usedMSHRCounter >= (1 << i).U, io.axiProfiling))
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

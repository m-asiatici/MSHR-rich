package fpgamshr.reqhandler.cuckoo

import chisel3._
import fpgamshr.interfaces._
import fpgamshr.util._
import chisel3.util._
import fpgamshr.profiling._
import chisel3.core.dontTouch
import fpgamshr.main.FPGAMSHR

import java.io.{File, BufferedWriter, FileWriter} // To generate the BRAM initialization files

import scala.collection.mutable.ArrayBuffer

object SubentryBuffer {
    val numEntriesPerRow = 4
    val rowAddrWidth = 8
    val idWidth = 22
    val memDataWidth = 512
    val reqDataWidth = 32
    val mshrPipelineLength = 3 + 2 // 3 stages + EB after input arbiter

    val bramLatency = 2
    val inputQueuesDepth = 32
    val pipelineLength = 3
    val nextPtrCacheSize = 8
}

class SubentryBuffer(idWidth: Int=SubentryBuffer.idWidth, memDataWidth: Int=SubentryBuffer.memDataWidth, reqDataWidth: Int=SubentryBuffer.reqDataWidth, rowAddrWidth: Int=SubentryBuffer.rowAddrWidth, numEntriesPerRow: Int=SubentryBuffer.numEntriesPerRow, mshrPipelineLength: Int=SubentryBuffer.mshrPipelineLength, nextPtrCacheSize: Int=SubentryBuffer.nextPtrCacheSize, blockOnNextPtr: Boolean=false) extends Module {
    require(isPow2(memDataWidth / reqDataWidth))
    require(numEntriesPerRow > 0)
    val offsetWidth = log2Ceil(memDataWidth / reqDataWidth)
    val memType = new LdBufRow(offsetWidth, idWidth, numEntriesPerRow, rowAddrWidth)
    val memWidth = memType.getWidth
    val memDepth = 1 << rowAddrWidth
    val inputQueuesDepth = SubentryBuffer.inputQueuesDepth
    val totalEntries = numEntriesPerRow * (1 << rowAddrWidth)
    val io = IO(new Bundle {
        val in = DecoupledIO(new MSHRToLdBufIO(offsetWidth, idWidth, dataWidth=memDataWidth, rowAddrWidth=rowAddrWidth)).flip
        val frqOut = DecoupledIO(UInt(rowAddrWidth.W))
        val stopAlloc = Output(Bool())
        val respGenOut = DecoupledIO(new RespGenIO(memDataWidth, offsetWidth, idWidth, numEntriesPerRow))
        val axiProfiling = new AXI4LiteReadOnlyProfiling(Profiling.dataWidth, Profiling.regAddrWidth)
    })

    /* Input logic: single queue for both allocations and deallocations, to
     * prevent reordering (which would cause problems if, e.g., a row ends up
     * being deallocated before new requests for the same row arrive). We ask
     * the MSHR unit to stall allocations when the FRQ is not able to satisfy
     * at most one new row per slot in the shared pipeline (in both the MSHR
     * and the load buffer). */
    val inputQueue = Module(new Queue(new MSHRToLdBufIO(offsetWidth, idWidth, memDataWidth, rowAddrWidth), inputQueuesDepth))
    inputQueue.io.enq <> io.in
    /* To avoid possible problems down the road... */
    inputQueue.io.enq.bits.opType.allocateRow := io.in.bits.opType.allocateRow & io.in.bits.opType.allocateEntry

    val memory = Module(new XilinxSimpleDualPortNoChangeBRAM(width=memWidth, depth=memDepth))
    memory.io.clock := clock
    memory.io.reset := reset

    val sharedPipelineReady = Wire(Bool())

    /* True if the row just read from memory has a valid nextRowPtr */
    val nextRowPtrValid = Wire(Bool())
    /* nextRowPtr of the row just read from memory */
    val nextRowPtr = Wire(UInt(rowAddrWidth.W))

    /* Arbitrates between incoming requests and next row of the current delayedRequest */
    val inputArbiter = Module(new Arbiter(new MSHRToLdBufWithOrigAddrIO(offsetWidth, idWidth, memDataWidth, rowAddrWidth), 2))
    inputArbiter.io.in(1).valid := inputQueue.io.deq.valid
    inputQueue.io.deq.ready := inputArbiter.io.in(1).ready
    inputArbiter.io.in(1).bits.rowAddr := inputQueue.io.deq.bits.rowAddr
    inputArbiter.io.in(1).bits.origRowAddr := inputQueue.io.deq.bits.rowAddr
    inputArbiter.io.in(1).bits.entry   := inputQueue.io.deq.bits.entry
    inputArbiter.io.in(1).bits.data    := inputQueue.io.deq.bits.data
    inputArbiter.io.in(1).bits.opType  := inputQueue.io.deq.bits.opType

    inputArbiter.io.out.ready := sharedPipelineReady
    val delayedRequest = Wire(Vec(SubentryBuffer.bramLatency + 1, ValidIO(inputArbiter.io.out.bits.cloneType)))
    delayedRequest(0).valid := RegEnable(inputArbiter.io.out.valid, enable=sharedPipelineReady, init=false.B)
    delayedRequest(0).bits  := RegEnable(inputArbiter.io.out.bits, enable=sharedPipelineReady)

    /* NextPtrCache */
    /* Lookup is between delayedRequest(0) and (1) */
    val nextPtrCache = Module(new NextPtrCache(rowAddrWidth, nextPtrCacheSize))
    if(nextPtrCacheSize > 0) {
      nextPtrCache.io.lookupAddr.valid := delayedRequest(0).valid
      nextPtrCache.io.lookupAddr.bits.origRowAddr  := delayedRequest(0).bits.origRowAddr
      nextPtrCache.io.lookupAddr.bits.rowAddr  := delayedRequest(0).bits.rowAddr
      nextPtrCache.io.deallocMatchingEntry := ~delayedRequest(0).bits.opType.allocateEntry
      delayedRequest(1).bits.rowAddr  := RegEnable(nextPtrCache.io.outAddr, enable=sharedPipelineReady)
    } else {
      nextPtrCache.io.lookupAddr.valid := false.B
      nextPtrCache.io.lookupAddr.bits := DontCare
      nextPtrCache.io.deallocMatchingEntry := DontCare
      delayedRequest(1).bits.rowAddr  := RegEnable(delayedRequest(0).bits.rowAddr, enable=sharedPipelineReady)
    }
    delayedRequest(1).bits.origRowAddr  := RegEnable(delayedRequest(0).bits.origRowAddr, enable=sharedPipelineReady)
    delayedRequest(1).valid := RegEnable(delayedRequest(0).valid, enable=sharedPipelineReady, init=false.B)
    delayedRequest(1).bits.entry  := RegEnable(delayedRequest(0).bits.entry, enable=sharedPipelineReady)
    delayedRequest(1).bits.data  := RegEnable(delayedRequest(0).bits.data, enable=sharedPipelineReady)
    delayedRequest(1).bits.opType  := RegEnable(delayedRequest(0).bits.opType, enable=sharedPipelineReady)

    for(i <- 2 until SubentryBuffer.bramLatency + 1) {
      delayedRequest(i).valid := RegEnable(delayedRequest(i-1).valid, enable=sharedPipelineReady, init=false.B)
      delayedRequest(i).bits := RegEnable(delayedRequest(i-1).bits, enable=sharedPipelineReady)
    }

    inputArbiter.io.in(0).valid := delayedRequest.last.valid & nextRowPtrValid
    inputArbiter.io.in(0).bits.rowAddr := nextRowPtr
    inputArbiter.io.in(0).bits.origRowAddr := delayedRequest.last.bits.origRowAddr
    inputArbiter.io.in(0).bits.entry := delayedRequest.last.bits.entry
    inputArbiter.io.in(0).bits.data := delayedRequest.last.bits.data
    inputArbiter.io.in(0).bits.opType := delayedRequest.last.bits.opType

    val isDelayedAlloc = delayedRequest.last.valid & delayedRequest.last.bits.opType.allocateEntry
    val isDelayedDealloc = delayedRequest.last.valid & ~delayedRequest.last.bits.opType.allocateEntry

    /* Memory read port */
    if(nextPtrCacheSize > 0) {
      memory.io.addrb := nextPtrCache.io.outAddr
    } else {
      memory.io.addrb := delayedRequest(0).bits.rowAddr
    }
    memory.io.enb := sharedPipelineReady
    memory.io.regceb := sharedPipelineReady

    /* Update network */
    val updateNetwork = Module(new SubentryBufferUpdateNetwork(offsetWidth, idWidth, rowAddrWidth, numEntriesPerRow))
    nextRowPtrValid := updateNetwork.io.outRow.nextPtrValid
    nextRowPtr := updateNetwork.io.outRow.nextPtr
    updateNetwork.io.newEntry := delayedRequest.last.bits.entry
    updateNetwork.io.createNewRow := delayedRequest.last.bits.opType.allocateRow


    /* Forward and write pipeline: contains the next row to be written (entry 0) and the last 2 written rows,
       for forwarding. */
    val invalidLdBufWritePipelineIO = Wire(ValidIO(new LdBufWritePipelineIO(offsetWidth, idWidth, rowAddrWidth, numEntriesPerRow)))
    invalidLdBufWritePipelineIO.valid := false.B
    invalidLdBufWritePipelineIO.bits := DontCare
    invalidLdBufWritePipelineIO.bits.entry := DontCare
    invalidLdBufWritePipelineIO.bits.rowAddr := DontCare
    for(i <- 0 until numEntriesPerRow) {
        invalidLdBufWritePipelineIO.bits.row.entries(i) := DontCare
    }
    invalidLdBufWritePipelineIO.bits.row.lastValidIdx := DontCare
    invalidLdBufWritePipelineIO.bits.row.nextPtrValid := false.B
    invalidLdBufWritePipelineIO.bits.row.nextPtr := DontCare
    invalidLdBufWritePipelineIO.bits.rowFull := false.B
    val forwardPipeline = RegInit(Vec(Seq.fill(SubentryBuffer.pipelineLength)(invalidLdBufWritePipelineIO)))

    /* FRQ and its connections + stopAlloc */
    val frq = Module(new FreeRowQueue(rowAddrWidth, mshrPipelineLength + inputQueuesDepth + SubentryBuffer.bramLatency + 1)) /* The last 1 is for the additional register just after inputArbiter */
    /* The FRQ must be arbitrated between two consumers: io.frqOut (with highest priority)
     * and the write pipeline. If the FRQ becomes empty and we try to request an entry,
     * stopAlloc must be set to true. */
    io.frqOut.valid := frq.io.deq.valid
    io.frqOut.bits := frq.io.deq.bits
    frq.io.enq.bits := delayedRequest.last.bits.rowAddr
    frq.io.enq.valid := isDelayedDealloc & sharedPipelineReady
    val frqGrantToPipeline = frq.io.deq.valid & ~io.frqOut.ready

    /* Logic to stall */
    if(blockOnNextPtr) {
      val invalidRowWithNextPtrValid = Wire(ValidIO(UInt(rowAddrWidth.W)))
      invalidRowWithNextPtrValid.valid := false.B
      invalidRowWithNextPtrValid.bits := DontCare
      val numEntries = mshrPipelineLength + inputQueuesDepth + SubentryBuffer.bramLatency + 1
      val rowsWithNextRowPtrValid = RegInit(Vec(Seq.fill(numEntries)(invalidRowWithNextPtrValid)))
      val emptyEntrySelect = PriorityEncoderOH(rowsWithNextRowPtrValid.map(x => ~x.valid))
      val memFull = Vec(rowsWithNextRowPtrValid.map(x => x.valid)).asUInt.andR
      val memNotEmpty = Vec(rowsWithNextRowPtrValid.map(x => x.valid)).asUInt.orR
      val DEBUG_overflow = memFull & isDelayedAlloc
      dontTouch(DEBUG_overflow)
      for(i <- 0 until numEntries) {
        when(isDelayedAlloc & updateNetwork.io.rowFull & ~updateNetwork.io.outRow.nextPtrValid & sharedPipelineReady & emptyEntrySelect(i)) {
          rowsWithNextRowPtrValid(i).valid := true.B
          rowsWithNextRowPtrValid(i).bits := delayedRequest.last.bits.origRowAddr
        } .elsewhen(isDelayedDealloc & sharedPipelineReady & (delayedRequest.last.bits.origRowAddr === rowsWithNextRowPtrValid(i).bits)) {
          rowsWithNextRowPtrValid(i).valid := false.B
        }
      }
      io.stopAlloc := frq.io.almostEmpty | memNotEmpty
    } else {
      io.stopAlloc := frq.io.almostEmpty
    }



    when(sharedPipelineReady) {
      forwardPipeline(0).valid := isDelayedAlloc & ~updateNetwork.io.outRow.nextPtrValid
      forwardPipeline(0).bits.entry := delayedRequest.last.bits.entry
      forwardPipeline(0).bits.rowAddr := delayedRequest.last.bits.rowAddr
      forwardPipeline(0).bits.origRowAddr := delayedRequest.last.bits.origRowAddr
      forwardPipeline(0).bits.row.entries := updateNetwork.io.outRow.entries
      forwardPipeline(0).bits.row.lastValidIdx := updateNetwork.io.outRow.lastValidIdx
    }

    /*   Possible situations:
         --------------------------
         | rowFull | nextPtrValid |
         --------------------------
      0  |    F    |      F       | Write updateNetwork.io.outRow
      1  |    F    |      T       | Repeat allocation on row nextPtr, do not write anything yet
      2  |    T    |      F       | Allocate one more row for the new entry, write address of new row to nextPtr of rowAddr
      3  |    T    |      T       | Repeat allocation on row nextPtr, do not write anything yet
         --------------------------
      If nextPtrValid, the request does not enter forwardPipeline.
      2 is the most complex case, because we have to stall the pipeline in order to perform two writes to memory
      instead of one. Therefore, when rowFull is high, we stall the pipeline - by doing so, we also avoid the problem
      of forwarding a row without nextPtr when it is supposed to have it. As soon as the FRQ is ready, we:
      - write the new row just with the new entry
      - clear rowFull
      - write the address of the newly allocated row to nextPtr
      By clearing rowFull, we release the stall and we write the row back to memory, just like in case 0.
    */
    when(forwardPipeline(0).valid & forwardPipeline(0).bits.rowFull & frqGrantToPipeline) {
      forwardPipeline(0).bits.rowFull := false.B
      forwardPipeline(0).bits.row.nextPtr := frq.io.deq.bits
      forwardPipeline(0).bits.row.nextPtrValid := true.B
    } .elsewhen(sharedPipelineReady) {
      forwardPipeline(0).bits.rowFull := isDelayedAlloc & updateNetwork.io.rowFull & ~updateNetwork.io.outRow.nextPtrValid
      forwardPipeline(0).bits.row.nextPtrValid := updateNetwork.io.outRow.nextPtrValid
    }

    frq.io.deq.ready := io.frqOut.ready | (forwardPipeline(0).bits.rowFull & forwardPipeline(0).valid)

    for(i <- 1 until 3) {
      when(sharedPipelineReady) {
        forwardPipeline(i).valid := forwardPipeline(i-1).valid
        forwardPipeline(i).bits := forwardPipeline(i-1).bits
      }
    }

    /* Memory write port */
    val newRowWithOneEntry = Wire(new LdBufRow(offsetWidth, idWidth, numEntriesPerRow, rowAddrWidth))
    newRowWithOneEntry.entries(0) := forwardPipeline(0).bits.entry
    if(numEntriesPerRow > 1) {
        for(i <- 1 until numEntriesPerRow) {
            newRowWithOneEntry.entries(i) := DontCare
        }
    }
    newRowWithOneEntry.lastValidIdx := 0.U
    newRowWithOneEntry.nextPtrValid := false.B
    newRowWithOneEntry.nextPtr := DontCare

    memory.io.addra := Mux(forwardPipeline(0).bits.rowFull, frq.io.deq.bits, forwardPipeline(0).bits.rowAddr)
    memory.io.dina  := Mux(forwardPipeline(0).bits.rowFull, newRowWithOneEntry.asUInt, forwardPipeline(0).bits.row.asUInt)
    memory.io.wea   := forwardPipeline(0).valid & (frqGrantToPipeline | ~forwardPipeline(0).bits.rowFull)

    if(nextPtrCacheSize > 0) {
      nextPtrCache.io.updateEntry.valid := forwardPipeline(0).bits.rowFull & forwardPipeline(0).valid & frqGrantToPipeline
      nextPtrCache.io.updateEntry.bits.rowAddr := forwardPipeline(0).bits.origRowAddr
      nextPtrCache.io.updateEntry.bits.nextPtr := frq.io.deq.bits
    } else {
      nextPtrCache.io.updateEntry.valid := false.B
      nextPtrCache.io.updateEntry.bits := DontCare
    }

    /* Forwarding logic */
    val fixedRow = MuxCase((new LdBufRow(offsetWidth, idWidth, numEntriesPerRow, rowAddrWidth)).fromBits(memory.io.doutb), forwardPipeline.map(x => (x.bits.rowAddr === delayedRequest.last.bits.rowAddr & x.valid) -> x.bits.row))
    updateNetwork.io.inRow := fixedRow

    sharedPipelineReady := ~(forwardPipeline(0).valid & forwardPipeline(0).bits.rowFull) & ~(isDelayedDealloc & ~io.respGenOut.ready)
    io.respGenOut.valid := isDelayedDealloc & ~(forwardPipeline(0).valid & forwardPipeline(0).bits.rowFull)
    io.respGenOut.bits.data := delayedRequest.last.bits.data
    io.respGenOut.bits.entries := fixedRow.entries
    io.respGenOut.bits.lastValidIdx := fixedRow.lastValidIdx


    if(Profiling.enable) {
      //val currentlyUsedEntries = ProfilingUpDownCounter(enUp=(elasticBuffer0.io.in.valid & elasticBuffer0.io.in.ready), enDown=(io.respGenOut.valid & io.respGenOut.ready), io.axiProfiling)
      val (snapshotUsedEntries, currentlyUsedEntries) = ProfilingArbitraryIncrementCounter(in=Array((isDelayedAlloc & ~updateNetwork.io.outRow.nextPtrValid & sharedPipelineReady) -> 1.S, (io.respGenOut.valid & io.respGenOut.ready) -> -(io.respGenOut.bits.lastValidIdx + 1.U((io.respGenOut.bits.lastValidIdx.getWidth + 1).W)).asSInt), io.axiProfiling, width=log2Ceil(totalEntries))
      val maxUsedEntries = ProfilingMax(currentlyUsedEntries, io.axiProfiling)
      val currentlyUsedRows = RegEnable((1 << rowAddrWidth).U - frq.io.count, init=0.U, enable=io.axiProfiling.snapshot)
      val maxUsedRows = ProfilingMax((1 << rowAddrWidth).U - frq.io.count, io.axiProfiling)
      val (snapshotRowsWithNextRowPtrValid, currentRowsWithNextRowPtrValid) = ProfilingUpDownCounter(enUp=(isDelayedAlloc & updateNetwork.io.rowFull & ~updateNetwork.io.outRow.nextPtrValid & sharedPipelineReady), enDown=(io.respGenOut.valid & io.respGenOut.ready & fixedRow.nextPtrValid), io.axiProfiling, width=rowAddrWidth)
      val maxRowsWithNextRowPtrValid = ProfilingMax(currentRowsWithNextRowPtrValid, io.axiProfiling)
      val cyclesRespGenStall = ProfilingCounter(io.respGenOut.valid & ~io.respGenOut.ready, io.axiProfiling)
      val cyclesWritePipelineStall = ProfilingCounter(forwardPipeline(0).valid & forwardPipeline(0).bits.rowFull, io.axiProfiling)
      val cyclesValidNextPtrInputStall = ProfilingCounter(delayedRequest.last.valid & nextRowPtrValid & sharedPipelineReady, io.axiProfiling)
      val nextPtrCacheHits = ProfilingCounter(nextPtrCache.io.hit & sharedPipelineReady, io.axiProfiling)
      /* usedEntriesHistogram(i) = num cycles with at least 2 ^ i used entries */

      val accumUsedEntries = ProfilingArbitraryIncrementCounter(Array((true.B -> (currentlyUsedEntries + 0.U((log2Ceil(totalEntries + 1) + 1).W)).asSInt)), io.axiProfiling)
      val accumUsedRows = ProfilingArbitraryIncrementCounter(Array((true.B -> ((1 << rowAddrWidth).U - frq.io.count).asSInt)), io.axiProfiling)
      val profilingRegisters = ArrayBuffer(snapshotUsedEntries, maxUsedEntries, currentlyUsedRows, maxUsedRows, snapshotRowsWithNextRowPtrValid, maxRowsWithNextRowPtrValid,
                                     cyclesRespGenStall, cyclesWritePipelineStall, cyclesValidNextPtrInputStall, nextPtrCacheHits, accumUsedEntries._1, accumUsedRows._1)// ++ usedEntriesHistogram
      if(Profiling.enableHistograms) {
        val usedEntriesHistogram = (0 until log2Ceil(totalEntries)).map(i => ProfilingCounter(currentlyUsedEntries >= (1 << i).U, io.axiProfiling))
        profilingRegisters ++= usedEntriesHistogram
      }
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

class SubentryBufferUpdateNetwork(offsetWidth: Int, idWidth: Int, rowAddrWidth: Int, entriesPerRow: Int) extends Module {
    require(entriesPerRow > 0)
    val io = IO(new Bundle {
        val newEntry = Input(new LdBufEntry(offsetWidth, idWidth))
        val inRow = Input(new LdBufRow(offsetWidth, idWidth, entriesPerRow, rowAddrWidth))
        val outRow = Output(new LdBufRow(offsetWidth, idWidth, entriesPerRow, rowAddrWidth))
        /* True if newEntry will be the only entry of a new row, false if it has to be inserted into a new row */
        val createNewRow = Input(Bool())
        /* True if inRow is already full */
        val rowFull = Output(Bool())
    })

    io.rowFull := (io.inRow.lastValidIdx === (entriesPerRow - 1).U) & ~io.createNewRow

    when (io.createNewRow) {
        io.outRow.entries(0) := io.newEntry
        for(i <- 1 until entriesPerRow) {
            io.outRow.entries(i).offset := 0.U
            io.outRow.entries(i).id := 0.U
        }
        // io.outRow.entries(i) := DontCare
        io.outRow.lastValidIdx := 0.U
    } .otherwise {
        when(~io.rowFull) {
            io.outRow.lastValidIdx := io.inRow.lastValidIdx + 1.U
            val loadNewEntryHere = UIntToOH(io.outRow.lastValidIdx)
            /* If we are not creating a new row, then there is always at least one entry
             * in inRow */
            io.outRow.entries(0) := io.inRow.entries(0)
            for(i <- 1 until entriesPerRow) io.outRow.entries(i) := Mux(loadNewEntryHere(i), io.newEntry, io.inRow.entries(i))

        } .otherwise {
            io.outRow.lastValidIdx := io.inRow.lastValidIdx
            io.outRow.entries := io.inRow.entries
        }
    }

    io.outRow.nextPtrValid := io.inRow.nextPtrValid & ~io.createNewRow
    io.outRow.nextPtr := io.inRow.nextPtr
}

class NextPtrCache(rowAddrWidth: Int, numEntries: Int) extends Module {
  val io=IO(new Bundle {
    val lookupAddr = ValidIO(new OrigAndNewRowAddrIO(rowAddrWidth)).flip
    val deallocMatchingEntry = Input(Bool())
    val outAddr = Output(UInt(rowAddrWidth.W))
    val hit = Output(Bool())
    val updateEntry = ValidIO(new NextPtrCacheEntryIO(rowAddrWidth)).flip
  })

  if(numEntries > 0) {
    val invalidMemoryEntry = Wire(ValidIO(new NextPtrCacheEntryIO(rowAddrWidth)))
    invalidMemoryEntry.valid := false.B
    invalidMemoryEntry.bits := DontCare
    val memory = RegInit(Vec(Seq.fill(numEntries)(invalidMemoryEntry)))
    val lookupMatches = memory.map(x => x.valid & (x.bits.rowAddr === io.lookupAddr.bits.origRowAddr))
    io.outAddr := MuxCase(io.lookupAddr.bits.rowAddr, memory.zip(lookupMatches).map(x => ((x._2 & ~io.deallocMatchingEntry) -> x._1.bits.nextPtr)))
    io.hit := Vec(lookupMatches).asUInt.orR & io.lookupAddr.valid & ~io.deallocMatchingEntry
    val updateMatches = memory.map(x => x.valid & (x.bits.rowAddr === io.updateEntry.bits.rowAddr))
    val updateHit = Vec(updateMatches).asUInt.orR
    val emptyEntrySelect = PriorityEncoderOH(memory.map(x => ~x.valid))
    val memFull = Vec(memory.map(x => x.valid)).asUInt.andR

    val mruBits = RegInit(Vec(Seq.fill(numEntries)(false.B)))
    val allMruSet = mruBits.asUInt.andR
    val onlyOneMruFalse = PopCount(mruBits) === (numEntries - 1).U

    //val evictCounter = Counter(io.updateEntry.valid & memFull, numEntries)
    //val entryToEvict = UIntToOH(evictCounter._1).toBools
    val entryToEvict = PriorityEncoderOH(~mruBits.asUInt)

    for(i <- 0 until numEntries) {
      when(io.lookupAddr.valid & io.deallocMatchingEntry & lookupMatches(i)) {
        memory(i).valid := false.B
      } .elsewhen(io.updateEntry.valid) {
        when(updateMatches(i)) {
          memory(i).bits.nextPtr := io.updateEntry.bits.nextPtr
        } .elsewhen(memFull & entryToEvict(i) & ~updateHit) {
          memory(i).bits := io.updateEntry.bits
        } .elsewhen(emptyEntrySelect(i) & ~updateHit) {
          memory(i).valid := true.B
          memory(i).bits := io.updateEntry.bits
        }
      }
      when(io.hit & ~io.deallocMatchingEntry) {
        when(lookupMatches(i)) {
          mruBits(i) := true.B
        } .elsewhen(allMruSet) {
          mruBits(i) := false.B
        }
      }
    }
  } else {
    io.hit := false.B
    io.outAddr := DontCare
  }


}

/* Same interface as a normal Chisel Queue, but we need to manually instantiate the
 * BRAM because it has to be initialized */
class FreeRowQueue(rowAddrWidth: Int=SubentryBuffer.rowAddrWidth, almostEmptyMargin: Int) extends Module {
    val io = IO(new Bundle {
        val enq = DecoupledIO(UInt(rowAddrWidth.W)).flip
        val deq = DecoupledIO(UInt(rowAddrWidth.W))
        val count = Output(UInt((rowAddrWidth+1).W))
        val almostEmpty = Output(Bool())
    })
    val memDepth = 1 << rowAddrWidth

    /* Generate BRAM initialization data
     * (all numbers from 0 to memDepth-1) */
    // val initFilePath = new File(".").getAbsolutePath() + "/FRQBRAM.hex"
    val initFilePath = FPGAMSHR.outputDir + "/FRQBRAM.hex"
    val file = new File(initFilePath)
    val bw = new BufferedWriter(new FileWriter(file))
    val rowAddrWidthHex = scala.math.ceil(rowAddrWidth.toDouble / 4).toInt
    val formatString = s"%0${rowAddrWidthHex}x"
    for(addr <- 0 until memDepth) {
        bw.write(formatString.format(addr) + "\n")
    }
    bw.close()

    val bramQueue = Module(new BRAMQueue(rowAddrWidth, memDepth, memDepth, almostEmptyMargin, initFilePath))
    io.enq <> bramQueue.io.enq
    io.deq <> bramQueue.io.deq
    io.count := bramQueue.io.count
    io.almostEmpty := bramQueue.io.almostEmpty
}

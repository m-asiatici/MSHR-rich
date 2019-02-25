package fpgamshr.reqhandler.traditional

import chisel3._
import fpgamshr.interfaces._
import fpgamshr.util._
import chisel3.util._
import fpgamshr.profiling._

object SubentryBufferTraditional {
    val numEntriesPerRow = 4
    val rowAddrWidth = 8
    val idWidth = 22
    val memDataWidth = 512
    val reqDataWidth = 32

    val inputQueuesDepth = 32
}

/* Differences from full SubentryBuffer:
 - entries stored in registers instead of BRAM
 - fixed maximum number of entries per rowAddr (numEntriesPerRow)
 - the index of the new entry is already given in lastValidIdx together with the entry:
   it is up to the MSHR to keep track of the number of used load buffer entries for a given rowAddr
 - one cycle latency
 - if allocateEntry = false (=deallocation) but additionalEntryValid = true, the entry
   field of the TraditionalMSHRToLdBufIO is taken as additional entry to be sent to the
   response generator, which will have to handle numEntriesPerRow+1 requests in parallel.
 */
class SubentryBufferTraditional(idWidth: Int=SubentryBufferTraditional.idWidth, memDataWidth: Int=SubentryBufferTraditional.memDataWidth, reqDataWidth: Int=SubentryBufferTraditional.reqDataWidth, rowAddrWidth: Int=SubentryBufferTraditional.rowAddrWidth, numEntriesPerRow: Int=SubentryBufferTraditional.numEntriesPerRow) extends Module {
    require(isPow2(memDataWidth / reqDataWidth))
    require(numEntriesPerRow > 0)
    require(isPow2(numEntriesPerRow))
    val offsetWidth = log2Ceil(memDataWidth / reqDataWidth)
    val memType = new LdBufRowTraditional(offsetWidth, idWidth, numEntriesPerRow)
    val memWidth = memType.getWidth
    val memDepth = 1 << rowAddrWidth
    val inputQueuesDepth = SubentryBufferTraditional.inputQueuesDepth
    val entryIdxWidth = log2Ceil(numEntriesPerRow - 1)
    val totalEntries = memDepth * numEntriesPerRow
    val io = IO(new Bundle {
        val in = DecoupledIO(new TraditionalMSHRToLdBufIO(offsetWidth, idWidth, dataWidth=memDataWidth, rowAddrWidth=rowAddrWidth, entryIdxWidth)).flip
        val respGenOut = DecoupledIO(new RespGenIO(memDataWidth, offsetWidth, idWidth, numEntriesPerRow + 1))
        val axiProfiling = new AXI4LiteReadOnlyProfiling(Profiling.dataWidth, Profiling.regAddrWidth)
    })

    val inputQueue = Module(new Queue(io.in.bits.cloneType, inputQueuesDepth))
    inputQueue.io.enq <> io.in
    /* To avoid possible problems down the road... */
    inputQueue.io.enq.bits.opType.allocateRow := io.in.bits.opType.allocateRow & io.in.bits.opType.allocateEntry

    val subentryBuffers = Reg(Vec(memDepth, memType))
    for(row <- 0 until memDepth) {
        for(col <- 0 until numEntriesPerRow) {
            when(inputQueue.io.deq.valid & inputQueue.io.deq.bits.opType.allocateEntry & inputQueue.io.deq.bits.rowAddr === row.U & Mux(inputQueue.io.deq.bits.opType.allocateRow, inputQueue.io.deq.bits.lastValidIdx, inputQueue.io.deq.bits.lastValidIdx + 1.U) === col.U) {
                subentryBuffers(row).entries(col) := inputQueue.io.deq.bits.entry
            }
        }
    }

    val currRow = MuxLookup(inputQueue.io.deq.bits.rowAddr, subentryBuffers(0), (0 until memDepth).map(i => (i.U -> subentryBuffers(i))))
    io.respGenOut.valid := inputQueue.io.deq.valid & ~inputQueue.io.deq.bits.opType.allocateEntry
    io.respGenOut.bits.data := inputQueue.io.deq.bits.data
    for(i <- 0 until numEntriesPerRow) {
        io.respGenOut.bits.entries(i) := currRow.entries(i)
    }
    /* If additionalEntryValid, the entry field of the input port contains an
     * additional request to be served, on top of those that are in the load buffer.
     * (see TraditionalMSHR for more comments on this feature). */
    io.respGenOut.bits.entries(numEntriesPerRow) := inputQueue.io.deq.bits.entry
    io.respGenOut.bits.lastValidIdx := Mux(inputQueue.io.deq.bits.additionalEntryValid, numEntriesPerRow.U, inputQueue.io.deq.bits.lastValidIdx)
    inputQueue.io.deq.ready := io.respGenOut.ready | inputQueue.io.deq.bits.opType.allocateEntry

    if(Profiling.enable) {
      val (snapshotUsedEntries, currentlyUsedEntries) = ProfilingUpDownCounter(enUp=(inputQueue.io.deq.valid & inputQueue.io.deq.ready & inputQueue.io.deq.bits.opType.allocateEntry), enDown=(inputQueue.io.deq.valid & inputQueue.io.deq.ready & ~inputQueue.io.deq.bits.opType.allocateEntry), io.axiProfiling)
      val maxUsedEntries = ProfilingMax(currentlyUsedEntries, io.axiProfiling)
      val currentlyUsedRows = 1.U
      val maxUsedRows = 1.U
      val rowsWithNextRowPtrValid = 0.U
      val cyclesInFwStall = 0.U
      val cyclesRespGenStall = ProfilingCounter(io.respGenOut.valid & ~io.respGenOut.ready, io.axiProfiling)
      val cyclesWritePipelineStall = 0.U
      /* usedEntriesHistogram(i) = num cycles with at least 2 ^ i used entries */
      val usedEntriesHistogram = (0 until log2Ceil(totalEntries)).map(i => ProfilingCounter(currentlyUsedEntries(i) >= (1 << i).U, io.axiProfiling))

      val profilingRegisters = Array(snapshotUsedEntries, maxUsedEntries, currentlyUsedRows, maxUsedRows, rowsWithNextRowPtrValid,
                                     cyclesInFwStall, cyclesRespGenStall, cyclesWritePipelineStall) ++ usedEntriesHistogram
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

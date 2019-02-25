package fpgamshr.reqhandler

import chisel3._
import chisel3.util._
import fpgamshr.interfaces._
import fpgamshr.util._
import fpgamshr.profiling._

object ResponseGenerator {
  val memDataWidth = 512
  val reqDataWidth = 32
  val numEntriesPerRow = 4
  val rowAddrWidth = 8
  val idWidth = 10
  val inputQueuesDepth = 32

  val numOutputPorts = 2
}

class ResponseGenerator(idWidth: Int=ResponseGenerator.idWidth, memDataWidth: Int=ResponseGenerator.memDataWidth, reqDataWidth: Int=ResponseGenerator.reqDataWidth, numEntriesPerRow: Int=ResponseGenerator.numEntriesPerRow, numOutputPorts: Int=ResponseGenerator.numOutputPorts) extends Module {
  require(isPow2(memDataWidth / reqDataWidth))
  require(numEntriesPerRow > 0)
  require(numOutputPorts > 0)
  require(isPow2(numEntriesPerRow))
  require(isPow2(numOutputPorts))
  require(numEntriesPerRow >= numOutputPorts)
  val offsetWidth = log2Ceil(memDataWidth / reqDataWidth)
  val maxOffset = (1 << offsetWidth) - 1
  val inputQueuesDepth = ResponseGenerator.inputQueuesDepth
  val io = IO(new Bundle{
    val in = DecoupledIO(new RespGenIO(memDataWidth, offsetWidth, idWidth, numEntriesPerRow)).flip
    val outs = Vec(DecoupledIO(new DataIdIO(reqDataWidth, idWidth)), numOutputPorts)
    val axiProfiling = new AXI4LiteReadOnlyProfiling(Profiling.dataWidth, Profiling.regAddrWidth)
  })

  /* Input queue */
  val inputQueue = Module(new Queue(new RespGenIO(memDataWidth, offsetWidth, idWidth, numEntriesPerRow), inputQueuesDepth))
  inputQueue.io.enq <> io.in

  /* Control signals (written by the FSM) */
  /* Enable currentEntryIndex counter */
  val entryIndexEnCount = Wire(Bool())
  /* Load new value in currentEntryIndex counter */
  val entryIndexLoad = Wire(Bool())
  /* The current set of output data is the last one, consume it from the queue */
  val responseDone = Wire(Bool())
  /* The current set of output data is valid */
  val outValid = Wire(Bool())
  val outReady = Wire(Bool())
  /* It is not the first iteration, so all the currently selected entries are valid */
  val notFirst = Wire(Bool())
  /* A new response is available: trigger the FSM */
  val responseStart = inputQueue.io.deq.valid
  inputQueue.io.deq.ready := responseDone

  /* Datapath */
  val currRowEntries = inputQueue.io.deq.bits.entries
  val currRowData = inputQueue.io.deq.bits.data
  val currRowLastValidEntry = inputQueue.io.deq.bits.lastValidIdx
  /* Only the high part, the one that may be loaded in the currentEntryIndex counter */
  val currRowLastValidEntryH = Wire(UInt((log2Ceil(numEntriesPerRow) - log2Ceil(numOutputPorts)).W))
  if (numOutputPorts < numEntriesPerRow)
  {
    currRowLastValidEntryH := currRowLastValidEntry(log2Ceil(numEntriesPerRow)-1, log2Ceil(numOutputPorts))
  }
  else
  {
    currRowLastValidEntryH := 0.U(1.W)
  }

  val entrySelectionMuxNumInputs = numEntriesPerRow / numOutputPorts

  val currentEntryIndex = ExclusiveUpDownSaturatingCounter(
    maxVal=entrySelectionMuxNumInputs-1,
    upDownN=false.B,
    en=entryIndexEnCount,
    load=entryIndexLoad,
    loadValue=currRowLastValidEntryH-1.U
  )

  val currentEntries = Wire(Vec(new LdBufEntry(offsetWidth, idWidth), numOutputPorts))
  val entryMuxMappings = (0 until numOutputPorts).map(outPort => (0 until entrySelectionMuxNumInputs).map(inPort => (inPort.U -> currRowEntries(outPort + inPort * numOutputPorts))))
  val dataMuxMappings = (0 until numOutputPorts).map(outPort => (0 to maxOffset).map(offset => (offset.U -> currRowData((offset + 1) * reqDataWidth - 1, offset * reqDataWidth))))
  val eagerFork = Module(new EagerFork(Bool(), numOutputPorts))
  eagerFork.io.in.valid := outValid
  outReady := eagerFork.io.in.ready
  for(i <- 0 until numOutputPorts) {
    currentEntries(i) := MuxLookup(Mux(notFirst, currentEntryIndex, currRowLastValidEntryH), currRowEntries(0), entryMuxMappings(i))
    io.outs(i).bits.data := MuxLookup(currentEntries(i).offset, currRowData(reqDataWidth-1, 0), dataMuxMappings(i))
    io.outs(i).bits.id := currentEntries(i).id
    if (numOutputPorts > 1) {
      // io.outs(i).valid := outValid & (notFirst | (i.U <= currRowLastValidEntry(log2Ceil(numOutputPorts)-1, 0)))
      io.outs(i).valid := eagerFork.io.out(i).valid & (notFirst | (i.U <= currRowLastValidEntry(log2Ceil(numOutputPorts)-1, 0)))
      eagerFork.io.out(i).ready := io.outs(i).ready | ~(notFirst | (i.U <= currRowLastValidEntry(log2Ceil(numOutputPorts)-1, 0)))
    } else {
      io.outs(i).valid := eagerFork.io.out(i).valid
      eagerFork.io.out(i).ready := io.outs(i).ready
      // io.outs(i).valid := outValid
    }
  }

  /* FSM */
  val sIdle :: sScan :: Nil = Enum(2)
  val state = Reg(init=sIdle)

  switch(state) {
    is (sIdle) {
      when (responseStart & (currRowLastValidEntryH != 0.U) & outReady) {
        state := sScan
      }
    }
    is (sScan) {
      when (outReady & (currentEntryIndex === 0.U)) {
          state := sIdle
      }
    }
  }

  entryIndexEnCount := false.B
  entryIndexLoad := false.B
  responseDone := false.B
  outValid := false.B
  notFirst := false.B

  switch(state) {
    is (sIdle) {
      when (responseStart) {
        outValid := true.B
        when (outReady) {
          when (currRowLastValidEntryH === 0.U) {
            responseDone := true.B
          } .otherwise {
            entryIndexLoad := true.B
          }
        }
      }
    }
    is (sScan) {
      entryIndexEnCount := true.B
      outValid := true.B
      notFirst := true.B
      when (outReady) {
        when (currentEntryIndex === 0.U) {
          responseDone := true.B
        }
      } .otherwise {
        entryIndexEnCount := false.B
      }
    }
  }

  if(Profiling.enable) {
      val acceptedInputsCount = ProfilingCounter(inputQueue.io.deq.valid & inputQueue.io.deq.ready, io.axiProfiling)
      /* One counter per output port, we only care about the total sum */
      val responsesSentOutCount = io.outs.map(out => ProfilingCounter(out.valid & out.ready, io.axiProfiling)).reduce(_ + _)
      val cyclesOutNotReady = ProfilingCounter(outValid & ~outReady, io.axiProfiling)
      val profilingRegisters = Array(acceptedInputsCount, responsesSentOutCount, cyclesOutNotReady)
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

/* The number of outputs is fixed to 1 but can numEntriesPerRow does not have
 * to be a power of two. For the rest, equivalent to ResponseGenerator. */
class ResponseGeneratorOneOutputArbitraryEntriesPerRow(idWidth: Int=ResponseGenerator.idWidth, memDataWidth: Int=ResponseGenerator.memDataWidth, reqDataWidth: Int=ResponseGenerator.reqDataWidth, numEntriesPerRow: Int=ResponseGenerator.numEntriesPerRow) extends Module {
    require(isPow2(memDataWidth / reqDataWidth))
    require(numEntriesPerRow > 0)
    val offsetWidth = log2Ceil(memDataWidth / reqDataWidth)
    val maxOffset = (1 << offsetWidth) - 1
    val inputQueuesDepth = ResponseGenerator.inputQueuesDepth
    val io = IO(new Bundle{
      val in = DecoupledIO(new RespGenIO(memDataWidth, offsetWidth, idWidth, numEntriesPerRow)).flip
      val out = DecoupledIO(new DataIdIO(reqDataWidth, idWidth))
      val axiProfiling = new AXI4LiteReadOnlyProfiling(Profiling.dataWidth, Profiling.regAddrWidth)
    })

    /* Input queue */
    val inputQueue = Module(new Queue(new RespGenIO(memDataWidth, offsetWidth, idWidth, numEntriesPerRow), inputQueuesDepth))
    inputQueue.io.enq <> io.in

    /* Control signals (written by the FSM) */
    /* Enable currentEntryIndex counter */
    val entryIndexEnCount = Wire(Bool())
    /* Load new value in currentEntryIndex counter */
    val entryIndexLoad = Wire(Bool())
    /* The current set of output data is the last one, consume it from the queue */
    val responseDone = Wire(Bool())
    /* The current set of output data is valid */
    val outValid = Wire(Bool())
    val outReady = Wire(Bool())
    /* It is not the first iteration, so all the currently selected entries are valid */
    val notFirst = Wire(Bool())
    /* A new response is available: trigger the FSM */
    val responseStart = inputQueue.io.deq.valid
    inputQueue.io.deq.ready := responseDone

    /* Datapath */
    val currRowEntries = inputQueue.io.deq.bits.entries
    val currRowData = inputQueue.io.deq.bits.data
    val currRowLastValidEntry = inputQueue.io.deq.bits.lastValidIdx

    val entrySelectionMuxNumInputs = numEntriesPerRow
    val currentEntryIndex = ExclusiveUpDownSaturatingCounter(
      maxVal=entrySelectionMuxNumInputs-1,
      upDownN=false.B,
      en=entryIndexEnCount,
      load=entryIndexLoad,
      loadValue=currRowLastValidEntry-1.U
    )

    val currentEntry = Wire(new LdBufEntry(offsetWidth, idWidth))
    val entryMuxMappings = (0 until entrySelectionMuxNumInputs).map(inPort => (inPort.U -> currRowEntries(inPort)))
    val dataMuxMappings = (0 to maxOffset).map(offset => (offset.U -> currRowData((offset + 1) * reqDataWidth - 1, offset * reqDataWidth)))
    io.out.bits.data := MuxLookup(currentEntry.offset, currRowData(reqDataWidth-1, 0), dataMuxMappings)
    io.out.bits.id := currentEntry.id
    outReady := io.out.ready
    io.out.valid := outValid
    currentEntry := MuxLookup(Mux(notFirst, currentEntryIndex, currRowLastValidEntry), currRowEntries(0), entryMuxMappings)

    /* FSM */
    val sIdle :: sScan :: Nil = Enum(2)
    val state = Reg(init=sIdle)

    switch(state) {
      is (sIdle) {
        when (responseStart & (currRowLastValidEntry != 0.U) & outReady) {
          state := sScan
        }
      }
      is (sScan) {
        when (outReady & (currentEntryIndex === 0.U)) {
            state := sIdle
        }
      }
    }

    entryIndexEnCount := false.B
    entryIndexLoad := false.B
    responseDone := false.B
    outValid := false.B
    notFirst := false.B

    switch(state) {
      is (sIdle) {
        when (responseStart) {
          outValid := true.B
          when (outReady) {
            when (currRowLastValidEntry === 0.U) {
              responseDone := true.B
            } .otherwise {
              entryIndexLoad := true.B
            }
          }
        }
      }
      is (sScan) {
        entryIndexEnCount := true.B
        outValid := true.B
        notFirst := true.B
        when (outReady) {
          when (currentEntryIndex === 0.U) {
            responseDone := true.B
          }
        } .otherwise {
          entryIndexEnCount := false.B
        }
      }
    }
    if(Profiling.enable) {
        val acceptedInputsCount = ProfilingCounter(inputQueue.io.deq.valid & inputQueue.io.deq.ready, io.axiProfiling)
        val responsesSentOutCount = ProfilingCounter(io.out.valid & io.out.ready, io.axiProfiling)
        val cyclesOutNotReady = ProfilingCounter(io.out.valid & ~io.out.ready, io.axiProfiling)
        val profilingRegisters = Array(acceptedInputsCount, responsesSentOutCount, cyclesOutNotReady)
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

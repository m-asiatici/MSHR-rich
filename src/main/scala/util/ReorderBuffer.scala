package fpgamshr.util

import chisel3._
import chisel3.util._
import fpgamshr.interfaces._
import fpgamshr.profiling._

import scala.collection.mutable.ArrayBuffer

object ReorderBufferAXI {
    val addrWidth = 32
    val dataWidth = 32
    val idWidth = 7

    def apply(in: AXI4FullReadOnly[UInt]) : AXI4FullReadOnly[UInt] = {
        val buffer = Module(new ReorderBufferAXI(in.ARADDR.getWidth, in.RDATA.getWidth, in.ARID.getWidth))
        buffer.io.in <> in
        buffer.io.out
    }
}

class ReorderBufferIO(addrWidth: Int, dataWidth: Int, inputIdWidth: Int, outputIdWidth: Int) extends Bundle {
  val in = new AXI4FullReadOnly(UInt(dataWidth.W), addrWidth, inputIdWidth)
  val out = new AXI4FullReadOnly(UInt(dataWidth.W), addrWidth, outputIdWidth).flip
  val axiProfiling = new AXI4LiteReadOnlyProfiling(Profiling.dataWidth, Profiling.regAddrWidth + Profiling.subModuleAddrWidth)
  // val clock2x = Input(Clock())
  override def cloneType = (new ReorderBufferIO(addrWidth, dataWidth, inputIdWidth, outputIdWidth)).asInstanceOf[this.type]
}

class BaseReorderBufferAXI(addrWidth: Int, dataWidth: Int, inputIdWidth: Int, outputIdWidth: Int) extends Module {
  val io=IO(new ReorderBufferIO(addrWidth, dataWidth, inputIdWidth, outputIdWidth))
}

class DummyReorderBufferAXI(addrWidth: Int=ReorderBufferAXI.addrWidth, dataWidth: Int=ReorderBufferAXI.dataWidth, idWidth: Int=ReorderBufferAXI.idWidth) extends BaseReorderBufferAXI(addrWidth, dataWidth, idWidth, idWidth) {
  io.in <> io.out
  if(Profiling.enable) {
    //val currentlyUsedEntries = ProfilingUpDownCounter(enUp=(elasticBuffer0.io.in.valid & elasticBuffer0.io.in.ready), enDown=(io.respGenOut.valid & io.respGenOut.ready), io.axiProfiling)
    val currentlyUsedEntries = 0.U
    val maxUsedEntries = 0.U
    val receivedRequestsCount = ProfilingCounter(io.in.ARVALID & io.in.ARREADY, io.axiProfiling)
    val receivedResponsesCount = ProfilingCounter(io.out.RVALID & io.out.RREADY, io.axiProfiling)
    val sentResponsesCount = receivedResponsesCount
    val cyclesFull = 0.U
    val cyclesReqsInStalled = ProfilingCounter(io.in.ARVALID & ~io.in.ARREADY, io.axiProfiling)
    val cyclesReqsOutStalled = cyclesReqsInStalled
    val cyclesRespOutStalled = ProfilingCounter(io.out.RVALID & ~io.out.RREADY, io.axiProfiling)

    val profilingRegisters = ArrayBuffer(receivedRequestsCount, receivedResponsesCount, currentlyUsedEntries, maxUsedEntries,
      sentResponsesCount, cyclesFull, cyclesReqsInStalled, cyclesReqsOutStalled, cyclesRespOutStalled)// ++ usedEntriesHistogram

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

/* WARNING: responses must come at least 3 cycles after the respective request have been sent out from io.out.
 * This is due to the current implementation of the 2W-1R memory, with no forwarding of stores in flight:
 * the store due to the request being sent (valid = 0) must be committed before the response (valid = 1) comes back.
 * If this becomes a problem, implement forwarding paths from previous writes across all ports. */
class ReorderBufferAXI(addrWidth: Int=ReorderBufferAXI.addrWidth, dataWidth: Int=ReorderBufferAXI.dataWidth, idWidth: Int=ReorderBufferAXI.idWidth) extends BaseReorderBufferAXI(addrWidth, dataWidth, 0, idWidth) {

    val numIds = (1 << idWidth)

    /* Input address EB (between ROB and accelerator) */
    val inputAddrEb = Module(new ElasticBuffer(UInt(addrWidth.W)))
    inputAddrEb.io.in.valid := io.in.ARVALID
    inputAddrEb.io.in.bits  := io.in.ARADDR
    io.in.ARREADY := inputAddrEb.io.in.ready

    /* Output data EB (between ROB and accelerator) */
    val inputDataEb = Module(new ElasticBuffer(UInt(dataWidth.W)))
    io.in.RVALID := inputDataEb.io.out.valid
    io.in.RDATA := inputDataEb.io.out.bits
    inputDataEb.io.out.ready := io.in.RREADY

    /* Counters */
    val headCounterEn = Wire(Bool())
    val headCounter = Counter(headCounterEn, numIds)._1
    val headCounterCommittedVec = Wire(Vec(4, ValidIO(headCounter.cloneType)))
    headCounterCommittedVec(0).bits := headCounter
    headCounterCommittedVec(0).valid := headCounterEn
    for(i <- 1 until 4) {
        headCounterCommittedVec(i).bits := RegEnable(headCounterCommittedVec(i-1).bits, enable=headCounterCommittedVec(i-1).valid, init=((1 << idWidth) - 1).U)
        headCounterCommittedVec(i).valid := RegNext(headCounterCommittedVec(i-1).valid, init=false.B)
    }
    val headCounterCommitted = headCounterCommittedVec(3).bits
    /* tailCounter = actual tail pointer (oldest ID that was sent out and not received back yet) */
    val tailCounter = RegInit(0.U(idWidth.W))
    /* tailAddrCounter = address that is given to the valid and data memories
    * Can speculatively advance past the tail counter as we try to read the two addresses past the tail counter,
    * in case they are valid - if not, tailAddrCounter will just revert to tailCounter. */
    val tailAddrCounter = RegInit(0.U(idWidth.W))
    /* Address of the data and valid currently on the output buffer of the respective BRAM */
    val currentDataAddress = RegEnable(RegEnable(tailAddrCounter, enable=inputDataEb.io.in.ready), enable=inputDataEb.io.in.ready)
    /* Address of the data just read from the BRAM. Used to control the valid bit: it will be raised only if
     * currentDataAddress != previousDataAddress, otherwise the same data will be received twice. */
    val previousDataAddress = RegEnable(currentDataAddress, enable=inputDataEb.io.in.ready)

    /* Memories */
    val validMemory = Module(new TwoWriteOneReadPortBRAM(idWidth, 1))
    val dataMemory = Module(new XilinxSimpleDualPortNoChangeBRAM(dataWidth, numIds))
    dataMemory.io.clock := clock
    dataMemory.io.reset := reset
    // validMemory.io.clock2x := io.clock2x

    /* Address channel */
    val full = headCounter === tailCounter - 1.U
    headCounterEn := inputAddrEb.io.out.valid & ~full & io.out.ARREADY
    io.out.ARVALID := inputAddrEb.io.out.valid & ~full
    inputAddrEb.io.out.ready := ~full & io.out.ARREADY
    io.out.ARADDR := inputAddrEb.io.out.bits
    io.out.ARID := headCounter

    val validReadIn = Wire(Bool())
    /* The first time a valid data is read back from the buffer, the FSM will
     * speculatively try to read the following addresses, even before receiving the
     * data read. If the following entry in the buffer is actually not valid, we need
     * to revert all the changes that we made speculatively (incrementing tailAddrCounter)
     * and to ignore the data that will be returned by the memory pipeline until the pipeline
     * gets empty again. To keep track of the validity of the data read from memory,
     * we use validReadOut, which contains a delayed copy of validReadIn, set
     * any time we perform a read that we are interested in. Also, validReadOut
     * proceed at the same pace as the memory pipeline.
     */
    val validReadReset = Wire(Bool())
    val validReadOut = RegEnable(RegEnable(validReadIn & ~validReadReset, enable=inputDataEb.io.in.ready) & ~validReadReset, enable=inputDataEb.io.in.ready)
    validMemory.io.rden := inputDataEb.io.in.ready
    validMemory.io.rdaddr := tailAddrCounter
    /* Write port A: writing 0 when a new ID is attributed */
    validMemory.io.dina := 0.U
    validMemory.io.wea := headCounterEn
    validMemory.io.wraddra := headCounter
    /* Write port B: writing 1 when a new data is received */
    validMemory.io.dinb := 1.U
    validMemory.io.web := io.out.RVALID
    validMemory.io.wraddrb := io.out.RID
    /* Data memory, write port */
    dataMemory.io.dina := io.out.RDATA
    dataMemory.io.wea := io.out.RVALID
    dataMemory.io.addra := io.out.RID
    /* Data memory, read port */
    dataMemory.io.addrb := tailAddrCounter
    dataMemory.io.enb := inputDataEb.io.in.ready
    dataMemory.io.regceb := inputDataEb.io.in.ready
    inputDataEb.io.in.bits := dataMemory.io.doutb

    io.out.RREADY := true.B

    /* Read FSM */
    val sEmpty :: sWaitHC :: sWaitValid :: sRead :: Nil = Enum(4)
    val state = RegInit(init=sEmpty)
    /* The FSM freezes if ~inputDataEb.io.in.ready. */
    switch(state) {
        /* Empty buffer: tailCounter = headCounter, headCounterCommitted = headCounter - 1
         * Leave when tailCounter != headCounter */
        is(sEmpty) {
            when(tailCounter != headCounter) {
                state := sWaitHC
            }
        }
        /* Wait until headCounterCommitted advances up to tailCounter, which means that the
         * values that we read from the tail address are valid. */
        is(sWaitHC) {
            when(tailCounter === headCounterCommitted) {
                state := sWaitValid
            }

        }
        /* Wait until the data at the tail address becomes valid (= is received from memory) */
        is(sWaitValid) {
            when(inputDataEb.io.in.ready & validReadOut & validMemory.io.dout === 1.U) {
                when(currentDataAddress === headCounter - 1.U) {
                    state := sEmpty
                } .otherwise {
                    state := sRead
                }
            }
        }
        /* Remain here as long as we read valid data, or the buffer does not become empty. */
        is(sRead) {
            when(inputDataEb.io.in.ready) {
                when(validMemory.io.dout === 1.U) {
                    when(currentDataAddress === headCounter - 1.U) {
                        state := sEmpty
                    }
                } .otherwise {
                    state := sWaitValid
                }
            }
        }
    }

    validReadReset := false.B
    validReadIn := false.B
    inputDataEb.io.in.valid := false.B
    switch(state) {
        is(sEmpty) {
            tailAddrCounter := tailCounter
            validReadReset := true.B
        }
        is(sWaitHC) {
            tailAddrCounter := tailCounter
            validReadReset := true.B
        }
        is(sWaitValid) {
            validReadIn := true.B
            when(inputDataEb.io.in.ready) {
                /* We try to speculatively read past tail address but we make sure never
                 * to go ahead headCounterCommitted, otherwise the valid bit may not have been updated yet. */
                when(tailAddrCounter != headCounterCommitted) {
                    tailAddrCounter := tailAddrCounter + 1.U
                }
                when(validReadOut) {
                    when(validMemory.io.dout === 1.U) {
                        /* The data at the tail address is valid: we send it out and move to sRead */
                        tailCounter := currentDataAddress + 1.U
                        inputDataEb.io.in.valid := true.B
                    } .otherwise {
                        /* The data at the tail address is NOT valid: we bring back tailAddrCounter and keep waiting */
                        tailAddrCounter := tailCounter
                        validReadReset := true.B
                    }
                }
            }
        }
        is(sRead) {
            when(inputDataEb.io.in.ready) {
                when(validMemory.io.dout === 1.U) {
                    when(currentDataAddress != previousDataAddress) {
                        inputDataEb.io.in.valid := true.B
                    }
                    tailCounter := currentDataAddress + 1.U
                    when(tailAddrCounter != headCounterCommitted) {
                        tailAddrCounter := tailAddrCounter + 1.U
                    }
                    when(currentDataAddress === headCounter - 1.U) {
                        /* This is the last data in the buffer, we prepare to move to sEmpty */
                        tailAddrCounter := tailCounter
                        validReadReset := true.B
                    }
                } .otherwise {
                    /* The data at the tail address is not valid, prepare to move to sWaitValid */
                    tailAddrCounter := tailCounter
                    validReadReset := true.B
                }
            }
        }
    }
    io.out.ARPROT := 0.U
    io.in.RLAST := true.B
    io.in.RRESP := 0.U
    io.out.ARBURST := 0.U
    io.out.ARLEN := 0.U
    io.out.ARLOCK := 0.U
    io.out.ARSIZE := log2Ceil(dataWidth / 8).U
    io.out.ARCACHE := 0.U
    io.in.RID := 0.U /* TODO: return same ID that was sent */
    if(Profiling.enable) {
      //val currentlyUsedEntries = ProfilingUpDownCounter(enUp=(elasticBuffer0.io.in.valid & elasticBuffer0.io.in.ready), enDown=(io.respGenOut.valid & io.respGenOut.ready), io.axiProfiling)
      val currentlyUsedEntries = RegEnable((headCounter - tailCounter)(headCounter.getWidth-1, 0), enable=io.axiProfiling.snapshot)
      val maxUsedEntries = ProfilingMax((headCounter - tailCounter)(headCounter.getWidth-1, 0), io.axiProfiling)
      val receivedRequestsCount = ProfilingCounter(headCounterEn, io.axiProfiling)
      val receivedResponsesCount = ProfilingCounter(io.out.RVALID, io.axiProfiling)
      val sentResponsesCount = ProfilingCounter(io.in.RVALID & io.in.RREADY, io.axiProfiling)
      val cyclesFullStalled = ProfilingCounter(io.in.ARVALID & full, io.axiProfiling)
      val cyclesReqsInStalled = ProfilingCounter(io.in.ARVALID & ~io.in.ARREADY, io.axiProfiling)
      val cyclesReqsOutStalled = ProfilingCounter(io.out.ARVALID & ~io.out.ARREADY, io.axiProfiling)
      val cyclesRespOutStalled = ProfilingCounter(io.out.RVALID & ~io.out.RREADY, io.axiProfiling)

      val profilingRegisters = ArrayBuffer(receivedRequestsCount, receivedResponsesCount, currentlyUsedEntries, maxUsedEntries,
        sentResponsesCount, cyclesFullStalled, cyclesReqsInStalled, cyclesReqsOutStalled, cyclesRespOutStalled)// ++ usedEntriesHistogram

      val innerAxiProfiling = Wire(new AXI4LiteReadOnlyProfiling(Profiling.dataWidth, Profiling.regAddrWidth))
      val profilingInterface = ProfilingInterface(innerAxiProfiling.axi, Vec(profilingRegisters))
      innerAxiProfiling.axi.RDATA := profilingInterface.bits
      innerAxiProfiling.axi.RVALID := profilingInterface.valid
      profilingInterface.ready := innerAxiProfiling.axi.RREADY
      innerAxiProfiling.axi.RRESP := 0.U

      val dummyAxiProfiling = Wire(new AXI4LiteReadOnlyProfiling(Profiling.dataWidth, Profiling.regAddrWidth))
      dummyAxiProfiling.axi.RDATA  := DontCare
      dummyAxiProfiling.axi.RRESP  := 0.U
      dummyAxiProfiling.axi.RVALID := false.B
      dummyAxiProfiling.axi.ARREADY := true.B

      val subModulesProfilingInterfaces = Array(innerAxiProfiling) ++ Seq.fill((1 << Profiling.subModuleAddrWidth)-1)(dummyAxiProfiling)
      //require(Profiling.subModuleAddrWidth >= log2Ceil(subModulesProfilingInterfaces.length))
      val profilingAddrDecoupledIO = Wire(DecoupledIO(UInt((Profiling.regAddrWidth + Profiling.subModuleAddrWidth).W)))
      //println(s"Profiling.regAddrWidth = ${Profiling.regAddrWidth}; Profiling.subModuleAddrWidth = ${Profiling.subModuleAddrWidth}")
      profilingAddrDecoupledIO.bits := io.axiProfiling.axi.ARADDR
      profilingAddrDecoupledIO.valid := io.axiProfiling.axi.ARVALID
      io.axiProfiling.axi.ARREADY := profilingAddrDecoupledIO.ready
      //println(s"profilingAddrDecoupledIO.bits.getWidth=${profilingAddrDecoupledIO.bits.getWidth}")
      val profilingSelector = ProfilingSelector(profilingAddrDecoupledIO, subModulesProfilingInterfaces, io.axiProfiling.clear, io.axiProfiling.snapshot)
      io.axiProfiling.axi.RDATA := profilingSelector.bits
      io.axiProfiling.axi.RVALID := profilingSelector.valid
      profilingSelector.ready := io.axiProfiling.axi.RREADY
      io.axiProfiling.axi.RRESP := 0.U

      //
      // io.axiProfiling.axi.RDATA := profilingInterface.bits
      // io.axiProfiling.axi.RVALID := profilingInterface.valid
      // profilingInterface.ready := io.axiProfiling.axi.RREADY
      // io.axiProfiling.axi.RRESP := 0.U
  } else {
      io.axiProfiling.axi.ARREADY := false.B
      io.axiProfiling.axi.RVALID := false.B
      io.axiProfiling.axi.RDATA := DontCare
      io.axiProfiling.axi.RRESP := DontCare
  }
}

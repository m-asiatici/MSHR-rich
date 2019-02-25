package fpgamshr.extmemarbiter

import chisel3._
import chisel3.util._
import fpgamshr.util._
import fpgamshr.interfaces._
import fpgamshr.crossbar.{OneWayCrossbar, OneWayCrossbarGeneric}

import java.io.{File, BufferedWriter, FileWriter} // To generate the BRAM initialization files

import scala.collection.mutable.ArrayBuffer

object ExternalMemoryArbiter {
    val memAddrWidth = 32
    val reqAddrWidth = 32
    val memAddrOffset = 0x00000000
    val memDataWidth = 512
    val memIdWidth = 5

    val numReqHandlers = 4

    val bramLatency = 2
}

object InOrderExternalMemoryArbiter {
  val maxInFlightRequests = 128
}

class InOrderExternalMemoryArbiter(reqAddrWidth: Int=ExternalMemoryArbiter.reqAddrWidth, memAddrWidth: Int=ExternalMemoryArbiter.memAddrWidth, memDataWidth: Int=ExternalMemoryArbiter.memDataWidth, memIdWidth: Int=ExternalMemoryArbiter.memIdWidth, numReqHandlers: Int=ExternalMemoryArbiter.numReqHandlers, maxInFlightRequests: Int=InOrderExternalMemoryArbiter.maxInFlightRequests, memAddrOffset: Long=ExternalMemoryArbiter.memAddrOffset) extends ExternalMemoryArbiterBase(reqAddrWidth, memAddrWidth, memDataWidth, memIdWidth, numReqHandlers, 1) {
  val inputArbiter = Module(new ResettableRRArbiter(UInt(tagWidth.W), numReqHandlers))
  for (i <- 0 until numReqHandlers) inputArbiter.io.in(i) <> io.inReq(i)

  val selectedDataAndChosen = Wire(DecoupledIO(new DataAndChosenIO(inputArbiter.io.out.bits.getWidth, inputArbiter.io.chosen.getWidth)))
  selectedDataAndChosen.valid := inputArbiter.io.out.valid
  inputArbiter.io.out.ready := selectedDataAndChosen.ready
  selectedDataAndChosen.bits.data := inputArbiter.io.out.bits
  selectedDataAndChosen.bits.chosen := inputArbiter.io.chosen
  /* This is not really required but we use it in order to make the output irrevocable,
   * something which is apparently required by Xilinx AXI IPs */
  val inputEb = ElasticBuffer(selectedDataAndChosen)
  val fullAddressWithoutOffset = Cat(inputEb.bits.data, inputEb.bits.chosen)
  val memInterfaceManager = Module(new MemoryInterfaceManager(tagWidth + handlerAddrWidth, offsetWidth, memAddrWidth, memDataWidth, memIdWidth, maxInFlightRequests, memAddrOffset))
  memInterfaceManager.io.enq.valid := inputEb.valid
  memInterfaceManager.io.enq.bits := fullAddressWithoutOffset
  inputEb.ready := memInterfaceManager.io.enq.ready
  io.outMem(0).ARVALID := memInterfaceManager.io.outMemAddr.valid
  io.outMem(0).ARADDR  := memInterfaceManager.io.outMemAddr.bits
  memInterfaceManager.io.outMemAddr.ready := io.outMem(0).ARREADY
  memInterfaceManager.io.inMemData.valid := io.outMem(0).RVALID
  memInterfaceManager.io.inMemData.bits := io.outMem(0).RDATA
  io.outMem(0).RREADY := memInterfaceManager.io.inMemData.ready
  io.outMem(0).ARID := 0.U

  val currTag = memInterfaceManager.io.deq.bits.addr(reqAddrWidth - offsetWidth - 1, handlerAddrWidth)
  val oneHotHandlerEnable = if (handlerAddrWidth > 0) UIntToOH(memInterfaceManager.io.deq.bits.addr(handlerAddrWidth - 1, 0)) else 1.U
  for (i <- 0 until numReqHandlers) {
      io.outResp(i).valid := oneHotHandlerEnable(i) & memInterfaceManager.io.deq.valid
      io.outResp(i).bits.data := memInterfaceManager.io.deq.bits.data
      io.outResp(i).bits.addr := currTag
  }
  memInterfaceManager.io.deq.ready := Mux1H(oneHotHandlerEnable, (0 until numReqHandlers).map(i => io.outResp(i).ready)) | ~memInterfaceManager.io.deq.valid
}

class MemoryInterfaceManager(tagWidth: Int, offsetWidth: Int, memAddrWidth: Int, memDataWidth: Int, memIdWidth: Int, maxInFlightRequests: Int, memAddrOffset: Long) extends Module {
  val io=IO(new Bundle{
    val enq = Flipped(DecoupledIO(UInt(tagWidth.W)))
    val outMemAddr = DecoupledIO(UInt(memAddrWidth.W))
    val inMemData = Flipped(DecoupledIO(UInt(memDataWidth.W)))
    val deq = DecoupledIO(new AddrDataIO(tagWidth, memDataWidth))
  })

  val fullAddress = Cat(io.enq.bits, 0.U(offsetWidth.W)) + memAddrOffset.U
  val inFlightAddresses = Module(new BRAMQueue(tagWidth, maxInFlightRequests))
  inFlightAddresses.io.enq.valid := io.enq.valid & io.outMemAddr.ready
  inFlightAddresses.io.enq.bits := io.enq.bits
  io.enq.ready := inFlightAddresses.io.enq.ready & io.outMemAddr.ready
  io.outMemAddr.valid := io.enq.valid & inFlightAddresses.io.enq.ready
  io.outMemAddr.bits := fullAddress

  val rChannelEb = Module(new ElasticBuffer(UInt(memDataWidth.W)))
  rChannelEb.io.in.valid := io.inMemData.valid
  rChannelEb.io.in.bits := io.inMemData.bits
  io.inMemData.ready := rChannelEb.io.in.ready
  io.deq.valid := rChannelEb.io.out.valid
  io.deq.bits.data := rChannelEb.io.out.bits
  io.deq.bits.addr := inFlightAddresses.io.deq.bits
  inFlightAddresses.io.deq.ready := rChannelEb.io.out.valid & io.deq.ready
  rChannelEb.io.out.ready := io.deq.ready & inFlightAddresses.io.deq.valid
}

class ExternalMemoryArbiterBase(reqAddrWidth: Int, memAddrWidth: Int, memDataWidth: Int, memIdWidth: Int, numReqHandlers: Int, numMemoryPorts: Int) extends Module {
  require(isPow2(memDataWidth))
  // require(isPow2(memAddrWidth))
  require(isPow2(numReqHandlers))
  require(numReqHandlers > 0)
  val bitsPerByte = 8
  val offsetWidth = log2Ceil(memDataWidth / bitsPerByte)
  val handlerAddrWidth = log2Ceil(numReqHandlers)
  val tagWidth = reqAddrWidth - handlerAddrWidth - offsetWidth
  val fullTagWidth = reqAddrWidth - offsetWidth
  val numIds = 1 << memIdWidth

  val io = IO(new Bundle{
      val inReq = Flipped(Vec(numReqHandlers, DecoupledIO(UInt(tagWidth.W))))
      val outMem = Flipped(Vec(numMemoryPorts, new AXI4FullReadOnly(UInt(memDataWidth.W), memAddrWidth, memIdWidth)))
      val outResp = Vec(numReqHandlers, DecoupledIO(new AddrDataIO(tagWidth, memDataWidth)))
  })

  io.outMem.foreach(x => {
    x.ARLEN := 0.U
    x.ARSIZE := log2Ceil(ExternalMemoryArbiter.memDataWidth / bitsPerByte).U
    x.ARBURST := 1.U /* FIXED */
    x.ARLOCK := 0.U  /* Normal (not exclusive/locked) access */
    x.ARCACHE := 0.U /* Non-modifiable */
    x.ARPROT := 0.U  /* Unprivileged, secure, data
    * (default used by Vivado HLS) */
    x.ARID := 0.U
  })
}

object ReorderingExternalMemoryArbiter{
  val numBanks = 8
  val ddrColWidthByteAddressed = 10
  val queueDepth = 8
}

// Not used in our ISFPGA19 paper, as its benefit was not clear
class ReorderingExternalMemoryArbiter(reqAddrWidth: Int=ExternalMemoryArbiter.reqAddrWidth, memAddrWidth: Int=ExternalMemoryArbiter.memAddrWidth, memDataWidth: Int=ExternalMemoryArbiter.memDataWidth, memIdWidth: Int=ExternalMemoryArbiter.memIdWidth, numReqHandlers: Int=ExternalMemoryArbiter.numReqHandlers, maxInFlightRequests: Int=InOrderExternalMemoryArbiter.maxInFlightRequests, memAddrOffset: Long=ExternalMemoryArbiter.memAddrOffset, numBanks: Int=ReorderingExternalMemoryArbiter.numBanks, queueDepth: Int=ReorderingExternalMemoryArbiter.queueDepth) extends ExternalMemoryArbiterBase(reqAddrWidth, memAddrWidth, memDataWidth, memIdWidth, numReqHandlers, 1) {
  require(isPow2(numBanks))
  require(numBanks > 0)
  val bankAddrWidth = log2Ceil(numBanks)
  val crossbarAddrWidth = tagWidth + handlerAddrWidth
  val memAddrWidthWithoutOffset = memAddrWidth - offsetWidth
  val ddrColWidthWithoutZeros = ReorderingExternalMemoryArbiter.ddrColWidthByteAddressed - offsetWidth

  /*
  * Input address from inReq:
  * --------------
  * |    tag     |
  * --------------
  * |<-tagWidth->|
  *
  * Addr sent to crossbar:
  * ----------------------------------------
  * |    tag     |   req handler address   |
  * ----------------------------------------
  * |<-tagWidth->|<--log2(numReqHandlers)->|
  * |<----------crossbarAddrWidth--------->|
  *
  * Addr received from crossbar:
  * --------------------------------------------
  * | DDR row addr |        DDR col addr       |
  * --------------------------------------------
  * |              |<-ddrColWidthWithoutZeros->|
  * |<--------memAddrWidthWithoutOffset------->|
  *
  * Full address sent to memory:
  *
  * |<--------------memAddrWidthWithoutOffset-------------->|
  * ---------------------------------------------------------------
  * | DDR row addr |  DDR bank addr  |     DDR col addr     |  0  |
  * ---------------------------------------------------------------
  * |    tag     |   req handler address   |           0          |
  * ---------------------------------------------------------------
  * |<-tagWidth->|<--log2(numReqHandlers)->|<----offsetWidth----->|
  */

  val inReqWithFullAddr = Wire(Vec(numReqHandlers, DecoupledIO(UInt(crossbarAddrWidth.W))))
  for(i <- 0 until numReqHandlers) {
    inReqWithFullAddr(i).valid := io.inReq(i).valid
    io.inReq(i).ready := inReqWithFullAddr(i).ready
    if(numReqHandlers > 1) {
      inReqWithFullAddr(i).bits := Cat(io.inReq(i).bits, i.U(handlerAddrWidth.W))
    } else {
      inReqWithFullAddr(i).bits := io.inReq(i).bits
    }
  }

  val crossbar = Module(new OneWayCrossbar(numReqHandlers, numBanks, crossbarAddrWidth, ddrColWidthWithoutZeros))
  for(i <- 0 until numReqHandlers) {
    crossbar.io.ins(i) <> inReqWithFullAddr(i)
  }
  val crossbarOutAddrWidth = crossbar.io.outs(0).bits.getWidth

  val selectors = Array.fill(numBanks)(Module(new SameRowReadSelector(crossbar.io.outs(0).bits.getWidth, ddrColWidthWithoutZeros, queueDepth)).io)
  val sameRowArbiter = Module(new ResettableRRArbiter(UInt(memAddrWidthWithoutOffset.W), numBanks))
  val validArbiter   = Module(new ResettableRRArbiter(UInt(memAddrWidthWithoutOffset.W), numBanks))
  for(i <- 0 until numBanks) {
    selectors(i).enq <> crossbar.io.outs(i)
    validArbiter.io.in(i).bits := Cat(selectors(i).deq.bits(crossbarOutAddrWidth-1, ddrColWidthWithoutZeros), i.U(bankAddrWidth.W), selectors(i).deq.bits(ddrColWidthWithoutZeros-1, 0))
    validArbiter.io.in(i).valid := selectors(i).deq.valid
    sameRowArbiter.io.in(i).bits := Cat(selectors(i).deq.bits(crossbarOutAddrWidth-1, ddrColWidthWithoutZeros), i.U(bankAddrWidth.W), selectors(i).deq.bits(ddrColWidthWithoutZeros-1, 0))
    sameRowArbiter.io.in(i).valid := selectors(i).deq.valid & ~selectors(i).isNewRow
  }
  val downstreamArbiter = Module(new Arbiter(UInt(memAddrWidthWithoutOffset.W), 2))
  downstreamArbiter.io.in(0) <> sameRowArbiter.io.out
  downstreamArbiter.io.in(1) <> validArbiter.io.out
  for(i <- 0 until numBanks) {
    selectors(i).deq.ready := Mux(downstreamArbiter.io.chosen === 1.U, validArbiter.io.in(i).ready, sameRowArbiter.io.in(i).ready & ~selectors(i).isNewRow)
  }
  val inputEb = ElasticBuffer(downstreamArbiter.io.out)

  val fullAddress = Cat(inputEb.bits, 0.U(offsetWidth.W)) + memAddrOffset.U
  val inFlightAddresses = Module(new BRAMQueue(memAddrWidthWithoutOffset, maxInFlightRequests))
  inFlightAddresses.io.enq.valid := inputEb.valid & io.outMem(0).ARREADY
  inFlightAddresses.io.enq.bits := inputEb.bits
  inputEb.ready := inFlightAddresses.io.enq.ready & io.outMem(0).ARREADY
  io.outMem(0).ARVALID := inputEb.valid & inFlightAddresses.io.enq.ready
  io.outMem(0).ARADDR := fullAddress
  io.outMem(0).ARID := 0.U

  val rChannelEb = Module(new ElasticBuffer(UInt(memDataWidth.W)))
  rChannelEb.io.in.valid := io.outMem(0).RVALID
  rChannelEb.io.in.bits := io.outMem(0).RDATA
  io.outMem(0).RREADY := rChannelEb.io.in.ready

  val targetOutputReady = Wire(Bool())
  rChannelEb.io.out.ready := targetOutputReady & inFlightAddresses.io.deq.valid
  inFlightAddresses.io.deq.ready := rChannelEb.io.out.valid & targetOutputReady
  val currTag = inFlightAddresses.io.deq.bits(reqAddrWidth - offsetWidth - 1, handlerAddrWidth)
  val oneHotHandlerEnable = if (handlerAddrWidth > 0) UIntToOH(inFlightAddresses.io.deq.bits(handlerAddrWidth - 1, 0)) else 1.U
  for (i <- 0 until numReqHandlers) {
      io.outResp(i).valid := oneHotHandlerEnable(i) & rChannelEb.io.out.valid
      io.outResp(i).bits.data := rChannelEb.io.out.bits
      io.outResp(i).bits.addr := currTag
  }
  targetOutputReady := Mux1H(oneHotHandlerEnable, (0 until numReqHandlers).map(i => io.outResp(i).ready)) | ~rChannelEb.io.out.valid
}

class SameRowReadSelector(addrWidth: Int, colWidth: Int, queueDepth: Int) extends Module {
  val io=IO(new Bundle{
    val enq = Flipped(DecoupledIO(UInt(addrWidth.W)))
    val deq = DecoupledIO(UInt(addrWidth.W))
    val isNewRow = Output(Bool())
  })

  def getRow(addr: UInt) : UInt = addr(addrWidth - 1, colWidth)

  val emptyEntry = Wire(ValidIO(io.enq.bits.cloneType))
  emptyEntry.valid := false.B
  emptyEntry.bits  := DontCare
  val memory = RegInit(Vec(Seq.fill(queueDepth)(emptyEntry)))

  val sameRowArbiter = Module(new ResettableRRArbiter(io.enq.bits.cloneType, queueDepth))
  val validArbiter   = Module(new ResettableRRArbiter(io.enq.bits.cloneType, queueDepth))
  val emptyDataAndChosen = Wire(ValidIO(new DataAndChosenIO(addrWidth, 1)))
  emptyDataAndChosen.valid := false.B
  emptyDataAndChosen.bits  := DontCare
  val lastRequestSent = RegInit(emptyDataAndChosen)
  for(i <- 0 until queueDepth) {
    sameRowArbiter.io.in(i).valid := memory(i).valid & (getRow(memory(i).bits) === getRow(lastRequestSent.bits.data)) & lastRequestSent.valid
    sameRowArbiter.io.in(i).bits := memory(i).bits
    validArbiter.io.in(i).valid := memory(i).valid
    validArbiter.io.in(i).bits := memory(i).bits
  }
  val downstreamArbiter = Module(new Arbiter(io.enq.bits.cloneType, 2))
  downstreamArbiter.io.in(0) <> sameRowArbiter.io.out
  downstreamArbiter.io.in(1) <> validArbiter.io.out

  val outputEb = Module(new ElasticBuffer(lastRequestSent.bits.cloneType))
  io.deq.valid := outputEb.io.out.valid
  io.deq.bits := outputEb.io.out.bits.data
  io.isNewRow := outputEb.io.out.bits.chosen === 1.U
  outputEb.io.out.ready := io.deq.ready
  outputEb.io.in.bits := lastRequestSent.bits
  outputEb.io.in.valid := lastRequestSent.valid

  when(outputEb.io.in.ready) {
    lastRequestSent.valid := downstreamArbiter.io.out.valid
    lastRequestSent.bits.data  := downstreamArbiter.io.out.bits
    lastRequestSent.bits.chosen := downstreamArbiter.io.chosen
  }
  downstreamArbiter.io.out.ready := outputEb.io.in.ready
  val queueFull = Vec(memory.map(x => x.valid)).asUInt.andR
  val emptyEntrySelect = PriorityEncoderOH(memory.map(x => ~x.valid))
  io.enq.ready := outputEb.io.in.ready | ~queueFull

  for(i <- 0 until queueDepth) {
    when(io.enq.valid & Mux(downstreamArbiter.io.out.ready & downstreamArbiter.io.out.valid, Mux(downstreamArbiter.io.chosen === 1.U, validArbiter.io.in(i).ready & validArbiter.io.in(i).valid, sameRowArbiter.io.in(i).ready & sameRowArbiter.io.in(i).valid), emptyEntrySelect(i))) {
      memory(i).valid := true.B
      memory(i).bits := io.enq.bits
    } .elsewhen(downstreamArbiter.io.out.ready & downstreamArbiter.io.out.valid & Mux(downstreamArbiter.io.chosen === 1.U, validArbiter.io.in(i).ready & validArbiter.io.in(i).valid, sameRowArbiter.io.in(i).ready & sameRowArbiter.io.in(i).valid)) {
      memory(i).valid := false.B
    }
  }
}

// Not used in our ISFPGA19 paper, validated in simulation but not tested on FPGA
object InOrderExternalMultiPortedMemoryArbiter {
  val numMemoryPorts = 5
}

class InOrderExternalMultiPortedMemoryArbiter(reqAddrWidth: Int=ExternalMemoryArbiter.reqAddrWidth, memAddrWidth: Int=ExternalMemoryArbiter.memAddrWidth, memDataWidth: Int=ExternalMemoryArbiter.memDataWidth, memIdWidth: Int=ExternalMemoryArbiter.memIdWidth, numReqHandlers: Int=ExternalMemoryArbiter.numReqHandlers, maxInFlightRequests: Int=InOrderExternalMemoryArbiter.maxInFlightRequests, memAddrOffset: Long=ExternalMemoryArbiter.memAddrOffset, numMemoryPorts: Int=InOrderExternalMultiPortedMemoryArbiter.numMemoryPorts) extends ExternalMemoryArbiterBase(reqAddrWidth, memAddrWidth, memDataWidth, memIdWidth, numReqHandlers, numMemoryPorts) {
  val inReqWithFullAddr = Wire(Vec(numReqHandlers, DecoupledIO(UInt(fullTagWidth.W))))
  for(i <- 0 until numReqHandlers) {
    inReqWithFullAddr(i).valid := io.inReq(i).valid
    io.inReq(i).ready := inReqWithFullAddr(i).ready
    if(numReqHandlers > 1) {
      inReqWithFullAddr(i).bits := Cat(io.inReq(i).bits, i.U(handlerAddrWidth.W))
    } else {
      inReqWithFullAddr(i).bits := io.inReq(i).bits
    }
  }
  val scrambledInputs = {
    if(numReqHandlers > 1) {
      Scrambler(inReqWithFullAddr(0).bits.cloneType, inReqWithFullAddr, numMemoryPorts)
    } else {
      val inputArbiter = Module(new ResettableRRArbiter(UInt(tagWidth.W), numReqHandlers))
      for (i <- 0 until numReqHandlers) inputArbiter.io.in(i) <> io.inReq(i)
      Vec(1, inputArbiter.io.out)
    }
  }
  val memInterfaceManagers = Array.fill(numMemoryPorts)(Module(new MemoryInterfaceManager(fullTagWidth, offsetWidth, memAddrWidth, memDataWidth, memIdWidth, maxInFlightRequests, memAddrOffset)).io)
  // Using ElasticBuffer to make memory input irrevocable, replace with Queue if
  // more buffering is needed.
  memInterfaceManagers.map(_.enq).zip(scrambledInputs).foreach{case(mgrPort, in) => mgrPort <> ElasticBuffer(in)}
  memInterfaceManagers.map(_.outMemAddr).zip(io.outMem).foreach{case(mgrPort, memPort) => {
    memPort.ARVALID := mgrPort.valid
    mgrPort.ready   := memPort.ARREADY
    memPort.ARADDR  := mgrPort.bits
  }}
  memInterfaceManagers.map(_.inMemData).zip(io.outMem).foreach{case(mgrPort, memPort) => {
    mgrPort.valid   := memPort.RVALID
    mgrPort.bits    := memPort.RDATA
    memPort.RREADY  := mgrPort.ready
  }}

  val dataCrossbarInputType = memInterfaceManagers(0).deq.bits.cloneType
  val dataCrossbarOutputType = io.outResp(0).bits.cloneType
  val dataCrossbar = Module(new OneWayCrossbarGeneric(dataCrossbarInputType,
    dataCrossbarOutputType, numMemoryPorts, numReqHandlers,
    (mgrPort: AddrDataIO) => mgrPort.addr(handlerAddrWidth-1, 0),
    (mgrPort: AddrDataIO) => {
      val output = Wire(dataCrossbarOutputType)
      output.data := mgrPort.data
      output.addr := mgrPort.addr(fullTagWidth-1, handlerAddrWidth)
      output
    }))
  dataCrossbar.io.ins.zip(memInterfaceManagers.map(_.deq)).foreach{case(xBarIn, mgrOut) => xBarIn <> mgrOut}
  dataCrossbar.io.outs.zip(io.outResp).foreach{case(xBarOut, outResp) => xBarOut <> outResp }
}

package fpgamshr.util

import chisel3._
import chisel3.experimental._
import chisel3.util.{log2Ceil, HasBlackBoxResource, Queue, DecoupledIO, RRArbiter, ShiftRegister, isPow2}

import fpgamshr.interfaces._

class XilinxTrueDualPortReadFirstBRAM(width: Int,
                                 depth: Int,
                                 performance: String="HIGH_PERFORMANCE",
                                 initFile: String="")
                                 extends BlackBox(Map("RAM_WIDTH" -> width,
                                                      "RAM_DEPTH" -> depth,
                                                      "RAM_PERFORMANCE" -> performance,
                                                      "INIT_FILE" -> initFile))
                                 with HasBlackBoxResource {
    val io = IO(new XilinxTrueDualPortBRAMBlackBoxIO(log2Ceil(depth), width))

    setResource("/XilinxTrueDualPortReadFirstBRAM.v")
}

class XilinxSimpleDualPortNoChangeBRAM(width: Int,
                                       depth: Int,
                                       performance: String="HIGH_PERFORMANCE",
                                       initFile: String="")
                                       extends BlackBox(Map("RAM_WIDTH" -> width,
                                                            "RAM_DEPTH" -> depth,
                                                            "RAM_PERFORMANCE" -> performance,
                                                            "INIT_FILE" -> initFile))
                                       with HasBlackBoxResource {
    val io = IO(new XilinxSimpleDualPortBRAMBlackBoxIO(log2Ceil(depth), width))

    setResource("/XilinxSimpleDualPortNoChangeBRAM.v")
}

/* Default values for testing */
object AXIBRAMInterface {
    val addrWidth = 8
    val axiDataWidth = 128
    val bramDataWidth = 72
}

/* Exposes a true dual port BRAM to AXI. Supports WSTRB to perform partial updates,
 * implemented as read-modify-writes of lines read from the BRAM. */
class AXITDPBRAMInterface(addrWidth: Int, axiDataWidth: Int, bramDataWidth: Int, queueDepth: Int=4) extends Module {
    /* WARNING: clock and reset of the memory must be connected externally! */
    require(isPow2(axiDataWidth))
    require(axiDataWidth >= 8)
    require(axiDataWidth >= bramDataWidth)
    val strbWidth = axiDataWidth / 8
    val usefulStrbWidth = bramDataWidth / 8
    val bramLatency = 2
    val io = IO(new Bundle{
        val axi = new AXI4Lite(UInt(axiDataWidth.W), addrWidth)
        val bram = new XilinxTrueDualPortBRAMIO(addrWidth, bramDataWidth).flip
    })


    val awChannel = Wire(DecoupledIO(UInt(addrWidth.W)))
    io.axi.AWREADY := awChannel.ready
    awChannel.valid := io.axi.AWVALID
    awChannel.bits := io.axi.AWADDR

    val arChannel = Wire(DecoupledIO(UInt(addrWidth.W)))
    io.axi.ARREADY := arChannel.ready
    arChannel.valid := io.axi.ARVALID
    arChannel.bits := io.axi.ARADDR

    val rChannel = Wire(DecoupledIO(UInt(axiDataWidth.W)))
    rChannel.ready := io.axi.RREADY
    io.axi.RVALID := rChannel.valid
    io.axi.RDATA := rChannel.bits
    io.axi.RRESP := 0.U

    val wChannel = Wire(DecoupledIO(new DataStrobeIO(axiDataWidth)))
    io.axi.WREADY := wChannel.ready
    wChannel.valid := io.axi.WVALID
    wChannel.bits.data := io.axi.WDATA(bramDataWidth - 1, 0)
    wChannel.bits.strb := io.axi.WSTRB

    val bChannel = Wire(DecoupledIO(UInt(2.W)))
    bChannel.ready := io.axi.BREADY
    io.axi.BVALID := bChannel.valid
    io.axi.BRESP := bChannel.bits

    val awQueue = Module(new Queue(UInt(addrWidth.W), queueDepth))
    awQueue.io.enq <> awChannel
    val wQueue = Module(new Queue(new DataStrobeIO(axiDataWidth), queueDepth))
    wQueue.io.enq <> wChannel
    /* Synchronizes the AW and W channels, since the BRAM requires address and data at the same time. */
    val addrDataWriteQueue = Module(new Queue(new AddressDataStrobeIO(addrWidth, axiDataWidth), queueDepth))
    addrDataWriteQueue.io.enq.valid := awQueue.io.deq.valid & wQueue.io.deq.valid
    addrDataWriteQueue.io.enq.bits.addr := awQueue.io.deq.bits
    addrDataWriteQueue.io.enq.bits.data := wQueue.io.deq.bits.data
    addrDataWriteQueue.io.enq.bits.strb := wQueue.io.deq.bits.strb
    /* Consume one token only when the other one is available and the receiving queue is ready. */
    awQueue.io.deq.ready := wQueue.io.deq.valid & addrDataWriteQueue.io.enq.ready
    wQueue.io.deq.ready := awQueue.io.deq.valid & addrDataWriteQueue.io.enq.ready

    val arQueue = Module(new Queue(UInt(addrWidth.W), queueDepth))
    arQueue.io.enq <> arChannel

    /* Arbitrates between reads and writes. Replace with an Arbiter to always give
     * priority to one of the channels. */
    val inputArbiter = Module(new RRArbiter(new AddressDataStrobeIO(addrWidth, axiDataWidth), 2))
    inputArbiter.io.in(0).valid := arQueue.io.deq.valid
    inputArbiter.io.in(0).bits.addr := arQueue.io.deq.bits
    arQueue.io.deq.ready := inputArbiter.io.in(0).ready
    inputArbiter.io.in(0).bits.data := 0.U
    inputArbiter.io.in(0).bits.strb := 0.U
    inputArbiter.io.in(1) <> addrDataWriteQueue.io.deq

    val stall = Wire(Bool())
    val delayedBits = ShiftRegister(inputArbiter.io.out.bits, bramLatency, ~stall)
    val delayedValid = ShiftRegister(inputArbiter.io.out.valid, bramLatency, ~stall)
    val delayedChosen = ShiftRegister(inputArbiter.io.chosen, bramLatency, ~stall)

    inputArbiter.io.out.ready := ~stall
    io.bram.addra := inputArbiter.io.out.bits.addr
    io.bram.ena := ~stall
    io.bram.regcea := ~stall
    io.bram.addrb := delayedBits.addr
    io.bram.web := delayedChosen & delayedValid
    io.bram.enb := ~stall
    io.bram.dina := 0.U
    io.bram.wea := false.B
    io.bram.regceb := false.B

    val storeToLoad = Module(new StoreToLoadForwardingTwoStages(UInt(bramDataWidth.W), addrWidth))
    storeToLoad.io.rdAddr := inputArbiter.io.out.bits.addr
    storeToLoad.io.wrEn := io.bram.web
    storeToLoad.io.dataInFromMem := io.bram.douta
    storeToLoad.io.dataOutToMem := io.bram.dinb
    val dataFixed = storeToLoad.io.dataInFixed

    val wrLineByteVector = Wire(Vec(usefulStrbWidth, UInt(8.W)))
    /* Re-writes the same line except for the bytes whose strobe bit is active. */
    for(i <- 0 until usefulStrbWidth) {
        wrLineByteVector(i) := Mux(delayedBits.strb(i), delayedBits.data(math.min((i + 1) * 8 - 1, bramDataWidth - 1), i * 8), dataFixed(math.min((i + 1) * 8 - 1, bramDataWidth - 1), i * 8))
    }

    io.bram.dinb := wrLineByteVector.asUInt

    val rQueue = Module(new Queue(UInt(axiDataWidth.W), queueDepth))
    rQueue.io.enq.valid := delayedValid & ~delayedChosen
    rQueue.io.enq.bits := dataFixed

    val bQueue = Module(new Queue(UInt(2.W), queueDepth))
    bQueue.io.enq.valid := delayedValid & delayedChosen
    bQueue.io.enq.bits := 0.U

    stall := ~rQueue.io.enq.ready | ~bQueue.io.enq.ready

    rChannel.valid := rQueue.io.deq.valid
    rChannel.bits := rQueue.io.deq.bits
    rQueue.io.deq.ready := rChannel.ready

    bChannel.valid := bQueue.io.deq.valid
    bChannel.bits := bQueue.io.deq.bits
    bQueue.io.deq.ready := bChannel.ready
}

class AXISDPBRAMInterface(addrWidth: Int, axiDataWidth: Int, bramDataWidth: Int, queueDepth: Int=4) extends Module {
    /* WARNING: clock and reset of the memory must be connected externally! */
    require(isPow2(axiDataWidth))
    require(axiDataWidth >= 8)
    require(axiDataWidth >= bramDataWidth)
    val strbWidth = axiDataWidth / 8
    val usefulStrbWidth = bramDataWidth / 8
    val bramLatency = 2
    val io = IO(new Bundle{
        val axi = new AXI4Lite(UInt(axiDataWidth.W), addrWidth)
        val bram = new XilinxSimpleDualPortBRAMIO(addrWidth, bramDataWidth).flip
    })


    val awChannel = Wire(DecoupledIO(UInt(addrWidth.W)))
    io.axi.AWREADY := awChannel.ready
    awChannel.valid := io.axi.AWVALID
    awChannel.bits := io.axi.AWADDR

    val arChannel = Wire(DecoupledIO(UInt(addrWidth.W)))
    io.axi.ARREADY := arChannel.ready
    arChannel.valid := io.axi.ARVALID
    arChannel.bits := io.axi.ARADDR

    val rChannel = Wire(DecoupledIO(UInt(axiDataWidth.W)))
    rChannel.ready := io.axi.RREADY
    io.axi.RVALID := rChannel.valid
    io.axi.RDATA := rChannel.bits
    io.axi.RRESP := 0.U

    val wChannel = Wire(DecoupledIO(new DataStrobeIO(axiDataWidth)))
    io.axi.WREADY := wChannel.ready
    wChannel.valid := io.axi.WVALID
    wChannel.bits.data := io.axi.WDATA(bramDataWidth - 1, 0)
    wChannel.bits.strb := io.axi.WSTRB

    val bChannel = Wire(DecoupledIO(UInt(2.W)))
    bChannel.ready := io.axi.BREADY
    io.axi.BVALID := bChannel.valid
    io.axi.BRESP := bChannel.bits

    val awQueue = Module(new Queue(UInt(addrWidth.W), queueDepth))
    awQueue.io.enq <> awChannel
    val wQueue = Module(new Queue(new DataStrobeIO(axiDataWidth), queueDepth))
    wQueue.io.enq <> wChannel
    /* Synchronizes the AW and W channels, since the BRAM requires address and data at the same time. */
    val addrDataWriteQueue = Module(new Queue(new AddressDataStrobeIO(addrWidth, axiDataWidth), queueDepth))
    addrDataWriteQueue.io.enq.valid := awQueue.io.deq.valid & wQueue.io.deq.valid
    addrDataWriteQueue.io.enq.bits.addr := awQueue.io.deq.bits
    addrDataWriteQueue.io.enq.bits.data := wQueue.io.deq.bits.data
    addrDataWriteQueue.io.enq.bits.strb := wQueue.io.deq.bits.strb
    /* Consume one token only when the other one is available and the receiving queue is ready. */
    awQueue.io.deq.ready := wQueue.io.deq.valid & addrDataWriteQueue.io.enq.ready
    wQueue.io.deq.ready := awQueue.io.deq.valid & addrDataWriteQueue.io.enq.ready

    val arQueue = Module(new Queue(UInt(addrWidth.W), queueDepth))
    arQueue.io.enq <> arChannel

    /* Arbitrates between reads and writes. Replace with an Arbiter to always give
     * priority to one of the channels. */
    val inputArbiter = Module(new RRArbiter(new AddressDataStrobeIO(addrWidth, axiDataWidth), 2))
    inputArbiter.io.in(0).valid := arQueue.io.deq.valid
    inputArbiter.io.in(0).bits.addr := arQueue.io.deq.bits
    arQueue.io.deq.ready := inputArbiter.io.in(0).ready
    inputArbiter.io.in(0).bits.data := 0.U
    inputArbiter.io.in(0).bits.strb := 0.U
    inputArbiter.io.in(1) <> addrDataWriteQueue.io.deq

    val stall = Wire(Bool())
    val delayedBits = ShiftRegister(inputArbiter.io.out.bits, bramLatency, ~stall)
    val delayedValid = ShiftRegister(inputArbiter.io.out.valid, bramLatency, ~stall)
    val delayedChosen = ShiftRegister(inputArbiter.io.chosen, bramLatency, ~stall)

    inputArbiter.io.out.ready := ~stall
    io.bram.addrb := inputArbiter.io.out.bits.addr
    io.bram.enb := ~stall
    io.bram.regceb := ~stall
    io.bram.addra := delayedBits.addr
    io.bram.wea := delayedChosen & delayedValid & ~stall

    val storeToLoad = Module(new StoreToLoadForwardingTwoStages(UInt(bramDataWidth.W), addrWidth))
    storeToLoad.io.rdAddr := inputArbiter.io.out.bits.addr
    storeToLoad.io.wrEn := io.bram.wea
    storeToLoad.io.dataInFromMem := io.bram.doutb
    storeToLoad.io.dataOutToMem := io.bram.dina
    val dataFixed = storeToLoad.io.dataInFixed

    val wrLineByteVector = Wire(Vec(usefulStrbWidth, UInt(8.W)))
    /* Re-writes the same line except for the bytes whose strobe bit is active. */
    for(i <- 0 until usefulStrbWidth) {
        wrLineByteVector(i) := Mux(delayedBits.strb(i), delayedBits.data(math.min((i + 1) * 8 - 1, bramDataWidth - 1), i * 8), dataFixed(math.min((i + 1) * 8 - 1, bramDataWidth - 1), i * 8))
    }

    io.bram.dina := wrLineByteVector.asUInt

    val rQueue = Module(new Queue(UInt(axiDataWidth.W), queueDepth))
    rQueue.io.enq.valid := delayedValid & ~delayedChosen
    rQueue.io.enq.bits := dataFixed

    val bQueue = Module(new Queue(UInt(2.W), queueDepth))
    bQueue.io.enq.valid := delayedValid & delayedChosen
    bQueue.io.enq.bits := 0.U

    stall := ~rQueue.io.enq.ready | ~bQueue.io.enq.ready

    rChannel.valid := rQueue.io.deq.valid
    rChannel.bits := rQueue.io.deq.bits
    rQueue.io.deq.ready := rChannel.ready

    bChannel.valid := bQueue.io.deq.valid
    bChannel.bits := bQueue.io.deq.bits
    bQueue.io.deq.ready := bChannel.ready
}

/* AXIBRAMInterface with an SDP BRAM, to make testing of the AXIBRAMInterface easier */
class AXIXilinxSimpleDualPortNoChangeBRAM(addrWidth: Int, axiDataWidth: Int, bramDataWidth: Int, queueDepth: Int=4) extends Module {
    require(isPow2(axiDataWidth))
    require(axiDataWidth >= 8)
    require(axiDataWidth >= bramDataWidth)
    val strbWidth = axiDataWidth / 8
    val usefulStrbWidth = bramDataWidth / 8
    val bramLatency = 2
    val io = IO(new Bundle{
        val axi = new AXI4Lite(UInt(axiDataWidth.W), addrWidth)
    })

    val bram = Module(new XilinxSimpleDualPortNoChangeBRAM(bramDataWidth, (1 << addrWidth)))
    val interface = Module(new AXISDPBRAMInterface(addrWidth, axiDataWidth, bramDataWidth, queueDepth))

    io.axi <> interface.io.axi
    interface.io.bram <> bram.io
    bram.io.clock := clock
    bram.io.reset := reset
}

/* A 2W/1R memory made of 4 XilinxSimpleDualPortNoChangeBRAM (c.f. LaForest et al. "Multi-Ported Memories for FPGAs via XOR") */
/* WARNING: It takes 3 cycles before a write can be read back. */
class TwoWriteOneReadPortBRAM(addrWidth: Int, dataWidth: Int) extends Module {
    val io = IO(new Bundle{
        val wraddra = Input(UInt(addrWidth.W))
        val wea = Input(Bool())
        val dina = Input(UInt(dataWidth.W))
        val wraddrb = Input(UInt(addrWidth.W))
        val web = Input(Bool())
        val dinb = Input(UInt(dataWidth.W))
        val rdaddr = Input(UInt(addrWidth.W))
        val rden = Input(Bool())
        val dout = Output(UInt(dataWidth.W))
    })


    val writeMemColumn = Array.fill(2)(Module(new XilinxSimpleDualPortNoChangeBRAM(dataWidth, (1 << addrWidth))).io)
    val readMemColumn = Array.fill(2)(Module(new XilinxSimpleDualPortNoChangeBRAM(dataWidth, (1 << addrWidth))).io)
    for(i <- 0 until 2) {
      writeMemColumn(i).clock := clock
      writeMemColumn(i).reset := reset
      readMemColumn(i).clock := clock
      readMemColumn(i).reset := reset
    }

    val delayedDinA = RegNext(RegNext(io.dina))
    val delayedWeA = RegNext(RegNext(io.wea))
    val delayedWrAddrA = RegNext(RegNext(io.wraddra))
    writeMemColumn(0).addra := delayedWrAddrA
    writeMemColumn(0).wea := delayedWeA
    writeMemColumn(1).addrb := io.wraddra
    writeMemColumn(1).enb := true.B
    writeMemColumn(1).regceb := true.B
    writeMemColumn(0).dina := delayedDinA ^ writeMemColumn(1).doutb
    readMemColumn(0).addra := delayedWrAddrA
    readMemColumn(0).wea := delayedWeA
    readMemColumn(0).dina := delayedDinA ^ writeMemColumn(1).doutb

    val delayedDinB = RegNext(RegNext(io.dinb))
    val delayedWeB = RegNext(RegNext(io.web))
    val delayedWrAddrB = RegNext(RegNext(io.wraddrb))
    writeMemColumn(1).addra := delayedWrAddrB
    writeMemColumn(1).wea := delayedWeB
    writeMemColumn(0).addrb := io.wraddrb
    writeMemColumn(0).enb := true.B
    writeMemColumn(0).regceb := true.B
    writeMemColumn(1).dina := delayedDinB ^ writeMemColumn(0).doutb
    writeMemColumn(1).addra := delayedWrAddrB
    writeMemColumn(1).wea := delayedWeB
    readMemColumn(1).dina := delayedDinB ^ writeMemColumn(0).doutb
    readMemColumn(1).addra := delayedWrAddrB
    readMemColumn(1).wea := delayedWeB

    readMemColumn(0).addrb := io.rdaddr
    readMemColumn(0).enb := io.rden
    readMemColumn(0).regceb := io.rden
    readMemColumn(1).addrb := io.rdaddr
    readMemColumn(1).enb := io.rden
    readMemColumn(1).regceb := io.rden
    io.dout := readMemColumn(0).doutb ^ readMemColumn(1).doutb

}

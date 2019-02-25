package fpgamshr.interfaces

import chisel3._
import chisel3.util.{DecoupledIO}

object AXI4Channel extends Enumeration {
    type AXI4Channel = Value
    val ReadAddress, ReadData, WriteAddress, WriteData, WriteResponse = Value
}

class AXI4LiteReadOnly[T <: Data](dataType: T, addressWidth: Int) extends Bundle {
    val ARADDR  = Input(UInt(addressWidth.W))
    val ARVALID = Input(Bool())
    val ARREADY = Output(Bool())
    val RDATA   = Output(dataType)
    val RRESP   = Output(UInt(2.W))
    val RVALID  = Output(Bool())
    val RREADY  = Input(Bool())

    def AXI4ARAsDecoupledIO(): DecoupledIO[UInt] = {
        val output = Wire(DecoupledIO(UInt(addressWidth.W)))
        output.bits := this.ARADDR
        output.valid := this.ARVALID
        this.ARREADY := output.ready
        output
    }

    def AXI4RAsDecoupledIO(): DecoupledIO[T] = {
        val output = Wire(DecoupledIO(dataType))
        output.bits := this.RDATA
        output.valid := this.RVALID
        this.RREADY := output.ready
        output
    }
}

class AXI4LiteReadOnlyWithID[T <: Data](dataType: T, addressWidth: Int, idWidth: Int) extends AXI4LiteReadOnly(dataType, addressWidth) {
    val ARID    = Input(UInt(idWidth.W))
    val RID     = Output(UInt(idWidth.W))
}

class AXI4FullReadOnly[T <: Data](dataType: T, addressWidth: Int, idWidth: Int) extends AXI4LiteReadOnlyWithID(dataType, addressWidth, idWidth) {
    val ARLEN   = Input(UInt(8.W))
    val ARSIZE  = Input(UInt(3.W))
    val ARBURST = Input(UInt(2.W))
    val ARLOCK  = Input(UInt(2.W))
    val ARCACHE = Input(UInt(4.W))
    val ARPROT  = Input(UInt(3.W))
    val RLAST   = Output(Bool())
    override def cloneType = (new AXI4FullReadOnly(dataType, addressWidth, idWidth)).asInstanceOf[this.type]
}

class AXI4Lite[T <: Data](dataType: T, addressWidth: Int) extends AXI4LiteReadOnly(dataType, addressWidth) {
    val AWADDR  = Input(UInt(addressWidth.W))
    val AWVALID = Input(Bool())
    val AWREADY = Output(Bool())
    val WDATA   = Input(dataType)
    val WVALID  = Input(Bool())
    val WREADY  = Output(Bool())
    val WSTRB  = Input(UInt((dataType.getWidth / 8).W))
    val BRESP   = Output(UInt(2.W))
    val BVALID  = Output(Bool())
    val BREADY  = Input(Bool())
    override def cloneType = (new AXI4Lite(dataType, addressWidth)).asInstanceOf[this.type]
}

class AXI4LiteReadOnlyProfiling(dataWidth: Int, addressWidth: Int) extends Bundle {
    val axi = new AXI4LiteReadOnly(UInt(dataWidth.W), addressWidth)
    val clear = Input(Bool())
    val snapshot = Input(Bool())

    override def cloneType = (new AXI4LiteReadOnlyProfiling(dataWidth, addressWidth)).asInstanceOf[this.type]
}

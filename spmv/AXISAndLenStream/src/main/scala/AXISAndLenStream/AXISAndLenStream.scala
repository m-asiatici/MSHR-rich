package axislenstream

import chisel3._
import chisel3.util._

object ElasticBufferAXISAndLenStream {
    def apply[T <: Data](in: DecoupledIO[T]) = {
        val m = Module(new ElasticBufferAXISAndLenStream(in.bits.cloneType))
        m.io.in <> in
        m.io.out
    }

}

class ElasticBufferAXISAndLenStream[T <: Data](gen: T) extends Module {
    val io = IO(new Bundle {
        val in = Flipped(DecoupledIO(gen))
        val out = DecoupledIO(gen)
    })

    val fullBuffer = Module(new ElasticBufferRegExportAXISAndLenStream(gen))
    fullBuffer.io.in <> io.in
    io.out <> fullBuffer.io.out
}

class ElasticBufferRegExportAXISAndLenStream[T <: Data](gen: T) extends Module {
    val io = IO(new Bundle {
        val in = Flipped(DecoupledIO(gen))
        val out = DecoupledIO(gen)
        val regs = Vec(2, ValidIO(gen))
        val readyReg = Output(Bool())
    })

    val outerRegData = Reg(gen)
    val outerRegValid = RegInit(Bool(), false.B)
    val innerRegData = Reg(gen)
    val innerRegValid = RegInit(Bool(), false.B)
    val readyReg = Reg(Bool())

    when(readyReg === true.B)
    {
        outerRegData := io.in.bits
        innerRegData := outerRegData
        outerRegValid := io.in.valid
        innerRegValid := outerRegValid & ~(io.out.ready | ~io.out.valid)
    }
    io.out.bits := Mux(readyReg === true.B, outerRegData, innerRegData)
    io.out.valid := Mux(readyReg === true.B, outerRegValid, innerRegValid)
    readyReg := io.out.ready | ~io.out.valid
    io.in.ready := readyReg
    io.regs(0).bits := outerRegData
    io.regs(0).valid := outerRegValid
    io.regs(1).bits := innerRegData
    io.regs(1).valid := innerRegValid
    io.readyReg := readyReg
}

class AXISAndLenStream extends Module {
  val numRegs = 3
  val addrWidth = log2Ceil(numRegs + 1) // +1 for the status register
  val dataWidth = 32
    val io=IO(new Bundle{
        val rdAddr = Flipped(DecoupledIO(UInt(addrWidth.W)))
        val rdData = DecoupledIO(UInt(dataWidth.W))
        val wrAddr = Flipped(DecoupledIO(UInt(addrWidth.W)))
        val wrData = Flipped(DecoupledIO(UInt(dataWidth.W)))
        val wrAck  = Output(Bool())
        val offset = ValidIO(UInt(dataWidth.W))
        val nnz = ValidIO(UInt(dataWidth.W))
        val outputSize = ValidIO(UInt(dataWidth.W))
        val running = Output(Bool())
        val done = Input(Bool())
        val rowPtrStream = Flipped(DecoupledIO(UInt(dataWidth.W)))
        val lenStream = DecoupledIO(UInt(dataWidth.W))
    })

    val sIdle :: sRunning :: Nil = Enum(2)

    val state = RegInit(sIdle)
    io.running := state === sRunning

    val regs = Reg(Vec(numRegs, UInt(dataWidth.W)))
    val start = Wire(Bool())

    val rdAddrEb = ElasticBufferAXISAndLenStream(io.rdAddr)
    rdAddrEb.ready := io.rdData.ready
    io.rdData.bits := MuxLookup(rdAddrEb.bits, state === sIdle, (1 to numRegs).map(i => (i.U -> regs(i-1))))
    io.rdData.valid := rdAddrEb.valid

    val wrAddrEb = ElasticBufferAXISAndLenStream(io.wrAddr)
    val wrDataEb = ElasticBufferAXISAndLenStream(io.wrData)
    val wrAddrDataAvailable = wrAddrEb.valid & wrDataEb.valid
    wrAddrEb.ready := wrDataEb.valid
    wrDataEb.ready := wrAddrEb.valid

    start := false.B
    io.wrAck := false.B
    when(wrAddrDataAvailable) {
      when(wrAddrEb.bits === 0.U) {
        when(wrDataEb.bits(0) === 1.U) {
          start := true.B
        }
      }
      io.wrAck := true.B
    }

    for(i <- 1 to numRegs) {
      when(wrAddrDataAvailable & (wrAddrEb.bits === i.U)) {
        regs(i-1) := wrDataEb.bits
      }
    }

    io.nnz.bits        := regs(0)
    io.outputSize.bits := regs(1)
    io.offset.bits     := regs(2)

    io.running := false.B
    io.offset.valid := false.B
    io.nnz.valid := false.B
    io.outputSize.valid := false.B

    switch(state) {
      is(sIdle) {
        when(start) {
          state := sRunning
          io.offset.valid := true.B
          io.nnz.valid := true.B
          io.outputSize.valid := true.B
        }
      }
      is(sRunning) {
        io.running := true.B
        when(io.done) {
          state := sIdle
        }
      }
    }

    val emptyData = Wire(ValidIO(UInt(dataWidth.W)))
    emptyData.valid := false.B
    emptyData.bits  := DontCare
    val delayedRowPtr = RegInit(Vec(Seq.fill(2)(emptyData)))
    // val lenStreamBuffer = Module(new ElasticBufferAXISAndLenStream(io.lenStream.bits.cloneType))

    io.rowPtrStream.ready := io.lenStream.ready | ~delayedRowPtr(0).valid | ~delayedRowPtr(1).valid
    when(io.done) {
      delayedRowPtr(0).valid := false.B
    } .elsewhen(io.lenStream.ready | ~delayedRowPtr(0).valid | ~delayedRowPtr(1).valid) {
      delayedRowPtr(0).bits := io.rowPtrStream.bits
      delayedRowPtr(0).valid := io.rowPtrStream.valid
    }
    when(io.done) {
      delayedRowPtr(1).valid := false.B
    } .elsewhen(io.lenStream.ready | ~delayedRowPtr(1).valid) {
      delayedRowPtr(1) := delayedRowPtr(0)
    }
    io.lenStream.valid := delayedRowPtr(1).valid & delayedRowPtr(0).valid
    io.lenStream.bits  := delayedRowPtr(0).bits - delayedRowPtr(1).bits

    // lenStreamBuffer.io.in.valid := delayedRowPtr(1).valid & delayedRowPtr(0).valid
    // lenStreamBuffer.io.in.bits  := delayedRowPtr(0).bits - delayedRowPtr(1).bits
    // io.lenStream <> lenStreamBuffer.io.out
}

/**
  * To just generate the Verilog for the AXISAndLenStream, run:
  * {{{
  * test:runMain axislenstream.AXISAndLenStream
  * }}}
  */

object AXISAndLenStream extends App {
    chisel3.Driver.execute(args, () => new AXISAndLenStream)
}

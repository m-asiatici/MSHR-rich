package fpgamshr.util

import chisel3._
import chisel3.util.{DecoupledIO, ValidIO, log2Ceil, RegEnable}

object ElasticBuffer {
    def apply[T <: Data](in: DecoupledIO[T]) = {
        val m = Module(new ElasticBuffer(in.bits.cloneType))
        m.io.in <> in
        m.io.out
    }

}

class ElasticBuffer[T <: Data](gen: T) extends Module {
    val io = IO(new Bundle {
        val in = DecoupledIO(gen).flip
        val out = DecoupledIO(gen)
    })

    val fullBuffer = Module(new ElasticBufferRegExport(gen))
    fullBuffer.io.in <> io.in
    io.out <> fullBuffer.io.out
}

class ElasticBufferRegExport[T <: Data](gen: T) extends Module {
    val io = IO(new Bundle {
        val in = DecoupledIO(gen).flip
        val out = DecoupledIO(gen)
        val regs = Vec(2, ValidIO(gen))
        val readyReg = Output(Bool())
    })

    val outerRegData = Reg(gen)
    val outerRegValid = RegInit(false.B)
    val innerRegData = Reg(gen)
    val innerRegValid = RegInit(false.B)
    val readyReg = RegInit(false.B)

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

object DReg {
    def apply[T <: Data](in: T) = {
        val m = Module(new DReg(in))
        m.io.in <> in
        m.io.out
    }
}

class DReg[T <: Data](gen: T) extends Module {
    val io = IO(new Bundle {
        val in = DecoupledIO(gen).flip
        val out = DecoupledIO(gen)
    })

    val regData = Reg(gen)
    val regValid = RegInit(Bool(), false.B)
    when(io.out.ready === true.B) {
        regData := io.in.bits
        regValid := io.in.valid
    }
    io.in.ready := io.out.ready
    io.out.valid := regValid
    io.out.bits := regData
}

object EagerFork{
    val defaultType = UInt(32.W)
    val defaultNumOutputs = 4
}

class EagerFork[T <: Data](gen: T, numOutputs: Int) extends Module {
    val io = IO(new Bundle {
        val in = DecoupledIO(gen).flip
        val out = Vec(numOutputs, DecoupledIO(gen))
    })

    val tokenAvailable = Wire(Vec(numOutputs, Bool()))
    val outStalls = Vec(io.out.zip(tokenAvailable).map((x) => ~x._1.ready & x._2))
    tokenAvailable := RegNext(Vec(outStalls.map((x) => x | ~(io.in.valid & ~io.in.ready))), Vec(Seq.fill(numOutputs)(true.B)))
    io.in.ready := ~outStalls.asUInt.orR
    for(i <- 0 until numOutputs) {
        io.out(i).valid := tokenAvailable(i) & io.in.valid
        io.out(i).bits := io.in.bits
    }

}

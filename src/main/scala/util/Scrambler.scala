package fpgamshr.util

import chisel3._
import chisel3.util._
import fpgamshr.interfaces._

import scala.math.max

class Scrambler[T <: Data](gen: T, numInputs: Int, numOutputs: Int) extends Module {
  val inputIndexWidth = log2Ceil(numInputs)
  val io=IO(new Bundle{
    val in = Flipped(Vec(numInputs, DecoupledIO(gen)))
    val out = Vec(numOutputs, DecoupledIO(gen))
    val chosen = Vec(numOutputs, Output(UInt(inputIndexWidth.W)))
  })
  val counterPeriod = max(numInputs, numOutputs)
  val (counter, wrap) = Counter(true.B, counterPeriod)
  val typedDontCare: T = Wire(gen)
  typedDontCare := DontCare
  io.out.zipWithIndex.foreach{case(x, iOut) => {
    x.bits := MuxLookup(counter, typedDontCare,
      (0 until numInputs).map(iIn => (
        ((iIn + iOut) % counterPeriod).U -> io.in(iIn).bits
      ))
    )
    x.valid := MuxLookup(counter, false.B,
      (0 until numInputs).map(iIn => (
        ((iIn + iOut) % counterPeriod).U -> io.in(iIn).valid
      ))
    )
  }}
  io.in.map(_.ready).zipWithIndex.foreach{case(x, iIn) => {
    x := MuxLookup(counter, false.B,
      (0 until numOutputs).map(iOut => (
        ((iIn + iOut) % counterPeriod).U -> io.out(iOut).ready
      ))
    )
  }}
  io.chosen.zipWithIndex.foreach{case(x, iOut) =>
    x := MuxLookup(counter, 0.U,
      (0 until numInputs).map(iIn => (
        ((iIn + iOut) % counterPeriod).U -> iIn.U
      ))
    )
  }
}

object Scrambler {
  def apply[T <: Data](gen: T, in: Seq[T], numOutputs: Int): Vec[DecoupledIO[T]] = {
    val m = Module(new Scrambler(gen, in.length, numOutputs))
    m.io.in.zip(in).foreach{case(a, b) => a <> b}
    m.io.out
  }
}

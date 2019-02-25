package fpgamshr.util

import chisel3._
import chisel3.util.{MuxCase, log2Ceil, isPow2}

abstract class UpDownLoadableCounter extends Module {
  val io: UpDownLoadableCounterIO
  def connect(increment: UInt, decrement: UInt, load: Bool, loadValue: Data) = {
    io.increment := increment
    io.decrement := decrement
    io.load := load
    io.loadValue := loadValue
  }
}

class UpDownLoadableCounterIO(width: Int) extends Bundle {
  val increment = Input(Bool())
  val decrement = Input(Bool())
  val load = Input(Bool())
  val loadValue = Input(UInt(width.W))
  val currValue = Output(UInt(width.W))
}

class SaturatingUpDownLoadableCounterIO(width: Int) extends UpDownLoadableCounterIO(width) {
  val saturatingUp = Output(Bool())
  val saturatingDown = Output(Bool())
}

object SimultaneousUpDownSaturatingCounter {
  def apply(maxVal: Int, increment: UInt, decrement: UInt, load: Bool=false.B, loadValue: Data=DontCare, resetVal: Int=0): UInt = {
    val m = Module(new SimultaneousUpDownSaturatingCounter(maxVal, resetVal))
    m.connect(increment=increment, decrement=decrement, load=load, loadValue=loadValue)
    m.io.currValue
  }
}

object ExclusiveUpDownSaturatingCounter {
  def apply(maxVal: Int, upDownN: Bool, en: Bool=true.B, load: Bool=false.B, loadValue: Data=DontCare, resetVal: Int=0): UInt = {
    val m = Module(new SimultaneousUpDownSaturatingCounter(maxVal, resetVal))
    m.connect(increment=(upDownN & en),
      decrement=(~upDownN & en),
      load=load,
      loadValue=loadValue)
    m.io.currValue
  }
}

object ExclusiveUpDownWrappingCounter {
  def apply(maxVal: Int, upDownN: Bool, en: Bool=true.B, load: Bool=false.B, loadValue: Data=DontCare, resetVal: Int=0): UInt = {
    val m = Module(new SimultaneousUpDownSaturatingCounter(maxVal, resetVal))
    m.connect(increment=(upDownN & en),
      decrement=(~upDownN & en),
      load=load,
      loadValue=loadValue)
    m.io.currValue
  }
}

class SimultaneousUpDownSaturatingCounter(maxVal: Int, resetVal: Int=0) extends UpDownLoadableCounter {
  val width = BigInt(maxVal).bitLength
  val io = IO(new SaturatingUpDownLoadableCounterIO(width))

  val saturatingIncrement = Mux(io.currValue < maxVal.U, io.currValue + 1.U, io.currValue)
  val saturatingDecrement = Mux(io.currValue > 0.U, io.currValue - 1.U, io.currValue)
  io.currValue := RegNext(MuxCase(io.currValue, Array(io.load -> io.loadValue,
    (io.increment & io.decrement) -> io.currValue,
    io.increment -> saturatingIncrement,
    io.decrement -> saturatingDecrement)), init=resetVal.U)

  io.saturatingUp := io.currValue === maxVal.U
  io.saturatingDown := io.currValue === 0.U
}

class SimultaneousUpDownWrappingCounter(maxVal: Int, resetVal: Int=0) extends UpDownLoadableCounter {
  val width = BigInt(maxVal).bitLength
  val io = IO(new UpDownLoadableCounterIO(width))

  val saturatingIncrement = if(isPow2(maxVal)) {io.currValue + 1.U} else {Mux(io.currValue < maxVal.U, io.currValue + 1.U, 0.U)}
  val saturatingDecrement = if(isPow2(maxVal)) {io.currValue - 1.U} else {Mux(io.currValue > 0.U, io.currValue - 1.U, maxVal.U)}
  io.currValue := RegNext(MuxCase(io.currValue, Array(io.load -> io.loadValue,
    (io.increment & io.decrement) -> io.currValue,
    io.increment -> saturatingIncrement,
    io.decrement -> saturatingDecrement)), init=resetVal.U)

}

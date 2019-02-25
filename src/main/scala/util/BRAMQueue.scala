package fpgamshr.util

import chisel3._
import chisel3.util._
import fpgamshr.interfaces._
import fpgamshr.util._

class BRAMQueue(dataWidth: Int, depth: Int, resetCount: Int=0, almostEmptyMargin: Int=0, initFilePath: String="") extends Module {
    val addrWidth = log2Ceil(depth)
    val io = IO(new Bundle {
        val enq = DecoupledIO(UInt(dataWidth.W)).flip
        val deq = DecoupledIO(UInt(dataWidth.W))
        val count = Output(UInt((addrWidth+1).W))
        val almostEmpty = Output(Bool())
    })

    val memory = Module(new XilinxSimpleDualPortNoChangeBRAM(width=dataWidth, depth=depth, initFile=initFilePath))

    memory.io.clock := clock
    memory.io.reset := reset
    val full = Wire(Bool())
    val empty = Wire(Bool())
    val wrEn = io.enq.valid & ~full

    /* Enqueue side */
    /* Nothing fancy here */
    val enqPtr = Counter(wrEn, depth)
    memory.io.addra := enqPtr._1
    memory.io.wea := wrEn
    memory.io.dina := io.enq.bits

    /* Dequeue side */
    /* To minimize latency and avoid bubbles despite the fact that the memory
     * has a 2-cycle latency, we try to always fill up the output 2-stage
     * pipeline. For this reason, we distinguish the situation where the entire
     * FIFO is empty (when empty = true) from that of only the BRAM is empty,
     * but there may be some valid elements in the output pipeline
     * (bramEmpty = true). */
    val bramEmpty = Wire(Bool())
    val rdEn = Wire(Bool())
    val deqPtr = Counter(rdEn, depth)
    memory.io.addrb := deqPtr._1
    val enb = Wire(Bool())
    val regceb = Wire(Bool())
    val valid0 = RegEnable(~bramEmpty, init=false.B, enable=enb)
    enb := (~bramEmpty & ~valid0) | regceb
    memory.io.enb := enb
    rdEn := enb & ~bramEmpty
    val valid1 = RegEnable(valid0, init=false.B, enable=regceb)
    regceb := (valid0 & ~valid1) | io.deq.ready
    memory.io.regceb := regceb
    io.deq.valid := valid1
    io.deq.bits := memory.io.doutb

    /* Element counter */
    val elemCounter = Module(new SimultaneousUpDownSaturatingCounter(depth, resetCount))
    elemCounter.io.increment := wrEn
    elemCounter.io.decrement := rdEn
    elemCounter.io.load := false.B
    elemCounter.io.loadValue := DontCare
    full := elemCounter.io.saturatingUp
    bramEmpty := elemCounter.io.saturatingDown
    empty := bramEmpty & ~valid0 & ~valid1
    io.enq.ready := ~full

    when(valid0 & valid1) {
        io.count := elemCounter.io.currValue + 2.U
    } .elsewhen(valid0 | valid1) {
        io.count := elemCounter.io.currValue + 1.U
    } .otherwise {
        io.count := elemCounter.io.currValue
    }

    io.almostEmpty := io.count <= almostEmptyMargin.U
}

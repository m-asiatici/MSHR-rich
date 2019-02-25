package tlastgen

import chisel3._
import chisel3.util._

class DataAndLast(width: Int) extends Bundle {
    val data = UInt(width.W)
    val last = Bool()
    override def cloneType = (new DataAndLast(width)).asInstanceOf[this.type]
}

class TLASTGenerator extends Module {
    val io=IO(new Bundle{
        val mult_res = Flipped(DecoupledIO(UInt(32.W)))
        val row_len = Flipped(DecoupledIO(UInt(32.W)))
        val out = DecoupledIO(new DataAndLast(32))
    })

    val sIdle :: sCount :: Nil = Enum(2)

    val state = RegInit(sIdle)

    val count = Reg(UInt(32.W))
    switch(state) {
        is(sIdle) {
            when(io.row_len.valid && (io.row_len.bits =/= 0.U) && io.mult_res.valid && io.out.ready && (io.row_len.bits =/= 1.U)) {
                state := sCount
            }
        }
        is(sCount) {
            when(io.out.ready && io.mult_res.valid && (count === io.row_len.bits - 1.U)) {
                state := sIdle
            }
        }
    }


    io.out.bits.data := io.mult_res.bits
    io.out.bits.last := false.B
    io.out.valid := false.B
    io.row_len.ready := false.B
    io.mult_res.ready := false.B
    switch(state) {
        is(sIdle) {
            count := 0.U
            when(io.row_len.valid) {
                when(io.row_len.bits === 0.U) {
                    io.out.bits.data := 0.U /* = 0.0f */
                    io.out.bits.last := true.B
                    io.out.valid := true.B
                    io.row_len.ready := io.out.ready
                } .elsewhen(io.mult_res.valid) {
                    io.out.bits.data := io.mult_res.bits
                    io.out.valid := true.B
                    io.out.bits.last := io.row_len.bits === 1.U
                    when(io.out.ready) {
                        io.mult_res.ready := true.B
                        when(io.row_len.bits === 1.U) {
                          io.row_len.ready := true.B
                        } .otherwise {
                          count := count + 1.U
                        }
                    }
                }
            }
        }
        is(sCount) {
            when(io.out.ready && io.mult_res.valid) {
                io.out.bits.data := io.mult_res.bits
                io.out.valid := true.B
                count := count + 1.U
                io.mult_res.ready := true.B
                when(count === io.row_len.bits - 1.U) {
                    io.out.bits.last := true.B
                    io.row_len.ready := true.B
                    count := 0.U
                }
            }
        }
    }
}

/**
  * To just generate the Verilog for the TLASTGenerator, run:
  * {{{
  * test:runMain tlastgen.TLASTGenerator
  * }}}
  */

object TLASTGenerator extends App {
    chisel3.Driver.execute(args, () => new TLASTGenerator)
}

package fpgamshr.interfaces

import chisel3._
import chisel3.util._
import fpgamshr.profiling._

class CacheIO(addrWidth: Int, idWidth: Int, reqDataWidth: Int, memDataWidth: Int, sizeReductionWidth: Int) extends Bundle {
    /* Incoming requests */
    val inReq = DecoupledIO(new AddrIdIO(addrWidth, idWidth)).flip
    /* If they miss, they are just forwarded as they are to this interface */
    val outMisses = DecoupledIO(new AddrIdIO(addrWidth, idWidth))
    /* Responses of requests that hit */
    val outData = DecoupledIO(new DataIdIO(reqDataWidth, idWidth))
    /* New cache lines coming from memory */
    val inData = DecoupledIO(new AddrDataIO(addrWidth, memDataWidth)).flip
    /* Profiling */
    val axiProfiling = new AXI4LiteReadOnlyProfiling(Profiling.dataWidth, Profiling.regAddrWidth)
    /* Control */
    val invalidate = Input(Bool())
    val enabled = Input(Bool())
    val log2SizeReduction = Input(UInt(sizeReductionWidth.W))
}

class CacheLineNoValid(val tagWidth: Int, val dataWidth: Int) extends Bundle with HasTag with HasData {
  override def cloneType = (new CacheLineNoValid(tagWidth, dataWidth)).asInstanceOf[this.type]
}

class CacheLine(val tagWidth: Int, val dataWidth: Int)
  extends Bundle with HasTag with HasData with HasValid {
    override def cloneType = (new CacheLine(tagWidth, dataWidth)).asInstanceOf[this.type]
}

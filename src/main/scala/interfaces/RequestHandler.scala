package fpgamshr.interfaces

import chisel3._
import chisel3.util._
import fpgamshr.profiling._
import fpgamshr.reqhandler.cuckoo.{CuckooMSHR}

class RequestHandlerIO(addrWidth: Int, tagWidth: Int, reqDataWidth: Int, idWidth: Int, memDataWidth: Int, cacheSizeReductionWidth: Int, numMSHRWidth: Int) extends Bundle {
    val inReq = new DecAddrIdDecDataIdIO(addrWidth, reqDataWidth, idWidth)
    val outMemReq = DecoupledIO(UInt(tagWidth.W))
    val inMemResp = DecoupledIO(new AddrDataIO(tagWidth, memDataWidth)).flip
    val invalidate = Input(Bool()) /* Trigger cache invalidation */
    val log2CacheSizeReduction = Input(UInt(cacheSizeReductionWidth.W))
    val maxAllowedMSHRs = Input(UInt(numMSHRWidth.W))
    val enableCache = Input(Bool())
    val axiProfiling = new AXI4LiteReadOnlyProfiling(Profiling.dataWidth, Profiling.regAddrWidth + Profiling.subModuleAddrWidth)
}

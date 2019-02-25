package fpgamshr.reqhandler.cuckoo

import chisel3._
import fpgamshr.interfaces._
import fpgamshr.util._
import chisel3.util._
import fpgamshr.profiling._
import fpgamshr.reqhandler.ResponseGeneratorOneOutputArbitraryEntriesPerRow

/* Test configurations:
 - trigger MSHRAlmostFull:
 val numLevelComparators = 2
 val numSplPerLevelComparator = 3
 val numMSHRPerRow = numSplPerLevelComparator
 val numSubentriesPerRow = 4
 val mshrAlmostFullRelMargin = 0.5
 p_change = 0.5
 previous_tag_window_width = 20
 - trigger stopAlloc:
 val numLevelComparators = 2
 val numSplPerLevelComparator = 3
 val numMSHRPerRow = numSplPerLevelComparator
 val numSubentriesPerRow = 4
 val subentriesAddrWidth = 5
 p_change = 0.1
 previous_tag_window_width = 10
 - cache:
 p_change = 0.05
 previous_tag_window_width = 10
 MIN_MEM_LATENCY = 1
 MAX_MEM_LATENCY = 1
 */

object RequestHandler {
    val reqAddrWidth = 28   /* Excluding the part that is always 0, i.e. the log2Ceil(reqDataWidth) least significant bits, and the req handler address (log2Ceil(numReqHandlers)) */
    val reqDataWidth = 32
    val reqIdWidth = 22     /* Original ID width + input port address (log2Ceil(numInputPorts)) */
    val memDataWidth = 512

    val numHashTables = 4
    val numMSHRPerHashTable = 128
    val mshrAssocMemorySize = 6

    val numMSHRWidth = log2Ceil(numHashTables * numMSHRPerHashTable)

    val numSubentriesPerRow = 4
    val subentriesAddrWidth = 11
    val numCacheWays = 4
    val cacheSizeBytes = 4096
    val cacheSizeReductionWidth = 2
    val nextPtrCacheSize = 8

    /* Set to >= 0.5 to actually trigger MSHRAlmostFullMargin (for testing, for example) */
    val mshrAlmostFullRelMargin = 0.0 /* As fraction of total number of MSHRs */
    // val branchAddrWidth = numLevelComparators * log2Ceil(numSplPerLevelComparator + 1)
    val responseGeneratorPorts = 1 /* More ports are supported by the responseGenerator but not by the RequestHandler */
}

class RequestHandlerBase(reqAddrWidth: Int=RequestHandler.reqAddrWidth, reqDataWidth: Int=RequestHandler.reqDataWidth, reqIdWidth: Int=RequestHandler.reqIdWidth, memDataWidth: Int=RequestHandler.memDataWidth, cacheSizeReductionWidth: Int=RequestHandler.cacheSizeReductionWidth, numMSHRWidth: Int=0) extends Module {
    require(isPow2(memDataWidth / reqDataWidth))
    require(RequestHandler.responseGeneratorPorts == 1)
    val offsetWidth = log2Ceil(memDataWidth / reqDataWidth)
    val tagWidth = reqAddrWidth - offsetWidth
    val io = IO(new RequestHandlerIO(reqAddrWidth, tagWidth, reqDataWidth, reqIdWidth, memDataWidth, cacheSizeReductionWidth, numMSHRWidth))
}

class RequestHandlerCuckoo(reqAddrWidth: Int=RequestHandler.reqAddrWidth, reqDataWidth: Int=RequestHandler.reqDataWidth, reqIdWidth: Int=RequestHandler.reqIdWidth, memDataWidth: Int=RequestHandler.memDataWidth, numHashTables: Int=RequestHandler.numHashTables, numMSHRPerHashTable: Int=RequestHandler.numMSHRPerHashTable, mshrAssocMemorySize: Int=RequestHandler.mshrAssocMemorySize, numSubentriesPerRow: Int=RequestHandler.numSubentriesPerRow, subentriesAddrWidth: Int=RequestHandler.subentriesAddrWidth, numCacheWays: Int=RequestHandler.numCacheWays, cacheSizeBytes: Int=RequestHandler.cacheSizeBytes, cacheSizeReductionWidth: Int=RequestHandler.cacheSizeReductionWidth, numMSHRWidth: Int=RequestHandler.numMSHRWidth, nextPtrCacheSize: Int=RequestHandler.nextPtrCacheSize, blockOnNextPtr: Boolean=false, sameHashFunction: Boolean=false) extends RequestHandlerBase(reqAddrWidth, reqDataWidth, reqIdWidth, memDataWidth, cacheSizeReductionWidth, numMSHRWidth) {
  /* Cache */
  val cache: Cache =
      if(numCacheWays > 0 && cacheSizeBytes > 0) {
          Module(new RRCache(reqAddrWidth, reqIdWidth, reqDataWidth, memDataWidth, numCacheWays, cacheSizeBytes, cacheSizeReductionWidth))
      } else {
          Module(new DummyCache(reqAddrWidth, reqIdWidth, reqDataWidth, memDataWidth, cacheSizeReductionWidth))
      }

  cache.io.inReq <> io.inReq.addr
  cache.io.log2SizeReduction := io.log2CacheSizeReduction
  cache.io.invalidate := io.invalidate
  cache.io.enabled := io.enableCache

  val totalNumMSHR = numHashTables * numMSHRPerHashTable
  // mshrAlmostFullMargin can now be redefined at runtime via axiProfiling interface
  // val mshrAlmostFullMargin = (totalNumMSHR * RequestHandler.mshrAlmostFullRelMargin).toInt
  val mshrManager = Module(new CuckooMSHR(reqAddrWidth, numMSHRPerHashTable, numHashTables,reqIdWidth, memDataWidth, reqDataWidth, subentriesAddrWidth, 0, mshrAssocMemorySize, sameHashFunction))

  mshrManager.io.allocIn <> cache.io.outMisses
  mshrManager.io.allocIn.bits.addr := Cat(cache.io.outMisses.bits.addr(reqAddrWidth-1, offsetWidth), cache.io.outMisses.bits.addr(offsetWidth-1, 0))
  mshrManager.io.allocIn.bits.id := cache.io.outMisses.bits.id
  mshrManager.io.allocIn.valid := cache.io.outMisses.valid
  cache.io.outMisses.ready := mshrManager.io.allocIn.ready
  val inMemRespEagerFork = Module(new EagerFork(new AddrDataIO(reqAddrWidth, memDataWidth), 2))
  val inMemRespEb = ElasticBuffer(io.inMemResp)

  inMemRespEagerFork.io.in.bits.data := inMemRespEb.bits.data
  inMemRespEagerFork.io.in.bits.addr := Cat(inMemRespEb.bits.addr, 0.U(offsetWidth.W))
  inMemRespEagerFork.io.in.valid := inMemRespEb.valid
  inMemRespEb.ready := inMemRespEagerFork.io.in.ready
  mshrManager.io.deallocIn <> inMemRespEagerFork.io.out(0)
  cache.io.inData.bits.addr := Cat(inMemRespEagerFork.io.out(1).bits.addr(reqAddrWidth-1, offsetWidth), inMemRespEagerFork.io.out(1).bits.addr(offsetWidth-1, 0))
  cache.io.inData.bits.data := inMemRespEagerFork.io.out(1).bits.data
  cache.io.inData.valid := inMemRespEagerFork.io.out(1).valid
  inMemRespEagerFork.io.out(1).ready := cache.io.inData.ready

  // mshrManager.io.outMem <> io.outMemReq
  mshrManager.io.outMem <> io.outMemReq
  mshrManager.io.maxAllowedMSHRs := io.maxAllowedMSHRs

  /* SubentryBuffer */
  val subentryBuffer = Module(new SubentryBuffer(reqIdWidth, memDataWidth, reqDataWidth, subentriesAddrWidth, numSubentriesPerRow, MSHR.pipelineLatency, nextPtrCacheSize, blockOnNextPtr))
  subentryBuffer.io.in <> mshrManager.io.outLdBuf
  subentryBuffer.io.frqOut <> mshrManager.io.frqIn
  mshrManager.io.stopAllocFromLdBuf := subentryBuffer.io.stopAlloc

  /* ResponseGenerator */
  // val responseGenerator = Module(new ResponseGenerator(reqIdWidth, memDataWidth, reqDataWidth, numSubentriesPerRow, RequestHandler.responseGeneratorPorts))
  val responseGenerator = Module(new ResponseGeneratorOneOutputArbitraryEntriesPerRow(reqIdWidth, memDataWidth, reqDataWidth, numSubentriesPerRow))
  responseGenerator.io.in <> subentryBuffer.io.respGenOut

  /* Returned data */
  val returnedDataArbiter = Module(new ResettableRRArbiter(new DataIdIO(reqDataWidth, reqIdWidth), 2))
  returnedDataArbiter.io.in(0) <> cache.io.outData
  returnedDataArbiter.io.in(1) <> responseGenerator.io.out
  returnedDataArbiter.io.out <> io.inReq.data

  /* Profiling */
  if (Profiling.enable) {
      val subModulesProfilingInterfaces = Array(cache.io.axiProfiling, mshrManager.io.axiProfiling, subentryBuffer.io.axiProfiling, responseGenerator.io.axiProfiling)
      require(Profiling.subModuleAddrWidth >= log2Ceil(subModulesProfilingInterfaces.length))
      val profilingAddrDecoupledIO = Wire(DecoupledIO(UInt((Profiling.regAddrWidth + Profiling.subModuleAddrWidth).W)))
      profilingAddrDecoupledIO.bits := io.axiProfiling.axi.ARADDR
      profilingAddrDecoupledIO.valid := io.axiProfiling.axi.ARVALID
      io.axiProfiling.axi.ARREADY := profilingAddrDecoupledIO.ready
      val profilingSelector = ProfilingSelector(profilingAddrDecoupledIO, subModulesProfilingInterfaces, io.axiProfiling.clear, io.axiProfiling.snapshot)
      io.axiProfiling.axi.RDATA := profilingSelector.bits
      io.axiProfiling.axi.RVALID := profilingSelector.valid
      profilingSelector.ready := io.axiProfiling.axi.RREADY
      io.axiProfiling.axi.RRESP := 0.U
  } else {
      io.axiProfiling.axi.ARREADY := false.B
      io.axiProfiling.axi.RVALID := false.B
      io.axiProfiling.axi.RDATA := DontCare
      io.axiProfiling.axi.RRESP := DontCare
  }
}

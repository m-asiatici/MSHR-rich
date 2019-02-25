package fpgamshr.reqhandler.traditional

import chisel3._
import fpgamshr.interfaces._
import fpgamshr.util._
import chisel3.util._
import fpgamshr.profiling._
import fpgamshr.reqhandler.cuckoo.{RequestHandlerBase}
import fpgamshr.reqhandler.ResponseGeneratorOneOutputArbitraryEntriesPerRow

object RequestHandlerTraditional {
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

class RequestHandlerBlockingCache(reqAddrWidth: Int=RequestHandlerTraditional.reqAddrWidth, reqDataWidth: Int=RequestHandlerTraditional.reqDataWidth, reqIdWidth: Int=RequestHandlerTraditional.reqIdWidth, memDataWidth: Int=RequestHandlerTraditional.memDataWidth, numCacheWays: Int=RequestHandlerTraditional.numCacheWays, cacheSizeBytes: Int=RequestHandlerTraditional.cacheSizeBytes, cacheSizeReductionWidth: Int=RequestHandlerTraditional.cacheSizeReductionWidth) extends RequestHandlerBase(reqAddrWidth, reqDataWidth, reqIdWidth, memDataWidth, cacheSizeReductionWidth, 0) {
    val maxOffset = (1 << offsetWidth) - 1

    def getTag(input: UInt, addrWidth: Int=reqAddrWidth, tagWidth: Int=tagWidth): UInt = input(addrWidth - 1, addrWidth - tagWidth)
    def getOffset(input: UInt, offsetWidth: Int=offsetWidth): UInt = input(offsetWidth - 1, 0)

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

    /* Fork for the request coming from outMisses, between outMem and inReq.data */
    val missFork = Module(new EagerFork(cache.io.outMisses.bits.cloneType, 2))
    missFork.io.in <> cache.io.outMisses
    io.outMemReq.bits := getTag(missFork.io.out(0).bits.addr)
    io.outMemReq.valid := missFork.io.out(0).valid
    missFork.io.out(0).ready := io.outMemReq.ready

    /* Fork for the received data, between cache write port and inReq.data */
    val inMemRespEagerFork = Module(new EagerFork(new AddrDataIO(reqAddrWidth, memDataWidth), 2))
    val inMemRespEb = ElasticBuffer(io.inMemResp)

    inMemRespEagerFork.io.in.bits.data := inMemRespEb.bits.data
    inMemRespEagerFork.io.in.bits.addr := Cat(inMemRespEb.bits.addr, 0.U(offsetWidth.W))
    inMemRespEagerFork.io.in.valid := inMemRespEb.valid
    inMemRespEb.ready := inMemRespEagerFork.io.in.ready

    /* No need to check if the received tag corresponds to the one of the miss, as there
     * will always be only one outstanding read at any time. */
    val missOffset = getOffset(missFork.io.out(1).bits.addr)
    val missId = missFork.io.out(1).bits.id
    /* Select the requested data within the cache line that we just received */
    val dataMuxMappings = (0 to maxOffset).map(offset => (offset.U -> inMemRespEagerFork.io.out(0).bits.data((offset + 1) * reqDataWidth - 1, offset * reqDataWidth)))
    val missData = MuxLookup(missOffset, inMemRespEagerFork.io.out(0).bits.data(reqDataWidth-1, 0), dataMuxMappings)
    /* We add an EB between miss matching/selection logic and the returned data arbiter */
    val missEb = Module(new ElasticBuffer(io.inReq.data.bits.cloneType))
    missEb.io.in.bits.data := missData
    missEb.io.in.bits.id := missId
    missEb.io.in.valid := inMemRespEagerFork.io.out(0).valid & missFork.io.out(1).valid
    inMemRespEagerFork.io.out(0).ready := missEb.io.in.ready
    missFork.io.out(1).ready := missEb.io.in.ready & missEb.io.in.valid
    cache.io.inData <> inMemRespEagerFork.io.out(1)

    /* Returned data */
    val returnedDataArbiter = Module(new ResettableRRArbiter(new DataIdIO(reqDataWidth, reqIdWidth), 2))
    returnedDataArbiter.io.in(0) <> cache.io.outData
    returnedDataArbiter.io.in(1) <> missEb.io.out
    returnedDataArbiter.io.out <> io.inReq.data

    /* Profiling */
    if (Profiling.enable) {
        val subModulesProfilingInterfaces = Array(cache.io.axiProfiling, cache.io.axiProfiling, cache.io.axiProfiling, cache.io.axiProfiling)
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

object RequestHandlerTraditionalMSHR {
  val numMSHR = 4
}

class RequestHandlerTraditionalMSHR(reqAddrWidth: Int=RequestHandlerTraditional.reqAddrWidth, reqDataWidth: Int=RequestHandlerTraditional.reqDataWidth, reqIdWidth: Int=RequestHandlerTraditional.reqIdWidth, memDataWidth: Int=RequestHandlerTraditional.memDataWidth, numMSHR: Int=RequestHandlerTraditionalMSHR.numMSHR, numSubentriesPerRow: Int=RequestHandlerTraditional.numSubentriesPerRow, numCacheWays: Int=RequestHandlerTraditional.numCacheWays, cacheSizeBytes: Int=RequestHandlerTraditional.cacheSizeBytes, cacheSizeReductionWidth: Int=RequestHandlerTraditional.cacheSizeReductionWidth) extends RequestHandlerBase(reqAddrWidth, reqDataWidth, reqIdWidth, memDataWidth, cacheSizeReductionWidth, 0) {
    require(isPow2(numSubentriesPerRow))
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

    val inMemRespEagerFork = Module(new EagerFork(new AddrDataIO(reqAddrWidth, memDataWidth), 2))
    val inMemRespEb = ElasticBuffer(io.inMemResp)
    inMemRespEagerFork.io.in.bits.data := inMemRespEb.bits.data
    inMemRespEagerFork.io.in.bits.addr := Cat(inMemRespEb.bits.addr, 0.U(offsetWidth.W))
    inMemRespEagerFork.io.in.valid := inMemRespEb.valid
    inMemRespEb.ready := inMemRespEagerFork.io.in.ready
    cache.io.inData.bits.addr := Cat(inMemRespEagerFork.io.out(1).bits.addr(reqAddrWidth-1, offsetWidth),inMemRespEagerFork.io.out(1).bits.addr(offsetWidth-1, 0))
    cache.io.inData.bits.data := inMemRespEagerFork.io.out(1).bits.data
    cache.io.inData.valid := inMemRespEagerFork.io.out(1).valid
    inMemRespEagerFork.io.out(1).ready := cache.io.inData.ready

    val mshrManager = Module(new MSHRTraditional(reqAddrWidth, numMSHR, numSubentriesPerRow, reqIdWidth, memDataWidth, reqDataWidth))
    mshrManager.io.allocIn <> cache.io.outMisses
    mshrManager.io.deallocIn <> inMemRespEagerFork.io.out(0)
    mshrManager.io.outMem <> io.outMemReq

    /* SubentryBuffer */
    val subentryBuffer = Module(new SubentryBufferTraditional(reqIdWidth, memDataWidth, reqDataWidth, mshrManager.io.outLdBuf.bits.rowAddr.getWidth, numSubentriesPerRow))
    subentryBuffer.io.in <> mshrManager.io.outLdBuf

    /* ResponseGenerator */
    /* Since we may send one more load buffer entry (when the MSHR was stall due to running)
     * out of load buffers, and we receive the data that can satisfy that full MSHR),
     * numSubentriesPerRow will not be a power of 2. */
    val responseGenerator = Module(new ResponseGeneratorOneOutputArbitraryEntriesPerRow(reqIdWidth, memDataWidth, reqDataWidth, numSubentriesPerRow + 1))
    responseGenerator.io.in <> subentryBuffer.io.respGenOut

    /* Returned data */
    val returnedDataArbiter = Module(new ResettableRRArbiter(new DataIdIO(reqDataWidth, reqIdWidth), 2))
    returnedDataArbiter.io.in(0) <> cache.io.outData
    returnedDataArbiter.io.in(1) <> responseGenerator.io.out
    returnedDataArbiter.io.out <> io.inReq.data

    if (Profiling.enable) {
        //println("RequestHandler")
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

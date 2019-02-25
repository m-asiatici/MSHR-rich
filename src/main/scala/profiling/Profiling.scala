package fpgamshr.profiling

import chisel3._
import chisel3.util._
import fpgamshr.interfaces._
import fpgamshr.util._

object Profiling {
  val dataWidth = 64
  val regAddrWidth = 7
  val subModuleAddrWidth = 2 /* Currently, only the RequestHandler has submodules with profiling: Cache, MSHR, SubentryBuffer and ResponseGenerator */
  val enable = true
  val enableHistograms = false /* Enable histograms for the number of cycles where at least 2^N registers in MSHR and SubentryBuffer were used.
                                  Very informative but resource-hungry and harms critical path because of the large MUX when reading the profiling registers. */
}

object ProfilingInterface {
    def apply(inAddr: DecoupledIO[UInt], inRegs: Vec[UInt]) = {
        val m = Module(new ProfilingInterface(inAddr.bits.getWidth, Profiling.dataWidth, inRegs.length))
        m.io.inAddr <> inAddr
        m.io.inRegs := inRegs
        m.io.outData
    }

    def apply(inAXI: AXI4LiteReadOnly[UInt], inRegs: Vec[UInt]) = {
        val m = Module(new ProfilingInterface(inAXI.ARADDR.getWidth, Profiling.dataWidth, inRegs.length))
        val inAddr = Wire(DecoupledIO(m.io.inAddr.bits.cloneType))
        inAddr.bits := inAXI.ARADDR
        inAddr.valid := inAXI.ARVALID
        inAXI.ARREADY := inAddr.ready
        m.io.inAddr <> inAddr
        m.io.inRegs := inRegs
        m.io.outData
    }
}

class ProfilingInterface(addrWidth: Int, dataWidth: Int, numInputs: Int) extends Module {
    require(addrWidth >= log2Ceil(numInputs))
    val io = IO(new Bundle{
      val inAddr = DecoupledIO(UInt(addrWidth.W)).flip
      val outData = DecoupledIO(UInt(dataWidth.W))
      val inRegs = Input(Vec(numInputs, UInt(dataWidth.W)))
    })

    // val inEb = ElasticBuffer(io.inAddr)
    val emptyRequest = Wire(ValidIO(io.inAddr.bits.cloneType))
    emptyRequest.valid := false.B
    emptyRequest.bits := DontCare
    val delayedInAddr = RegInit(emptyRequest)
    val emptyResponse = Wire(ValidIO(io.outData.bits.cloneType))
    emptyResponse.valid := false.B
    emptyResponse.bits := DontCare
    val outDataReg = RegInit(emptyResponse)
    when(io.outData.ready | ~io.outData.valid) {
      delayedInAddr.valid := io.inAddr.valid
      delayedInAddr.bits  := io.inAddr.bits
      outDataReg.bits := MuxLookup(delayedInAddr.bits, io.inRegs(0), (0 until numInputs).map(i => (i.U -> io.inRegs(i))))
      outDataReg.valid := delayedInAddr.valid
    }
    io.inAddr.ready := io.outData.ready | ~io.outData.valid

    io.outData.bits := outDataReg.bits
    io.outData.valid := outDataReg.valid
    // inEb.ready := io.outData.ready
}

object ProfilingSelector {
    def apply(in: DecoupledIO[UInt], subModulesAXIProfiling: Seq[AXI4LiteReadOnlyProfiling], clear: Bool, snapshot: Bool): DecoupledIO[UInt] = {
        val numSubModules = subModulesAXIProfiling.length
        val selector = Module(new ProfilingSelector(in.bits.getWidth, Profiling.dataWidth, numSubModules))
        val width = in.bits.getWidth
        // println(s"in.bits.getWidth=$width")
        // println(s"numSubModules=$numSubModules")
        selector.io.in <> in
        for(i <- 0 until numSubModules) {
            subModulesAXIProfiling(i).axi.ARADDR := selector.io.submodulesReq(i).bits
            subModulesAXIProfiling(i).axi.ARVALID := selector.io.submodulesReq(i).valid
            selector.io.submodulesReq(i).ready := subModulesAXIProfiling(i).axi.ARREADY

            selector.io.submodulesResp(i).bits := subModulesAXIProfiling(i).axi.RDATA
            selector.io.submodulesResp(i).valid := subModulesAXIProfiling(i).axi.RVALID
            subModulesAXIProfiling(i).axi.RREADY := selector.io.submodulesResp(i).ready

            subModulesAXIProfiling(i).clear := clear
            subModulesAXIProfiling(i).snapshot := snapshot
        }
        selector.io.out
    }

    // def apply(in: DecoupledIO[UInt], subModuleAddrWidth: Int, subModulesAXIProfiling: Seq[AXI4LiteReadOnlyProfiling], clear: Bool, snapshot: Bool, outputEb: Boolean) = {
    //     val numSubModules = subModulesAXIProfiling.length
    //     require(subModuleAddrWidth >= log2Ceil(numSubModules))
    //     val selector = Module(new ProfilingSelector(subModuleAddrWidth, Profiling.dataWidth, numSubModules))
    //     selector.io.in <> in
    //     for(i <- 0 until numSubModules) {
    //         subModulesAXIProfiling(i).axi.ARADDR := selector.io.submodulesReq(i).bits
    //         subModulesAXIProfiling(i).axi.ARVALID := selector.io.submodulesReq(i).valid
    //         selector.io.submodulesReq(i).ready := subModulesAXIProfiling(i).axi.ARREADY
    //
    //         selector.io.submodulesResp(i).bits := subModulesAXIProfiling(i).axi.RDATA
    //         selector.io.submodulesResp(i).valid := subModulesAXIProfiling(i).axi.RVALID
    //         subModulesAXIProfiling(i).axi.RREADY := selector.io.submodulesResp(i).ready
    //
    //         subModulesAXIProfiling(i).clear := clear
    //         subModulesAXIProfiling(i).snapshot := snapshot
    //     }
    //     if (outputEb) ElasticBuffer(selector.io.out) else selector.io.out
    // }
}

class ProfilingSelector(addrWidth: Int, dataWidth: Int, numSubModules: Int) extends Module {
    // println(s"addrWidth=$addrWidth")
    val subModuleSelWidth = log2Ceil(numSubModules)
    // println(s"subModuleSelWidth=$subModuleSelWidth")
    val subModuleAddrWidth = addrWidth - subModuleSelWidth
    // println(s"subModuleAddrWidth=$subModuleAddrWidth")
    val io = IO(new Bundle{
        /* Address from the top level (input) */
        val in = DecoupledIO(UInt(addrWidth.W)).flip
        /* Address to the submodules (output) */
        val submodulesReq = Vec(numSubModules, DecoupledIO(UInt(subModuleAddrWidth.W)))
        /* Responses (data) from the submodules (input) */
        val submodulesResp = Vec(numSubModules, DecoupledIO(UInt(dataWidth.W))).flip
        /* Response to the top level (output) */
        val out = DecoupledIO(UInt(dataWidth.W))
    })

    val currSubModuleSel  = io.in.bits(subModuleAddrWidth + subModuleSelWidth - 1, subModuleAddrWidth)
    val currSubModuleAddr = io.in.bits(subModuleAddrWidth-1, 0)
    for(i <- 0 until numSubModules) {
        io.submodulesReq(i).valid := io.in.valid & (currSubModuleSel === i.U)
        io.submodulesReq(i).bits := currSubModuleAddr
        io.submodulesResp(i).ready := io.out.ready | ~io.out.valid
    }
    val emptyResponse = Wire(ValidIO(io.out.bits.cloneType))
    emptyResponse.valid := false.B
    emptyResponse.bits := DontCare
    val outReg = RegInit(emptyResponse)
    when(io.out.ready | ~io.out.valid) {
      outReg.valid := Vec(io.submodulesResp.map(m => m.valid)).asUInt.orR
      outReg.bits  := Mux1H(io.submodulesResp.map(m => (m.valid -> m.bits)))
    }
    io.in.ready := io.out.ready | ~io.out.valid
    io.out.valid := outReg.valid
    io.out.bits := outReg.bits
}

object ProfilingCounter {
  def apply(en: Bool, width: Int, snapshot: Bool, clear: Bool) : UInt = {
    val c = Module(new ProfilingCounter(width))
    c.io.en := en
    c.io.snapshot := snapshot
    c.io.clear := clear
    c.io.snapshotValue
  }

  def apply(en: Bool, axiProfiling: AXI4LiteReadOnlyProfiling, width: Int=Profiling.dataWidth) : UInt =
    apply(en, width, axiProfiling.snapshot, axiProfiling.clear)
}

/* A counter that counts the number of cycles during which en was enabled */
class ProfilingCounter(width: Int) extends Module {
    val io = IO(new Bundle{
      val en = Input(Bool())
      val snapshot = Input(Bool())
      val clear = Input(Bool())
      val snapshotValue = Output(UInt(width.W))
    })

    val count = RegInit(0.U(width.W))
    when(io.clear) {
      count := 0.U
    } .elsewhen(RegNext(io.en, init=false.B)) {
      count := count + 1.U
    }
    io.snapshotValue := RegEnable(count, init=0.U, enable=io.snapshot)
}

object ProfilingUpDownCounter {
  def apply(enUp: Bool, enDown: Bool, width: Int, snapshot: Bool, clear: Bool, initVal: Int) : (UInt, UInt) = {
    val c = Module(new ProfilingUpDownCounter(width, initVal))
    c.io.enUp := enUp
    c.io.enDown := enDown
    c.io.snapshot := snapshot
    c.io.clear := clear
    (c.io.snapshotValue, c.io.count)
  }

  def apply(enUp: Bool, enDown: Bool, axiProfiling: AXI4LiteReadOnlyProfiling, initVal: Int=0, width: Int=Profiling.dataWidth) : (UInt, UInt) =
    apply(enUp, enDown, width, axiProfiling.snapshot, axiProfiling.clear, initVal)

  // def apply(enUp: Bool, enDown: Bool, axiProfiling: AXI4LiteReadOnlyProfiling, initVal: Int, width: Int) : (UInt, UInt) =
  //   apply(enUp, enDown, width, axiProfiling.snapshot, axiProfiling.clear, initVal)

}

/* A counter that counts the number of cycles during which en was enabled */
class ProfilingUpDownCounter(width: Int, initVal: Int) extends Module {
    val io = IO(new Bundle{
      val enUp = Input(Bool())
      val enDown = Input(Bool())
      val snapshot = Input(Bool())
      val clear = Input(Bool())
      val snapshotValue = Output(UInt(width.W))
      val count = Output(UInt(width.W))
    })

    val count = RegInit(initVal.U(width.W))
    count := MuxCase(count, Array(io.clear -> 0.U, RegNext(io.enUp & io.enDown, init=false.B) -> count, RegNext(io.enUp, init=false.B) -> (count + 1.U), RegNext(io.enDown, init=false.B) -> (count - 1.U)))
    io.snapshotValue := RegEnable(count, init=0.U, enable=io.snapshot)
    io.count := count
}

object ProfilingArbitraryIncrementCounter {
    def apply(in: Array[(Bool, SInt)], axiProfiling: AXI4LiteReadOnlyProfiling, initVal: Int=0, width: Int=Profiling.dataWidth) : (UInt, UInt) = {
        val c = Module(new ProfilingArbitraryIncrementCounter(width, initVal))
        c.io.en := Vec(in.map(i => i._1)).asUInt.orR
        c.io.increment := MuxCase(0.S, in)
        c.io.snapshot := axiProfiling.snapshot
        c.io.clear := axiProfiling.clear
        (c.io.snapshotValue, c.io.count)
    }
}

class ProfilingArbitraryIncrementCounter(width: Int, initVal: Int) extends Module {
    val io = IO(new Bundle{
      val en = Input(Bool())
      val increment = Input(SInt(width.W))
      val snapshot = Input(Bool())
      val clear = Input(Bool())
      val snapshotValue = Output(UInt(width.W))
      val count = Output(UInt(width.W))
    })

    val count = RegInit(initVal.U(width.W))
    count := MuxCase(count, Array(io.clear -> 0.U, RegNext(io.en, init=false.B) -> (count.asSInt + RegNext(io.increment)).asUInt))
    io.snapshotValue := RegEnable(count, init=0.U, enable=io.snapshot)
    io.count := count
}

object ProfilingMax {
  def apply(in: UInt, snapshot: Bool=true.B, clear: Bool=false.B) : UInt = {
    val c = Module(new ProfilingMax(in.getWidth))
    c.io.in := in
    c.io.snapshot := snapshot
    c.io.clear := clear
    c.io.snapshotValue
  }

  def apply(in: UInt, axiProfiling: AXI4LiteReadOnlyProfiling) : UInt =
    apply(in, axiProfiling.snapshot, axiProfiling.clear)
}

/* Keeps the running maximum of in */
class ProfilingMax(width: Int) extends Module {
    val io = IO(new Bundle{
      val in = Input(UInt(width.W))
      val snapshot = Input(Bool())
      val clear = Input(Bool())
      val snapshotValue = Output(UInt(width.W))
    })

    val max = RegInit(0.U(width.W))
    when(io.clear) {
      max := 0.U
    } .elsewhen(RegNext(io.in) > max) {
      max := io.in
    }
    io.snapshotValue := RegEnable(max, init=0.U, enable=io.snapshot)
}

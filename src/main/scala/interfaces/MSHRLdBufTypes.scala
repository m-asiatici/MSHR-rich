package fpgamshr.interfaces

import chisel3._
import chisel3.util.{log2Ceil}

trait HasRowAddr extends Bundle {
  val rowAddrWidth: Int
  val rowAddr = UInt(rowAddrWidth.W)
}

trait HasLdBufEntries extends Bundle {
  val entriesPerRow: Int
  val offsetWidth: Int
  val idWidth: Int
  val entries = Vec(entriesPerRow, new LdBufEntry(offsetWidth, idWidth))
}

trait HasLastValidIdx extends Bundle {
  val lastValidIdxWidth: Int
  val lastValidIdx = UInt(lastValidIdxWidth.W)
}

trait HasLastTableIdx extends ModularBundle {
  val lastTableIdxWidth: Int
  val lastTableIdx = UInt(lastTableIdxWidth.W)
  registerConnectionFunction((that: Bundle) =>
    this.lastTableIdx := {if(that.isInstanceOf[HasLastTableIdx]) that.asInstanceOf[HasLastTableIdx].lastTableIdx else DontCare}
  )
}

class MSHREntry(val tagWidth: Int, val ldBufPtrWidth: Int) extends ModularBundle with HasTag {
    val ldBufPtr = UInt(ldBufPtrWidth.W)

    override def cloneType = (new MSHREntry(tagWidth, ldBufPtrWidth)).asInstanceOf[this.type]
}

class MSHREntryValid(tagWidth: Int, ldBufPtrWidth: Int)
  extends MSHREntry(tagWidth, ldBufPtrWidth) with HasValid {
    override def cloneType = (new MSHREntryValid(tagWidth, ldBufPtrWidth)).asInstanceOf[this.type]
}

class MSHREntryLastTable(tagWidth: Int, ldBufPtrWidth: Int, val lastTableIdxWidth: Int)
  extends MSHREntry(tagWidth, ldBufPtrWidth) with HasLastTableIdx {
    override def cloneType = (new MSHREntryLastTable(tagWidth, ldBufPtrWidth, lastTableIdxWidth)).asInstanceOf[this.type]
}

class MSHREntryValidLastTable(tagWidth: Int, ldBufPtrWidth: Int, val lastTableIdxWidth: Int)
  extends MSHREntry(tagWidth, ldBufPtrWidth) with HasValid with HasLastTableIdx {
    override def cloneType = (new MSHREntryValidLastTable(tagWidth, ldBufPtrWidth, lastTableIdxWidth)).asInstanceOf[this.type]
    def getInvalidEntry() = {
      val m = Wire(this)
      m.valid := false.B
      m.tag := DontCare
      m.ldBufPtr := DontCare
      m.lastTableIdx := DontCare
      m
    }
}

class TraditionalMSHREntry(val tagWidth: Int, ldBufCountWidth: Int) extends Bundle with HasTag with HasValid {
    val ldBufLastValidIdx = UInt(ldBufCountWidth.W)
    override def cloneType = (new TraditionalMSHREntry(tagWidth, ldBufCountWidth)).asInstanceOf[this.type]
}

class LdBufEntry(offsetWidth: Int, idWidth: Int) extends Bundle {
    val offset = UInt(offsetWidth.W)
    val id = UInt(idWidth.W)

    override def cloneType = (new LdBufEntry(offsetWidth, idWidth)).asInstanceOf[this.type]
}

class LdBufRow(val offsetWidth: Int, val idWidth: Int, val entriesPerRow: Int, nextPtrWidth: Int)
  extends {
    val lastValidIdxWidth = if (log2Ceil(entriesPerRow) > 0) log2Ceil(entriesPerRow) else 1
  } with Bundle with HasLdBufEntries with HasLastValidIdx {
    val nextPtr = UInt(nextPtrWidth.W)
    val nextPtrValid = Bool()

    override def cloneType = (new LdBufRow(offsetWidth, idWidth, entriesPerRow, nextPtrWidth)).asInstanceOf[this.type]
}

class LdBufRowTraditional(val offsetWidth: Int, val idWidth: Int, val entriesPerRow: Int)
  extends Bundle with HasLdBufEntries {
    override def cloneType = (new LdBufRowTraditional(offsetWidth, idWidth, entriesPerRow)).asInstanceOf[this.type]
}

class LdBufOpType extends Bundle {
    /* Whether we want to allocate (true) or deallocate (false) an entry */
    val allocateEntry = Bool()
    /* Whether the new entry goes to a new line (true) or to an existing line (false) */
    val allocateRow = Bool()
    /* allocateEntry = true and allocateRow = false should not be used */
}

class MSHRToLdBufIO(offsetWidth: Int, idWidth: Int, val dataWidth: Int, val rowAddrWidth: Int)
  extends Bundle with HasData with HasRowAddr {
    val entry = new LdBufEntry(offsetWidth, idWidth)
    val opType = new LdBufOpType()

    override def cloneType = (new MSHRToLdBufIO(offsetWidth, idWidth, dataWidth, rowAddrWidth)).asInstanceOf[this.type]
}

class TraditionalMSHRToLdBufIO(offsetWidth: Int, idWidth: Int, dataWidth: Int, rowAddrWidth: Int, entryIdxWidth: Int)
  extends {
    val lastValidIdxWidth = entryIdxWidth
  } with MSHRToLdBufIO(offsetWidth, idWidth, dataWidth, rowAddrWidth) with HasLastValidIdx {
    val additionalEntryValid = Bool()

    override def cloneType = (new TraditionalMSHRToLdBufIO(offsetWidth, idWidth, dataWidth, rowAddrWidth, entryIdxWidth)).asInstanceOf[this.type]
}

class RespGenIO(val dataWidth: Int, val offsetWidth: Int, val idWidth: Int, val entriesPerRow: Int)
  extends {
    val lastValidIdxWidth = log2Ceil(entriesPerRow)
  } with Bundle with HasLdBufEntries with HasData with HasLastValidIdx {
    override def cloneType = (new RespGenIO(dataWidth, offsetWidth, idWidth, entriesPerRow)).asInstanceOf[this.type]
}

class LdBufWritePipelineIO(offsetWidth: Int, idWidth: Int, rowAddrWidth: Int, entriesPerRow: Int) extends Bundle {
    val entry = new LdBufEntry(offsetWidth, idWidth)
    val rowAddr = UInt(rowAddrWidth.W)
    val origRowAddr = UInt(rowAddrWidth.W)
    val row = new LdBufRow(offsetWidth, idWidth, entriesPerRow, rowAddrWidth)
    val rowFull = Bool()

    override def cloneType = (new LdBufWritePipelineIO(offsetWidth, idWidth, rowAddrWidth, entriesPerRow)).asInstanceOf[this.type]
}

class NextPtrCacheEntryIO(val rowAddrWidth: Int) extends Bundle with HasRowAddr {
  val nextPtr = UInt(rowAddrWidth.W)

  override def cloneType = (new NextPtrCacheEntryIO(rowAddrWidth)).asInstanceOf[this.type]
}

class OrigAndNewRowAddrIO(val rowAddrWidth: Int) extends Bundle with HasRowAddr {
  val origRowAddr = UInt(rowAddrWidth.W)

  override def cloneType = (new OrigAndNewRowAddrIO(rowAddrWidth)).asInstanceOf[this.type]
}

class MSHRToLdBufWithOrigAddrIO(offsetWidth: Int, idWidth: Int, dataWidth: Int, rowAddrWidth: Int) extends MSHRToLdBufIO(offsetWidth, idWidth, dataWidth, rowAddrWidth) {
  val origRowAddr = UInt(rowAddrWidth.W)

  override def cloneType = (new MSHRToLdBufWithOrigAddrIO(offsetWidth, idWidth, dataWidth, rowAddrWidth)).asInstanceOf[this.type]
}

class AddrDataIdAllocLdBufPtrLastTableIO(addrWidth: Int, dataWidth: Int, idWidth: Int, subentriesAddrWidth: Int, tableIdxWidth: Int) extends AddrDataIdAllocIO(addrWidth, dataWidth, idWidth) {
  val ldBufPtr = UInt(subentriesAddrWidth.W)
  val lastTableIdx = UInt(tableIdxWidth.W)

  override def cloneType = (new AddrDataIdAllocLdBufPtrLastTableIO(addrWidth, dataWidth, idWidth, subentriesAddrWidth, tableIdxWidth)).asInstanceOf[this.type]
}

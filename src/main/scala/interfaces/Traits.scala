package fpgamshr.interfaces

import chisel3._
import chisel3.util.{DecoupledIO}
import scala.collection.mutable.ArrayBuffer

class ModularBundle extends Bundle {
  private val connectionFunctions = ArrayBuffer.empty[Bundle => Unit]
  def registerConnectionFunction(f: Bundle => Unit): Unit = connectionFunctions += f
  def connectAllExisting(that: Bundle): Unit = connectionFunctions.foreach(_(that))
}

trait HasID extends Bundle {
  val idWidth: Int
  val id = UInt(idWidth.W)
}

trait HasAddr extends Bundle {
  val addrWidth: Int
  val addr = UInt(addrWidth.W)
}

trait HasData extends Bundle {
  val dataWidth: Int
  val data = UInt(dataWidth.W)
}
trait HasStrb extends Bundle {
  val strbWidth: Int
  val strb = UInt(strbWidth.W)
}
trait HasChosen extends Bundle {
  val chosenWidth: Int
  val chosen = UInt(chosenWidth.W)
}

trait HasValid extends Bundle {
  val valid = Bool()
  def setValid()   = { this.valid := true.B  }
  def invalidate() = { this.valid := false.B }
}

trait HasTag extends Bundle {
  val tagWidth: Int
  val tag = UInt(tagWidth.W)
}

package fpgamshr.interfaces

import chisel3._
import chisel3.util.{DecoupledIO}

// class PayloadIdIO(dataWidth: Int, val idWidth: Int) extends Bundle with HasID {
//     val payload = UInt(dataWidth.W)
//     override def cloneType = (new PayloadIdIO(dataWidth, idWidth)).asInstanceOf[this.type]
// }

class AddrIdIO(val addrWidth: Int, val idWidth: Int)
  extends Bundle with HasAddr with HasID {
    override def cloneType = (new AddrIdIO(addrWidth, idWidth)).asInstanceOf[this.type]
}

class DataIdIO(val dataWidth: Int, val idWidth: Int)
  extends Bundle with HasData with HasID {
    override def cloneType = (new DataIdIO(dataWidth, idWidth)).asInstanceOf[this.type]
}

class AddrDataIO(val addrWidth: Int, val dataWidth: Int) extends Bundle with HasAddr with HasData {
    override def cloneType = (new AddrDataIO(addrWidth, dataWidth)).asInstanceOf[this.type]
}

class AddrDataIdIO(val addrWidth: Int, val dataWidth: Int, val idWidth: Int)
  extends Bundle with HasAddr with HasData with HasID {
    override def cloneType = (new AddrDataIdIO(addrWidth, dataWidth, idWidth)).asInstanceOf[this.type]

    // override def := (that: Bundle) = {
    //
    // }
}

class AddrDataIdAllocIO(val addrWidth: Int, val dataWidth: Int, val idWidth: Int)
  extends Bundle with HasAddr with HasData with HasID {
  val isAlloc = Bool()
  override def cloneType = (new AddrDataIdAllocIO(addrWidth, dataWidth, idWidth)).asInstanceOf[this.type]
}

class DataStrobeIO(val dataWidth: Int) extends {
  val strbWidth = dataWidth / 8
} with Bundle with HasData with HasStrb {
    override def cloneType = (new DataStrobeIO(dataWidth)).asInstanceOf[this.type]
}

class AddressDataStrobeIO(val addrWidth: Int, val dataWidth: Int)
  extends {
    val strbWidth = dataWidth / 8
  } with Bundle with HasAddr with HasData with HasStrb {
    override def cloneType = (new AddressDataStrobeIO(addrWidth, dataWidth)).asInstanceOf[this.type]
}

class DataAndChosenIO(val dataWidth: Int, val chosenWidth: Int)
  extends Bundle with HasData with HasChosen {
  override def cloneType = (new DataAndChosenIO(dataWidth, chosenWidth)).asInstanceOf[this.type]
}

class DecAddrIdDecDataIdIO(addrWidth: Int, dataWidth: Int, idWidth: Int) extends Bundle {
  val addr  = DecoupledIO(new AddrIdIO(addrWidth, idWidth)).flip
  val data  = DecoupledIO(new DataIdIO(dataWidth, idWidth))
  override def cloneType = (new DecAddrIdDecDataIdIO(addrWidth, dataWidth, idWidth)).asInstanceOf[this.type]
}

class Clock2xBundle extends Bundle {
  val clock2x = Input(Clock())
}

package fpgamshr.packaging
import  scala.io.Source
import  play.api.libs.json._
import  play.api.libs.functional.syntax._
import  chisel3.Module

/** Abstraction for known bus interfaces / pin groups. */
final case class Interface(name: String, kind: String)

/**
 * Basic definition of a core for IP-XACT packaging.
 **/
class CoreDefinition(val name: String, val vendor: String, val library: String, val version: String,
                     val root: String, val postBuildActions: Seq[Option[Any] => Unit] = Seq(),
                     val interfaces: Seq[Interface] = Seq()) {
  import CoreDefinition._
  def write(filename: String) : Boolean = try {
    val fw = new java.io.FileWriter(filename)
    fw.append(Json.toJson(this).toString)
    fw.flush()
    fw.close()
    true
  } catch { case ex: Exception => println("ERROR: " + ex); false }
}

/**
 * Contains methods for reading a core definition from Json.
 **/
object CoreDefinition {
  def apply(name: String, vendor: String, library: String, version: String, root: String,
            interfaces: Seq[Interface] = Seq()): CoreDefinition =
    new CoreDefinition(name, vendor, library, version, root, interfaces = interfaces)

  def withActions(name: String, vendor: String, library: String, version: String, root: String,
                  postBuildActions: Seq[Option[Any] => Unit], interfaces: Seq[Interface] = Seq()): CoreDefinition =
    new CoreDefinition(name, vendor, library, version, root, postBuildActions, interfaces)

  def unapply(cd: CoreDefinition): Option[Tuple6[String, String, String, String, String, Seq[Interface]]] =
    Some((cd.name, cd.vendor, cd.library, cd.version, cd.root, cd.interfaces))

  /** Provide automatic IP directory for given name. **/
  def root(name: String): String =
      java.nio.file.Paths.get("./output/ip").toAbsolutePath.resolveSibling("ip").resolve(name).toString

  implicit val interfaceFormat: Format[Interface] = (
    (JsPath \ "name").format[String] ~
    (JsPath \ "kind").format[String]
  ) (Interface.apply _, unlift(Interface.unapply _))

  implicit val coreDefinitionWrites: Writes[CoreDefinition] = (
      (JsPath \ "name").write[String] ~
      (JsPath \ "vendor").write[String] ~
      (JsPath \ "library").write[String] ~
      (JsPath \ "version").write[String] ~
      (JsPath \ "root").write[String] ~
      (JsPath \ "interfaces").write[Seq[Interface]]
    )(unlift(CoreDefinition.unapply _))

  implicit val coreDefinitionReads: Reads[CoreDefinition] = (
      (JsPath \ "name").read[String] ~
      (JsPath \ "vendor").read[String] ~
      (JsPath \ "library").read[String] ~
      (JsPath \ "version").read[String] ~
      (JsPath \ "root").read[String] ~
      (JsPath \ "interfaces").readNullable[Seq[Interface]].map(_ getOrElse Seq[Interface]())
    )(apply _)

  /**
   * Read CoreDefinition from file containing Json format.
   * @param filename Name (and path) of file.
   **/
  def read(filename: String) : Option[CoreDefinition] = try {
    val contents = Source.fromFile(filename).getLines.mkString("\n")
    val json = Json.parse(contents)
    json.validate[CoreDefinition] match {
      case s: JsSuccess[CoreDefinition] => Some(s.get)
      case e: JsError => { println("ERROR: " + e); None }
    }
  } catch { case ex: Exception => println("ERROR: " + ex); None }
}

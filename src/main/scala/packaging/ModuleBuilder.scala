package fpgamshr.packaging
import  chisel3._
import  scala.sys.process._
import  java.nio.file._
import  scala.language.postfixOps

import java.io.{File} // To generate the BRAM initialization files

/** Module definition.
 *  @param config Optional, arbitrary configuration object, passed to post build actions.
 *  @param constr Module constructor function.
 *  @param core   Core definition.
 **/
final case class ModuleDef(config: Option[Any], constr: () => Module, core: CoreDefinition)

/**
 * Abstract IP-XACT builder class:
 * Objects can inherit from ModuleBuilder to automate the building
 * and packaging process. Provides main method that can be run
 * automatically via sbt run, takes arguments which cores to build.
 * @param packagingDir Base directory of packaging submodule
 *                     (default: ./packaging)
 **/
abstract class ModuleBuilder(packagingDir: String = "packaging") {
  val chiselArgs = Array[String]()
  /** List of modules to build. */
  val modules: Seq[ModuleDef]
  var args = Array[String]()

  private def extractScript(name: String): Path = {
    val p = Paths.get(java.io.File.createTempFile("chisel-packaging-", "", null).getAbsolutePath.toString).resolveSibling(name)
    val ps = new java.io.FileOutputStream(p.toFile)
    val in = Option(getClass().getClassLoader().getResourceAsStream(name))

    if (in.isEmpty) throw new Exception(s"$name not found in resources!")
    in map { is =>
      Iterator continually (is.read) takeWhile (-1 !=) foreach (ps.write)
      ps.flush()
      ps.close()
      p.toFile.deleteOnExit()
      p.toFile.setExecutable(true)
      Paths.get(p.toString)
    } get
  }


  def main(args: Array[String]) {
    this.args ++= args
    assert ((modules map (_.core.name.toLowerCase)).toSet.size == modules.length, "module names must be unique")
    val fm = modules // filter (m => args.length == 0 || args.map(_.toLowerCase).contains(m.core.name.toLowerCase))
    assert (fm.length > 0, "no matching cores found for: " + args.mkString(", "))
    val (packaging, axi) = (extractScript("package.py"), extractScript("axi4.py"))
    System.err.println(s"packaging script in: ${packaging.toString}")
    fm foreach { m =>
      Driver.execute(chiselArgs ++ Array("--target-dir", m.core.root, "--top-name", m.core.name), m.constr)
      val hexFiles = (new File(".")).listFiles.filter(f => f.isFile && f.getName.endsWith(".hex")).map(_.getName)
      /* s"rm -f ${resourcePath}BasicRebalancer*.v" ! */
      for (filename <- hexFiles) {
          val dest = m.core.root + "/" + filename
          s"mv $filename $dest" !
      }
      m.core.postBuildActions map (fn => fn.apply(m.config))
      val json = "%s/%s.json".format(m.core.root, m.core.name)
      m.core.write(json)
      s"${packaging.toString} %s".format(json).!
    }
  }
}

package action;

import com.codex.firo.FileSystem.*;

using StringTools;
using Utils;

class FindDeclaration {
  public static function doFindDeclaration(args:Array<String>, map:EUtils.Remap, target:String, pos:Int, charPos:Bool) {
    var temp = map.fromActual(toFilePath (target));

    //Repair position if requested (Treat all linebreaks as a single character)
    if (charPos) {
      var source = readContents (temp).lines().unlines();
      
      writeContents(temp, source);
    }

    var source = readContents (temp).lines().unlines();
    source = source.substr(0, pos-1) + "." + source.substr(pos-1);
    writeContents(temp, source);
    
    var dispLine = '${fromFilePath (temp)}@$pos';

    var args = args.concat([ "-D", "display-mode=position"
                             , "--display", dispLine]);

    var out = Utils.exec("haxe", args);

    trace(out.stderr);

    try {
      var stderr = Xml.parse(out.stderr).elementsNamed("pos");
      var decl = stderr.next().firstChild().nodeValue;

      Sys.stderr().writeString(decl);
    } catch (e:Dynamic) {
      Sys.stderr().writeString("NO DECLARATION");
    }

    return out.exitCode;
  }
}
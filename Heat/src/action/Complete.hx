package action;

import com.codex.firo.FileSystem.*;

using StringTools;
using Utils;

class Complete {
  public static function doComplete(args:Array<String>, map:EUtils.Remap, target:String, pos:Int, charPos:Bool) {
    var temp = map.fromActual(toFilePath (target));

    //Repair position if requested (Treat all linebreaks as a single character)
    if (charPos) {
      var source = readContents (temp).lines().unlines();
      writeContents(temp, source);
    }

    var source = readContents (temp).lines().unlines();
    source = source.substr(0, pos) + "|" + source.substr(pos);
    writeContents(temp, source);
    
    var dispLine = '${fromFilePath (temp)}@0';

    var args = args.concat(["--display", dispLine]);

    var out = Utils.exec("haxe", args);
    var lines = out.stderr.split("\n");

    try {
      var xml = Xml.parse(Utils.unlines(lines)).elementsNamed("list").next();
      var is = [for (x in xml.elementsNamed("i")) x];
      var data = is.map(function (i) {
          var n = i.get ("n");
          function getText(name:String)
            return i.elementsNamed(name).next().firstChild().toString().htmlUnescape().htmlUnescape();
          var t = getText("t");
          var d = getText("d");
          return {name:n, type:t, description:d};
        });
      var json = haxe.Json.stringify (data);
      Sys.stderr().writeString(json);
    } catch (e:Dynamic) {
      Sys.stderr().writeString('[]');
    }

    return out.exitCode;
  }

  public static function doToplevelComplete() {

  }
}
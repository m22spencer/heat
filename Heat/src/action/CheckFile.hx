package action;

using com.codex.firo.EitherM;

import com.codex.firo.FileSystem.*;
import com.codex.firo.Data;

class CheckFile {
  /** Do a syntax check on `haxeFile` using `tempDir` to store the shadow copy.
      Requires `originFile` to determine the proper package structure. `originFile` and `haxeFile` may be the same.
  **/
  public static function doCheck(args:Array<String>, map:EUtils.Remap) {
    var out = Utils.exec('haxe', args);

    var lines = out.stderr.split("\n");
    var el = EUtils.errLine;
    var errs = lines.filter(el.match);

    var fixed = [for (err in errs) {
        el.match(err);
        var remapped = fromFilePath (map.fromTemp (toFilePath (el.matched(1))));
        remapped = if (remapped == null)
          el.matched(1);
        else try fromFilePath (resolveFilePath (toFilePath (remapped)))
                   catch (e:Dynamic) remapped; //FIXME: This is a temp fix for linux. The resolve function requires that the file exists....
        remapped + el.matched(2);
      }];

    Sys.stderr()
      .writeString (fixed.join("\n")+"\n");
    Sys.stderr().flush();

    return out.exitCode;
  }
}
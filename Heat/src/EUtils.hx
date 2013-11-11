package ;

import com.codex.firo.Data;
import com.codex.firo.FileSystem.*;
import taurine.System;

using com.codex.firo.EitherM;
using Lambda;
using StringTools;

@:publicFields
class EUtils {
  static var errline = ~/(.*?):([0-9]+):(.*)/g;
  /** Convert any string `s` to LF line endings
   **/
  static function toLF(s:String) {
    return Utils.unlines(Utils.lines(s));
  }
    
  static function shadowFile(file:FilePath, tempDir:DirPath, source:String) {
    var fileN = baseName (file);
    var tempFile = joinAsFile (tempDir, Parse.readPackage (source).concat([fromFilePath (fileN)]));
    makeDirectory (directory (tempFile));
    writeContents (tempFile, source);
    return {key: file, val: tempFile};
  }

  static function getPackage(file:FilePath) {
    var source = readContents (file);
    return Parse.readPackage (source);
  }

  static function getModuleName(file:FilePath) {
    var pack = getPackage (file);
    return pack
      .concat([fromFilePath (baseNameNoExt (file))]).join(".");
  }

  static function resolveClassPath(file:FilePath, pack:Iterable<String>) {
    var relpath = joinAsFile (directory (file),
                              pack.map(function(x) return ".."));
    var resolved = resolveFilePath(relpath);
    return toDirPath (fromFilePath (resolved));
  }

  static function mkTempDir() {
    var tempRoot = if (System.isUnix) "/tmp";
    else if (System.isMac) throw "Mac is not implemented yet";
    else if (System.isWin) {
      var tmp = Sys.getEnv("TEMP");
      if (tmp == null) throw "Unable to find windows temp directory";
      tmp;
    }
    else throw "Unimplemented system";

    var hash = haxe.crypto.Md5.encode('${Math.random()}');
    
    var temp = toDirPath (tempRoot);
    var tempDir = joinAsDir(temp, ['haxeEmAssist$hash']);
    makeDirectory(tempDir);
    return tempDir;
  }

  static function readFilemapStdin() {
    var stdin = Sys.stdin();

    var nt = String.fromCharCode(0);
    var dnt = nt + nt;

    var buf = "";
    while (!buf.endsWith(dnt)) {
      buf += String.fromCharCode(stdin.readByte());
    }

    var buf = buf.substr(0, buf.length-2);
    var kv = buf.split(nt);

    if (kv.length % 2 != 0)
      throw "Malformed filemap. Must be key-value";

    return [for (i in 0...(kv.length >>> 1))
        { key: kv[i*2]
        , val: kv[i*2+1]}];
  }

  static function loadExistingFiles(map:Array<{orig:String, temp:String}>) {
    return [for (r in map) {key: r.orig, val: try sys.io.File.getContent(r.temp) catch (e:Dynamic) ""}];
  }

  @:generic static function toKVList<T,K>(kv:Map<T,K>):KVList<T,K> {
    return [for (key in kv.keys()) {key:key, val:kv.get(key)}];
  }

  /** Using `kv` a map of filepaths to sourcecode, shadow via a temporary directory
      and return a map of `temp => actual`
   **/
  static function shadowFiles(temp:DirPath, kv:KVList<String, String>) {
    var tempDir = temp;
    var flat = [for (v in kv)
        shadowFile (toFilePath (v.key), tempDir, v.val)];
    return kvToRemap (flat);
  }

  static function kvToRemap (seq:KVList<FilePath, FilePath>):Remap {
    var actToTemp:haxe.ds.StringMap<FilePath> = [for (kv in seq) fromFilePath(kv.key) => kv.val];
    var tempToAct:haxe.ds.StringMap<FilePath> = [for (kv in seq) fromFilePath(kv.val) => kv.key];
    return { fromTemp  : function(x) return tempToAct.get (fromFilePath (x))
           , fromActual: function(x) return actToTemp.get (fromFilePath (x))
           }
  }

  //TODO: This does not handle a temporary hxml properly.
  static function hxmlArgs(hxml:FilePath) {
    var hxml = resolveFilePath (hxml);
    var hxmlDir = fromDirPath (directory (hxml));
    return [ "--cwd", hxmlDir
             , "-cp", hxmlDir
             , fromFilePath (hxml)];
  }

  static function auto(targetHx:FilePath, map:Remap, tempDir:DirPath) {
    var tempTargetHx = map.fromActual (targetHx);
    var pack = getPackage (tempTargetHx);

    var originCP = resolveClassPath(targetHx, pack);
    var originCPS = fromDirPath (originCP);
    return [ "--cwd", originCPS
             , "-cp", originCPS
             , '--macro', 'include(\'\',true,null,[\'${fromDirPath (tempDir)}\'])'
             ];
  }

  static var errLine = ~/^(.+?)(:[0-9]+:.+$)/;
}

typedef Remap = { fromTemp  : FilePath -> FilePath
                , fromActual: FilePath -> FilePath
                };

typedef KVList<T, K> = Iterable<{key: T, val: K}>;
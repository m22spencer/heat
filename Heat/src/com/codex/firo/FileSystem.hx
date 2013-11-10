package com.codex.firo;

import haxe.ds.Option;
import com.codex.firo.Data;

import com.mindrocks.text.Parser;
import com.mindrocks.text.Parser.Parsers.*;
import com.mindrocks.functional.Functional;

using com.mindrocks.text.Parser;
import com.mindrocks.text.ParserMonad.ParserM;

using sys.FileSystem;
using sys.io.File;
using haxe.io.Path;

using Lambda;

@:publicFields
class FileSystem {
  static function toFilePath(s:String)
    return new FilePath(s);

  static function toDirPath(s:String)
    return new DirPath(s);

  static function fromFilePath(f:FilePath)
    return f.toString();

  static function fromDirPath(d:DirPath)
    return d.toString();

  static function readContents(f:FilePath) {
    var f = f.toString();
    return if (!f.exists()) throw NoSuchFile(f);
    else try f.getContent()
               catch (e:Dynamic) throw Other('Unable to read file "$f" with error:"$e"');
  }

  static function writeContents(f:FilePath, contents:String) {
    var f = f.toString();
    return try {f.saveContent(contents); Unit;}
    catch (e:Dynamic) throw Other('Unable to write file "$f" with error:"$e"');
  }

  static function baseName(f:FilePath):FilePath
    return new FilePath(f.toString().withoutDirectory());

  static function baseNameNoExt(f:FilePath):FilePath {
    return new FilePath(f.toString().withoutDirectory().withoutExtension());
  }

  static function joinAsFile(d:DirPath, rest:Iterable<String>)
    return new FilePath(d.toString().addTrailingSlash() +
                        rest.array().join("".addTrailingSlash()));

  static function joinAsDir(d:DirPath, rest:Iterable<String>)
    return new DirPath(joinAsFile(d, rest).toString());

  static function directory(f:FilePath) {
    var d = f.toString().directory();
    if (d == "") d = ".";
    return new DirPath (d);
  }

  static function makeDirectory(d:DirPath) { 
    return try {d.toString().createDirectory(); Unit;}
    catch (e:Dynamic) throw Other('Unable to create directory "$d" with error:"$e"');
  }

  static function listDirectory(d:DirPath):{files: Iterable<FilePath>, directories: Iterable<DirPath>} {
    var dir = d.toString();
    var list = dir.readDirectory()
      .map(function(f) return '$dir/$f');

    return { directories: list.filter(sys.FileSystem.isDirectory).map(function(x) return new DirPath (x))
           , files      : list.filter(function(x) return !sys.FileSystem.isDirectory(x)).map(function(x) return new FilePath(x))
           }
  }

  static function deleteFile(f:FilePath) {
    f.toString().deleteFile();
  }

  static function deleteDirectory(d:DirPath) {
    function loop(dir:DirPath) {
      var list = listDirectory(dir);
      list.files.iter(deleteFile);
      list.directories.iter(loop);
      dir.toString().deleteDirectory();
    }

    loop (d);
  }

  static function resolveFilePath(f:FilePath)
    return try new FilePath(f.toString().fullPath())
                 catch (e:Dynamic) throw Other('Unable to resolve file "$f"');

  static function resolveDirPath(d:DirPath)
    return try new DirPath(d.toString().fullPath())
                 catch (e:Dynamic) throw Other('Unable to resolve dir "$d"');
}

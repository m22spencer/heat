package ;

import com.codex.firo.FileSystem.*;
import com.codex.firo.Data;

using StringTools;

class Main extends mcli.CommandLine {
  function new() {
    remaps = [];
    super ();
  }
  /** Set a project file, such as .nmml, .xml (openfl), .hxml
   **/
  public var projectFile:String;

  /** This should be the path of the file that the user is currently editing.
      It does not matter if this file exists, as it's purely used for reconstruting
      paths.
  **/
  public var targetHx:String;


  /** Wait on stdin for a list of null terminated filename/file pairs
      Ex:  MyFile.hx\0File Contents\0MyFile2.hx\0File Contents\0\0
      The final \0\0 is necessary to indicate that stdin is closed.
   **/
  public var filesStdin:Bool;

  var remaps:Array<{orig:String, temp:String}>;
  
  /** Any remapped file will use `orig` for the error line reporting, and `temp` for
      the actual file contents. `temp` MUST exist on disk. If you do not wish to write
      a temp file, you should use `--files-stdin`. Neither `orig` or `temp` will be modified.
   **/
  public function remap(orig:String, temp:String) {
    remaps.push ({orig: orig, temp: temp});
  }

  /** A no-output compile to validate the syntax of `--target-hx`. Useful for flycheck/flymake
   **/
  public function syntaxCheck() {
    withCtx(function(ctx) {
        var all_args = ctx.args
          .concat([ "--no-output" ]);

        return action.CheckFile.doCheck (all_args, ctx.map);
      });
  } 
  
  /** Return completions for the `.` or `(` at `pos`, where `pos` is measured in bytes when `charPos == false`
      and characters when `charPos == true`.

      It is always safe to read a list of completions from `stdout`.

      ExitCode is 0 for successful completion, and 1 for failed completion.
  **/
  public function complete(pos:Int, charPos:String) {
    var charPos = charPos == "true" ? true : false;
    withCtx(function(ctx) {
        var all_args = ctx.args
          .concat([ "--no-output" ]);

        return action.Complete.doComplete (all_args, ctx.map, targetHx, pos, charPos);
      });
  }

  /** Find and return the declaration of the item under `pos`, where `pos` is measured in bytes when `charPos == false`
      and characters when `charPos == true`
  **/
  public function findDeclaration(pos:Int, charPos:String) {
    var charPos = charPos == "true" ? true : false;
    withCtx(function(ctx) {
        var all_args = ctx.args
          .concat([ "--no-output" ]);

        return action.FindDeclaration.doFindDeclaration (all_args, ctx.map, targetHx, pos, charPos);
      });
  }

  function withCtx(f:Ctx->Int) {
    var target = EUtils.loadExistingFiles([{orig: targetHx, temp: targetHx}]);
    var existing = EUtils.loadExistingFiles (remaps);
    var filemap = if (filesStdin) EUtils.readFilemapStdin(); else [];
    var allmap = target.concat(existing).concat(filemap);

    var temp = EUtils.mkTempDir ();
    var map  = EUtils.shadowFiles (temp, allmap);

    var temp_args = ["-cp", fromDirPath (temp)];
    var proj_args =
      if (projectFile != null) {
        if (projectFile.endsWith (".hxml")) EUtils.hxmlArgs (toFilePath (projectFile));
        else if (projectFile.endsWith (".nmml")) throw "Neko is not yet supported";
        else if (projectFile.endsWith (".xml")) throw "openfl is not yet supported";
        else throw 'Unkown project file: $projectFile';
      } else EUtils.auto (toFilePath (targetHx), map, temp);

    var exitCode = f({ args   : proj_args.concat (temp_args)
                     , map    : map
                     , tempDir: temp
                     });
    deleteDirectory (temp);
    Sys.exit (exitCode);
  }

  public static function main() {
    var args = Sys.args();
    Sys.setCwd (args.pop());
    new mcli.Dispatch(args).dispatch(new Main());
  }
}

typedef Ctx = { args   : Array<String>
              , map    : EUtils.Remap
              , tempDir: DirPath
              };
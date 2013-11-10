package ;

import TestAll.TestUtils.*;

class TestAll {
  static function main() {
    var r = new haxe.unit.TestRunner();
    r.add (new TestAutoMake());
    r.add (new TestCompletion());
    r.run();
  }
}

class TestUtils {
  public static var testDir = Sys.getCwd() + 'Heat/test';
  public static var emBin   = Sys.getCwd() + 'run.n';
  public static function check(target:String, ?remaps) {
    return run (["--target-hx", target
                 , "--syntax-check"], remaps);
  }

  public static function complete(target:String, pos:Int, isPoint:Bool, ?remaps) {
    return run (["--target-hx", target
                 , "--complete", '$pos', isPoint ? "true" : "false"], remaps);
  }

  public static function dir(p:String) {
    Sys.setCwd('$testDir/$p');
  }

  static function run(args:Array<String>, ?remaps:Array<{key:String, val:String}>) {
    if (remaps == null) remaps = [];
    var map = [];
    for (r in remaps)
      map = map.concat(["--remap", r.key, r.val]);

    var proc = new sys.io.Process('neko',
                                  [emBin].concat(map).concat(args));
    var ec = proc.exitCode();
    return { exitCode: ec
           , stderr: proc.stderr.readAll().toString()
           , stdout: proc.stdout.readAll().toString()
           };
  }
}

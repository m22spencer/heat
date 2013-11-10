package ;

import neko.vm.*;
import haxe.io.*;

using Lambda;

class Utils {
  public static function exec(cmd:String, args:Iterable<String>):{stdout:String, stderr:String, exitCode:Int}
  {
    var proc = new sys.io.Process(cmd, args.array());

    var main = Thread.current();
    function mk(i:Input) {
      return Thread.create(function() main.sendMessage({t:i, v:i.readAll().toString()}));
    }

    mk(proc.stderr);
    mk(proc.stdout);

    var o:{stderr:String, stdout:String, exitCode:Int} = cast {};
    for (i in 0...2) {
      var msg = Thread.readMessage(true);
      if (msg.t == proc.stdout) o.stdout = msg.v;
      else if (msg.t == proc.stderr) o.stderr = msg.v;
      else throw "Impossible error";
    }
    o.exitCode = proc.exitCode();
    return o;
  }

  public static function lines(s:String) {
    return StringTools.replace(s, "\r", "").split("\n"); //Horrible implementation
  }

  public static function unlines(s:Array<String>) {
    return s.join("\n");
  }
}
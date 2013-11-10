package ;

import com.mindrocks.text.Parser;
using com.mindrocks.text.Parser;
using com.mindrocks.text.ParserMonad;
import com.mindrocks.functional.Functional;
using com.mindrocks.functional.Functional;
using com.mindrocks.macros.LazyMacro;
using Lambda;

class Parse {
  public static var empty = "".identifier();
  public static var ident = ~/[A-Za-z0-9_]+/.regexParser();
  public static var semicolon = ";".identifier();
  public static var pack = "package".identifier();
  public static var whitespace = ~/[\t \n\r\.]*/.regexParser(); //TODO: Handle comments
  public static var path = ParserM.dO({
      whitespace;
      pack;
      whitespace;
      x <= ident.repsep(whitespace);
      semicolon;
      ret(x);
    });
  public static function readPackage(s:String) {
    var val = path()(s.reader());
    return switch (val) {
    case Success(v,_): v;
    case _: [];
    }
  }
}
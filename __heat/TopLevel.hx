package __heat;

import haxe.macro.*;

class TopLevel {
  macro static function complete() {
    var lclass = Context.getLocalClass().get();
    var ltype  = Context.getLocalType();

    var inh = getInheritedDecl (lclass);
    var cls = getClassDecl (lclass);
    var vars = Context.getLocalVars();

    var isStatic = throw "isStatic is NYI";

    var all = if (isStatic) [cls.statics, vars];
    else [inh.fields, cls.statics, cls.fields, vars];

    var map = foldMaps (all);

    Context.warning(map.toString(), Context.currentPos());

    return macro null;
  }

  /** .get() without null
   **/
  static function refg<T>(v:haxe.macro.Type.Ref<Array<T>>):Array<T> {
    var a = v.get();
    if (a == null) a = [];
    return a;
  }

  static function extract<T>(v:Array<haxe.macro.Type.ClassField>) {
    return [for (fld in v) fld.name => fld.type];
  }
  
  static function getClassDecl(lclass:haxe.macro.Type.ClassType):Acc {
    return { statics: extract (refg (lclass.statics))
           , fields : extract (refg (lclass.fields))
           }
  }

  static function getInheritedDecl(lclass:haxe.macro.Type.ClassType):Acc {
    function g (cls) {
      return if (cls == null) [];
      else {
        var r = cls.t.get();
        if (r == null) [];
        else [r];
      }
    }
    
    var inh = g (lclass.superClass);
    for (i in lclass.interfaces) inh = inh.concat (g (i));

    var all = [for (i in inh) getClassDecl (i)];

    return foldAcc (all);
  }

  static function foldAcc(it:Iterable<Acc>) {
    return Lambda.fold (it, function (a,b) return mergeAcc (b, a), { statics: new TypeMap()
                                                                   , fields : new TypeMap() });
  }

  static function mergeMaps(a:TypeMap, b:TypeMap) {
    var h = new TypeMap();
    function w(to:TypeMap, from:TypeMap)
      for (key in from.keys()) to.set (key, from.get (key));
    w (h, a);
    w (h, b);
    return h;
  }

  static function foldMaps(it:Iterable<TypeMap>) {
    return Lambda.fold (it, function(a,b) return mergeMaps (b, a), new TypeMap());
  }

  /** Any key existing in both maps will favor the key/value from `b`
   **/
  static function mergeAcc(a:Acc, b:Acc) {
    return { statics: mergeMaps (a.statics, b.statics)
           , fields : mergeMaps (a.fields, b.fields)
           }
  }
}

typedef Acc = { statics: TypeMap
              , fields : TypeMap
              };

typedef TypeMap = Map<String, haxe.macro.Type>;
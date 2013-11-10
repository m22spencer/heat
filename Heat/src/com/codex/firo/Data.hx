package com.codex.firo;

using haxe.io.Path;

using StringTools;

abstract DirPath(String) {
  public function new(s:String) this = s.addTrailingSlash().directory().replace("\\", "/");
  public function toString() return this;
}

abstract FilePath(String) {
  public function new(s:String) this = s.replace("\\", "/");
  public function toString() return this;
}

enum Either<T,K> {
  Left(t:T);
  Right(k:K);
}

enum FileError {
  NoSuchFile(s:String);
  Other(s:String);
}

enum Unit {
  Unit;
}
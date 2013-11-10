package com.codex.firo;

import haxe.macro.Expr;
import haxe.macro.Context;
import com.mindrocks.monads.Monad;

import com.codex.firo.Data;

@:native("Either_Monad")
class EitherM {
  macro public static function dO(body:Expr)
    return Monad._dO("EitherM", body, Context);

  public static function monad<T,K>(e:Either<T,K>)
    return EitherM;

  public static function ret<T,K>(k:K):Either<T,K>
    return Right(k);

  public static function flatMap<T,K,S>(e:Either<T,K>, f:K->Either<T,S>):Either<T,S> {
    return switch (e) {
    case Left(t): Left(t);
    case Right(v): f(v);
    }
  }

  public static function map<T,K,S>(e:Either<T,K>, f:K->S):Either<T,S> {
    return switch (e) {
    case Left(t): Left(t);
    case Right(v): Right(f(v));
    }
  }
}

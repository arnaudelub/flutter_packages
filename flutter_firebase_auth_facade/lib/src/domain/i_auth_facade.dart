import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_failure.dart';

abstract class IAuthFacade {
  User? getSignedInUser();
  Future<Either<AuthFailure, Unit>> registerWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<Either<AuthFailure, Unit>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<Either<AuthFailure, Unit>> signInWithApple();
  Future<Either<AuthFailure, Unit>> signInWithGoogle();
  Future<Either<AuthFailure, Unit>> signInWithGitHub();
  Future<Either<AuthFailure, Unit>> signInWithAnon();
  Future<void> signedOut();
  Future<void> resetPassword({required String email});
  bool isAnonymous();
  Stream<User?> userState();
}

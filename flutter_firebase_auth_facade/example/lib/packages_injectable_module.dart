import 'package:firebase_auth/firebase_auth.dart';
import 'package:example/injections.dart';
import 'package:example/constants.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_firebase_auth_facade/flutter_firebase_auth_facade.dart';

@module
abstract class PackagesInjectableModule {
  @lazySingleton
  IAuthFacade get authFacade {
    final _firebaseAuth = FirebaseAuth.instance;
    final _googleSignIn = GoogleSignIn();
    final authFacade = FirebaseAuthFacade(_firebaseAuth, _googleSignIn);
    authFacade(
      callbackUrl:
          environment == Environment.dev ? callbackUrlDev : callbackUrl,
      githubClientId:
          environment == Environment.dev ? githubClientIdDev : githubClientId,
      githubSecret:
          environment == Environment.dev ? githubSecretDev : githubSecret,
    );
    return authFacade;
  }
}

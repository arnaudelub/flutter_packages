import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_firebase_auth_facade/flutter_firebase_auth_facade.dart';
import 'package:flutter_firebase_auth_facade/src/utils/constants.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart' as apple;
import 'package:url_launcher/url_launcher.dart';
import 'package:uni_links2/uni_links.dart';

class FirebaseAuthFacade implements IAuthFacade {
  FirebaseAuthFacade(
    this._firebaseAuth,
    this._googleSignIn,
  );

  /// This is the clientID in GitHub OAuth app
  late String githubClientId;

  /// The secret generated in the github OAuth apps
  late String githubSecret;

  ///can be found in signin method of firebase,
  ///it's required because it's needed for appleSignin
  late String callbackUrl;

  ///Only for ios auth on Android
  late String appleClientId;

  /// DI of the firebaseAuth plugin
  final FirebaseAuth _firebaseAuth;

  /// DI of the GoogleSignIn plugin

  final GoogleSignIn _googleSignIn;

  void call({
    required callbackUrl,
    githubClientId = '',
    githubSecret = '',
    appleClientId = '',
  }) {
    this.githubSecret = githubSecret;
    this.githubClientId = githubClientId;
    this.appleClientId = appleClientId;
    this.callbackUrl = callbackUrl;
  }

  /// Deep link stream subscription
  StreamSubscription? _streamSubscription;

  StreamController<Either<AuthFailure, Unit>>? githubloginStreamController;

  /// get the current signed in user,
  /// return null if unauthenticated
  @override
  User? getSignedInUser() => _firebaseAuth.currentUser;

  /// Checking if user is anonym or not
  @override
  bool isAnonymous() => _firebaseAuth.currentUser!.isAnonymous;

  ///Register with Email and password
  /// return [Future<Either<AuthFailure, Unit>>]
  @override
  Future<Either<AuthFailure, Unit>> registerWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      final previousUser = getSignedInUser();
      if (previousUser != null) {
        final authCreds =
            EmailAuthProvider.credential(email: email, password: password);
        await previousUser.linkWithCredential(authCreds);
      } else {
        await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
      return const Right(unit);
    } on FirebaseAuthException catch (e) {
      if (e.code == kFirebaseCodeEmailAlreadyInUse) {
        return const Left(AuthFailure.emailAlreadyInUse());
      } else if (e.code == kFirebaseCodeInvalidEmail) {
        return const Left(AuthFailure.invalidEmail());
      } else if (e.code == kFirebaseCodeWeakPassword) {
        return const Left(AuthFailure.weakPassword());
      } else if (e.code == kFirebaseCodeOperationNotAllowed) {
        return const Left(AuthFailure.operationNotAllowed());
      } else if (e.code == kFirebasecodeInvalidCredentials) {
        return const Left(AuthFailure.invalidCredentials());
      } else {
        return const Left(AuthFailure.serverError());
      }
    }
  }

  /// Send an email to reset the password
  @override
  Future<void> resetPassword({required String email}) =>
      _firebaseAuth.sendPasswordResetEmail(email: email);

  /// Login out
  @override
  Future<void> signedOut() =>
      Future.wait([_googleSignIn.signOut(), _firebaseAuth.signOut()]);

  /// Sign in as anonymous
  /// return [Future<Either<AuthFailure, Unit>>]
  @override
  Future<Either<AuthFailure, Unit>> signInWithAnon() async {
    try {
      await _firebaseAuth.signInAnonymously();
      return right(unit);
    } on FirebaseAuthException catch (e) {
      if (e.code == kFirebaseCodeOperationNotAllowed) {
        return const Left(AuthFailure.operationNotAllowed());
      }
      return const Left(AuthFailure.serverError());
    }
  }

  /// Sign in with Apple
  /// return [Future<Either<AuthFailure, Unit>>]
  @override
  Future<Either<AuthFailure, Unit>> signInWithApple() async {
    try {
      final oAuthProvider = OAuthProvider(appleProvider);
      if (kIsWeb) {
        final result = await _firebaseAuth.signInWithPopup(oAuthProvider);
        var credential = result.credential;
        await _firebaseAuth.signInWithCredential(credential!);
        return right(unit);
      } else {
        final credential = await apple.SignInWithApple.getAppleIDCredential(
          scopes: [
            apple.AppleIDAuthorizationScopes.email,
            apple.AppleIDAuthorizationScopes.fullName,
          ],
          webAuthenticationOptions: apple.WebAuthenticationOptions(
            clientId: appleClientId,
            redirectUri: Uri.parse(callbackUrl),
          ),
        );
        final newCredentials = oAuthProvider.credential(
          idToken: credential.identityToken,
          accessToken: credential.authorizationCode,
        );
        final previousUser = getSignedInUser();
        if (previousUser != null) {
          await previousUser.linkWithCredential(newCredentials);
        } else {
          await _firebaseAuth.signInWithCredential(newCredentials);
        }
        return right(unit);
      }
    } on apple.SignInWithAppleException catch (e) {
      print(e);
      if (e is apple.SignInWithAppleNotSupportedException) {
        return const Left(AuthFailure.wrongIosVersion());
      }
      return const Left(AuthFailure.serverError());
    } on FirebaseAuthException catch (e) {
      if (e.code.contains('credential-already-in-use')) {
        return const Left(AuthFailure.emailAlreadyInUse());
      }
      return const Left(AuthFailure.serverError());
    }
  }

  /// Sign in with user and password
  /// return [Future<Either<AuthFailure, Unit>>]
  @override
  Future<Either<AuthFailure, Unit>> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return const Right(unit);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        return const Left(AuthFailure.invalidEmailAndPasswordCombination());
      } else {
        return const Left(AuthFailure.serverError());
      }
    }
  }

  /// Sign in with GitHub
  /// return [Future<Either<AuthFailure, Unit>>]
  @override
  Future<Either<AuthFailure, Unit>> signInWithGitHub() async {
    try {
      githubloginStreamController =
          StreamController<Either<AuthFailure, Unit>>();
      var provider = GithubAuthProvider()
        ..addScope('repo')
        ..setCustomParameters({'allow_signup': false});

      if (kIsWeb) {
        final result = await _firebaseAuth.signInWithPopup(provider);
        var credential = result.credential;
        await _firebaseAuth.signInWithCredential(credential!);
        return right(unit);
      } else {
        final url = '$githubAuthUrl'
            '$githubClientId&$githubScope';
        await _streamSubscription?.cancel();
        _streamSubscription = linkStream.listen((deeplink) async {
          final code = _getCodeFromGitHubLink(deeplink!);
          await _loginWithGitHub(code);
        });
        if (await canLaunch(url)) {
          print('Launchunbg url');
          await launch(url);
        } else {
          return left(const AuthFailure.serverError());
        }
        final failureOrSuccess =
            await githubloginStreamController!.stream.first;
        await githubloginStreamController!.close();
        print(failureOrSuccess);
        return failureOrSuccess;
      }
    } catch (e) {
      print(e);
      return left(const AuthFailure.serverError());
    }
  }

  /// Sign in with google
  /// return [Future<Either<AuthFailure, Unit>>]
  @override
  Future<Either<AuthFailure, Unit>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return const Left(AuthFailure.cancelledByUser());
      }
      final googleAuthentication = await googleUser.authentication;
      final authCredential = GoogleAuthProvider.credential(
          idToken: googleAuthentication.idToken,
          accessToken: googleAuthentication.accessToken);
      final previousUser = getSignedInUser();
      if (previousUser != null) {
        await previousUser.linkWithCredential(authCredential);
      } else {
        await _firebaseAuth.signInWithCredential(authCredential);
      }
      return right(unit);
    } on FirebaseAuthException catch (e) {
      print(e);
      if (e.code.contains('credential-already-in-use')) {
        return const Left(AuthFailure.emailAlreadyInUse());
      }
      return const Left(AuthFailure.serverError());
    }
  }

  //// Stream of the user current state
  @override
  Stream<User?> userState() async* {
    yield* _firebaseAuth.authStateChanges();
  }

  String _getCodeFromGitHubLink(String link) =>
      link.substring(link.indexOf(RegExp('code=')) + 5);

  Future<void> _loginWithGitHub(String code) async {
    try {
      final response = await http.post(
          Uri.parse('https://github.com/login/oauth/access_token'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: '{"client_id":"$githubClientId",'
              '"client_secret":"$githubSecret","code":"$code"}');
      final body = response.body;
      final Map<String, dynamic> bodymap = json.decode(body);
      final token = bodymap['access_token'];
      final AuthCredential credential = GithubAuthProvider.credential(
        token,
      );
      await _firebaseAuth.signInWithCredential(credential);
      print(getSignedInUser());
      githubloginStreamController!.add(right(unit));
      await _streamSubscription?.cancel();
    } on FirebaseAuthException catch (e) {
      if (e.code == kFirebaseCodeEmailAlreadyInUse) {
        githubloginStreamController!
            .add(const Left(AuthFailure.emailAlreadyInUse()));
      } else if (e.code == kFirebaseCodeInvalidEmail) {
        githubloginStreamController!
            .add(const Left(AuthFailure.invalidEmail()));
      } else if (e.code == kFirebaseCodeWeakPassword) {
        githubloginStreamController!
            .add(const Left(AuthFailure.weakPassword()));
      } else if (e.code == kFirebaseCodeOperationNotAllowed) {
        githubloginStreamController!
            .add(const Left(AuthFailure.operationNotAllowed()));
      } else if (e.code == kFirebasecodeInvalidCredentials) {
        githubloginStreamController!
            .add(const Left(AuthFailure.invalidCredentials()));
      } else {
        githubloginStreamController!.add(const Left(AuthFailure.serverError()));
      }
    }
  }
}

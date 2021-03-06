# Flutter_Firebase_Auth_Facade

A package to add Firebase authentication methods to your app

# Use this package as a library

## 1. Depend on it

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  flutter_firebase_auth_facade: latest_version
```

## 2. Install it

You can install packages from the command line:

with Flutter:

```bash
$ flutter pub get
```

## 3. Import it

Now in your Dart code, you can use:

```dart
import 'package:flutter_firebase_auth_facade/flutter_firebase_auth_facade.dart';
```

## 4. use it

### Methods available:
| Method | Status |
|--------|:------:|
| `CurrentUser` | V |
| `registerWithEmailAndPassword` | V |
| `signInWithEmailAndPassword` | V |
| `SignInWithGoogle` | V |
| `SignInWithApple` | V |
| `SignInAnonym` | V |
| `SigninWithGitHub` | V |
| `SignInWithFacebook` | *X* |
| `SignInWithInstagram` | *X* |
| `SignOut` | V |
| `userState` | V |
| `resetPassword` | V |


### Prepare for Android and ios:
 * Android

add to your AndroidManifest.xml:

 ```xml
 <intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data
    android:scheme="https"
    android:host="[your firebase project name].firebaseapp.com" />
</intent-filter>
 ```

 * iOS

Add to your info.plist

 ```
<key>CFBundleURLTypes</key>
<array>
<dict>
<key>CFBundleTypeRole</key>
<string>Editor</string>
<key>CFBundleURLName</key>
<string>[your firebase project name].firebaseapp.com</string>
<key>CFBundleURLSchemes</key>
<array>
<string>https</string>
</array>
</dict>
</array>
 ```

First instanciate FirebaseAuthFacade and inject GoogleSignIn and FirebaseAuth.
Then you have to call the method call() on the instance => authFacade()
callbackUrl is required, you can find it in your firebase panel in the github sign in method or apple sign in method.

You can use injectable like this and inject it into your Bloc:

```dart
import 'package:flutter_firebase_auth_facade/flutter_firebase_auth_facade.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

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
```

### Real life example

* You can find a real life app open source being build here:
[flutterence](https://github.com/arnaudelub/flutterence)

### Simple example

The sign in methods are returning a Future<Either<AuthFailure, unit>>, so you'll have to
use Dartz and fold the result like this:

```dart
final failureOrSuccess = _authFacade.signInWithGitHub();
failureOrSuccess.fold(
    (failure) => print(failure), // Handle the failure here
    (success) => print("User logged in")// handle the user here
);

```

##  Handle error

The AuthFailure class use Freezed with code generation  so you can use Unions/sealed class feature:

```dart
    failure.map(

            );
    failure.maybeMap();
    failure.when();
    //etc...
```
# Dependencies

- [flutterFire](https://firebase.flutter.dev/)
- [freezed](https://pub.dev/packages/freezed)
- [SignInWithApple](https://pub.dev/packages/sign_in_with_apple)
- [dartz](https://pub.dev/packages/dartz/versions/0.10.0-nullsafety.1)

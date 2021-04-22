import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_failure.freezed.dart';

final kFirebaseCodeEmailAlreadyInUse = 'email-already-in-use';
final kFirebaseCodeInvalidEmail = 'invalid-email';
final kFirebaseCodeWeakPassword = 'weak-password';
final kFirebaseCodeOperationNotAllowed = 'operation=not=allowed';
final kFirebasecodeInvalidCredentials = 'invalid-credential';

@freezed
class AuthFailure with _$AuthFailure {
  const factory AuthFailure.cancelledByUser() = CancelledByUser;
  const factory AuthFailure.serverError() = ServerError;
  const factory AuthFailure.emailAlreadyInUse() = EmailAlreadyInUse;
  const factory AuthFailure.invalidEmailAndPasswordCombination() =
      InvalidEmailAndPasswordCombination;
  const factory AuthFailure.wrongIosVersion() = WrongIosVersion;
  const factory AuthFailure.invalidEmail() = InvalidEmail;
  const factory AuthFailure.weakPassword() = WeakPassword;
  const factory AuthFailure.operationNotAllowed() = OperationNotAllowed;
  const factory AuthFailure.invalidCredentials() = InvalidCredentials;
}

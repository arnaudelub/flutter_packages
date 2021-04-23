import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_auth_facade/flutter_firebase_auth_facade.dart';
import 'package:injectable/injectable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_event.dart';
part 'auth_state.dart';
part 'auth_bloc.freezed.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._facade) : super(const AuthState.initial());

  final IAuthFacade _facade;

  @override
  Stream<AuthState> mapEventToState(
    AuthEvent event,
  ) async* {
    yield* event.map(authCheckRequested: (AuthCheckRequested _) async* {
      final user = _facade.getSignedInUser();
      print(user);
      if (user == null) {
        yield const AuthState.unauthenticated();
      } else {
        yield const AuthState.authenticated();
      }
    }, loginWithGithub: (LoginWithGithub _) async* {
      yield const AuthState.loading();
      final failureOrSuccess = await _facade.signInWithGitHub();
      yield failureOrSuccess.fold(
          (failureOrSuccess) => const AuthState.unauthenticated(),
          (success) => const AuthState.authenticated());
    });
  }
}

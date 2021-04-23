import 'package:flutter_firebase_auth_facade/flutter_firebase_auth_facade.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart' as mock;
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class MockSignInWithApple extends Mock implements SignInWithApple {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  IAuthFacade? repository;
  MockFirebaseAuth? mockFirebaseAuth;
  MockGoogleSignIn? mockGoogleSignIn;
  mock.MockUser? user;
  MockUserCredential? mockUserCredential;
  final email = 'bob@mail.com';
  final wrongEmail = 'bobmail.com';
  final weakpassword = '123';
  final password = 'mySecretPassword';

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    repository = FirebaseAuthFacade(mockFirebaseAuth!, mockGoogleSignIn!);
    user = mock.MockUser(
      isAnonymous: false,
      uid: 'someuid',
      email: 'bob@somedomain.com',
      displayName: 'Bob',
    );
    mockUserCredential = MockUserCredential();
  });

  void runTestsAuthenticated(Function body) {
    group('when user is authenticated,', () {
      setUp(() {
        when(() => mockFirebaseAuth!.currentUser).thenReturn(user);
      });

      body();
    });
  }

  void runTestsUnauthenticated(Function body) {
    group('when user is Unauthenticated', () {
      setUp(() {
        when(() => mockFirebaseAuth!.currentUser).thenReturn(null);
      });

      body();
    });
  }

  group('getSignedUser', () {
    runTestsUnauthenticated(() {
      test('getSignedUser Should return null ', () {
        final result = repository!.getSignedInUser();
        verify(() => mockFirebaseAuth!.currentUser).called(1);
        expect(result, isNull);
      });
    });
    runTestsAuthenticated(() {
      test('getSignedUser Should return a User ', () {
        final result = repository!.getSignedInUser();
        verify(() => mockFirebaseAuth!.currentUser).called(1);
        expect(result, equals(user));
      });
    });
  });

  group('isAnonymous', () {
    runTestsAuthenticated(() {
      test('should return false ', () {
        final result = repository!.isAnonymous();
        verify(() => mockFirebaseAuth!.currentUser!.isAnonymous).called(1);
        expect(result, equals(false));
      });
    });
    test('should return true if logged in as anonym user ', () {
      user = mock.MockUser(
        isAnonymous: true,
        uid: 'someuid',
        email: 'bob@somedomain.com',
        displayName: 'Bob',
      );
      when(() => mockFirebaseAuth!.currentUser).thenReturn(user);
      final result = repository!.isAnonymous();
      verify(() => mockFirebaseAuth!.currentUser!.isAnonymous).called(1);
      expect(result, equals(true));
    });
  });

  group('registerWithEmailAndPassword', () {
    runTestsUnauthenticated(() {
      test(
          'should return emailAlreadyInUse failure'
          'when email is already registered', () async {
        when(() => mockFirebaseAuth!.currentUser).thenReturn(null);

        when(() => mockFirebaseAuth!.createUserWithEmailAndPassword(
                email: email, password: password))
            .thenThrow(
                FirebaseAuthException(code: kFirebaseCodeEmailAlreadyInUse));
        final result = await repository!
            .registerWithEmailAndPassword(email: email, password: password);
        verify(() => mockFirebaseAuth!.currentUser).called(1);
        verify(() => mockFirebaseAuth!.createUserWithEmailAndPassword(
            email: email, password: password)).called(1);
        expect(result, equals(const Left(AuthFailure.emailAlreadyInUse())));
      });

      test('should return invalidEmail failure when email is invalid',
          () async {
        when(() => mockFirebaseAuth!.currentUser).thenReturn(null);

        when(() => mockFirebaseAuth!.createUserWithEmailAndPassword(
                email: wrongEmail, password: password))
            .thenThrow(FirebaseAuthException(code: kFirebaseCodeInvalidEmail));
        final result = await repository!.registerWithEmailAndPassword(
            email: wrongEmail, password: password);
        verify(() => mockFirebaseAuth!.currentUser).called(1);
        verify(() => mockFirebaseAuth!.createUserWithEmailAndPassword(
            email: wrongEmail, password: password)).called(1);
        expect(result, equals(const Left(AuthFailure.invalidEmail())));
      });
      test('should return operationNotAllowed failure when email is disabled',
          () async {
        when(() => mockFirebaseAuth!.currentUser).thenReturn(null);

        when(() => mockFirebaseAuth!.createUserWithEmailAndPassword(
                email: email, password: password))
            .thenThrow(
                FirebaseAuthException(code: kFirebaseCodeOperationNotAllowed));
        final result = await repository!
            .registerWithEmailAndPassword(email: email, password: password);
        verify(() => mockFirebaseAuth!.currentUser).called(1);
        verify(() => mockFirebaseAuth!.createUserWithEmailAndPassword(
            email: email, password: password)).called(1);
        expect(result, equals(const Left(AuthFailure.operationNotAllowed())));
      });
      test(
          'should return weakpassword failure when email is already registered',
          () async {
        when(() => mockFirebaseAuth!.currentUser).thenReturn(null);

        when(() => mockFirebaseAuth!.createUserWithEmailAndPassword(
                email: email, password: weakpassword))
            .thenThrow(FirebaseAuthException(code: kFirebaseCodeWeakPassword));
        final result = await repository!
            .registerWithEmailAndPassword(email: email, password: weakpassword);
        verify(() => mockFirebaseAuth!.currentUser).called(1);
        verify(() => mockFirebaseAuth!.createUserWithEmailAndPassword(
            email: email, password: weakpassword)).called(1);
        expect(result, equals(const Left(AuthFailure.weakPassword())));
      });

      test('should return right(unit) when user is registered correctly',
          () async {
        when(() => mockFirebaseAuth!.currentUser).thenReturn(null);

        when(() => mockFirebaseAuth!.createUserWithEmailAndPassword(
            email: email,
            password: password)).thenAnswer((_) async => mockUserCredential!);
        final result = await repository!
            .registerWithEmailAndPassword(email: email, password: password);
        verify(() => mockFirebaseAuth!.currentUser).called(1);
        verify(() => mockFirebaseAuth!.createUserWithEmailAndPassword(
            email: email, password: password)).called(1);
        expect(result, equals(const Right(unit)));
      });
    });
  });
}

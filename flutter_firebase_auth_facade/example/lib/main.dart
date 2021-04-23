import 'package:example/bloc/auth_bloc.dart';
import 'package:example/injections.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_auth_facade/flutter_firebase_auth_facade.dart';
import 'package:injectable/injectable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureInjection(Environment.prod);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SplashPage();
  }
}

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return BlocProvider(
                create: (_) => getIt<AuthBloc>()
                  ..add(const AuthEvent.authCheckRequested()),
                child:
                    BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
                  if (state is Authenticated) {
                    return const SplashView(text: 'authenticated');
                  } else if (state is Unauthenticated) {
                    return SplashView(
                        text: 'unauthenticated', homeContext: context);
                  } else {
                    return const SplashView();
                  }
                }));
          } else if (snapshot.hasError) {
            return const SplashView(text: 'Error With Firebase');
          } else {
            return const SplashView();
          }
        });
  }
}

class SplashView extends StatelessWidget {
  const SplashView({Key? key, this.text, this.homeContext}) : super(key: key);
  final String? text;
  final BuildContext? homeContext;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: text == null
            ? const CircularProgressIndicator()
            : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(text!),
                BlocProvider.value(
                  value: BlocProvider.of<AuthBloc>(context),
                  child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                    return TextButton(
                        onPressed: () => state is Unauthenticated
                            ? context
                                .read<AuthBloc>()
                                .add(const AuthEvent.loginWithGithub())
                            : print('ok'),
                        child: const Text('action'));
                  }),
                )
              ]),
      ),
    );
  }
}

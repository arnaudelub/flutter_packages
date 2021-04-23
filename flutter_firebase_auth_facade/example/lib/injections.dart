import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import './injections.config.dart';

final GetIt getIt = GetIt.instance;
String? environment;
@injectableInit
void configureInjection(String env) {
  environment = env;
  $initGetIt(getIt);
}

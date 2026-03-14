import 'package:get_it/get_it.dart';
import 'package:h02_colorfill/di/dependency_injection.config.dart';
import 'package:injectable/injectable.dart';

final GetIt getIt = GetIt.instance;

@injectableInit
Future<void> configureDependencies(String env) async =>
    await getIt.init(environment: env);

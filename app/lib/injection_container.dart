import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External
  sl.registerLazySingleton<Dio>(() => Dio());

  // Features (later)
}

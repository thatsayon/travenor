import 'package:dio/dio.dart';

class DioClient {
  final Dio dio;

  DioClient()
      : dio = Dio(
          BaseOptions(
            baseUrl: 'https://travenor-v1.thatsayon.com',
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => print(obj),
      ),
    );
  }

  /// Add auth interceptor after Riverpod providers are available
  void addAuthInterceptor(Interceptor interceptor) {
    // Remove existing auth interceptor if any
    dio.interceptors.removeWhere((i) => i.runtimeType.toString() == 'AuthInterceptor');
    // Add new auth interceptor at the beginning (before LogInterceptor)
    dio.interceptors.insert(0, interceptor);
    print('✅ AuthInterceptor added to Dio client');
  }
}

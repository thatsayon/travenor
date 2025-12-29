import 'package:dio/dio.dart';

class DioClient {
  final Dio dio;

  DioClient()
      : dio = Dio(
          BaseOptions(
            baseUrl: 'https://api.example.com',
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
          ),
        );
}

import 'package:dio/dio.dart';

class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({required this.message, this.statusCode});

  factory ServerException.fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        return const ServerException(message: 'Connection timeout with server');
      case DioExceptionType.sendTimeout:
        return const ServerException(message: 'Send timeout with server');
      case DioExceptionType.receiveTimeout:
        return const ServerException(message: 'Receive timeout with server');
      case DioExceptionType.badCertificate:
        return const ServerException(message: 'Bad certificate with server');
      case DioExceptionType.badResponse:
        return ServerException._fromResponse(dioException.response);
      case DioExceptionType.cancel:
        return const ServerException(message: 'Request was cancelled');
      case DioExceptionType.connectionError:
        return const ServerException(
          message: 'No internet connection. Please check your network.',
        );
      case DioExceptionType.unknown:
      default:
        return const ServerException(
          message: 'Unexpected error occurred. Please try again.',
        );
    }
  }

  factory ServerException._fromResponse(Response? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;

    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is List) {
        return ServerException(
          message: message.join('\n'),
          statusCode: statusCode,
        );
      } else if (message is String) {
        return ServerException(
          message: message,
          statusCode: statusCode,
        );
      }
    }

    switch (statusCode) {
      case 400:
        return const ServerException(
          message: 'Bad request. Please verify your input.',
          statusCode: 400,
        );
      case 401:
        return const ServerException(
          message: 'Invalid credentials or unauthorized.',
          statusCode: 401,
        );
      case 403:
        return const ServerException(
          message: 'Access forbidden.',
          statusCode: 403,
        );
      case 404:
        return const ServerException(
          message: 'Requested resource not found.',
          statusCode: 404,
        );
      case 500:
      default:
        return const ServerException(
          message: 'Server error. Please try again later.',
          statusCode: 500,
        );
    }
  }

  @override
  String toString() => message;
}


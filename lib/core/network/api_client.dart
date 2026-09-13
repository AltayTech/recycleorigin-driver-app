import 'dart:async';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:recycleorigindriver/core/config/app_config.dart';
import 'package:recycleorigindriver/core/network/token_refresher.dart';
import 'package:recycleorigindriver/core/network/urls.dart';
import 'package:recycleorigindriver/core/storage/secure_storage.dart';
import 'package:recycleorigindriver/core/utils/result.dart';

/// Centralized HTTP client for the driver app.
///
/// Mirrors the customer app's `ApiClient`:
/// - shared base options and timeouts,
/// - automatic bearer-token injection from secure storage,
/// - transparent access-token rotation: when the backend returns 401 the
///   client refreshes the token pair once through [TokenRefresher] and
///   replays the original request,
/// - request/response/error logging via `dart:developer`, and
/// - unified mapping of transport failures into `Result<T>`.
///
/// Session expiry (refresh token rejected) is handled by [TokenRefresher],
/// which clears storage and fires its `onSessionExpired` callback.
class ApiClient {
  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    _setupInterceptors();
  }

  late final Dio _dio;

  Dio get raw => _dio;

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final base = options.baseUrl.isEmpty
              ? AppConfig.apiBaseUrl
              : options.baseUrl;
          options.path = stripApiBasePrefix(options.path, base);
          if (_isAuthExempt(options.path)) {
            handler.next(options);
            return;
          }
          final token = await SecureStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          developer.log('${options.method} ${options.uri}', name: 'driver.api');
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) async {
          if (_shouldAttemptRefresh(error)) {
            try {
              final refreshed = await TokenRefresher.instance.refreshSession();
              if (!refreshed) {
                handler.next(error);
                return;
              }
              final retry = await _retryRequest(error.requestOptions);
              handler.resolve(retry);
              return;
            } catch (refreshError, stackTrace) {
              developer.log(
                'Token refresh failed: $refreshError',
                name: 'driver.api',
                error: refreshError,
                stackTrace: stackTrace,
                level: 900,
              );
              handler.next(error);
              return;
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  bool _isAuthExempt(String path) {
    return path.contains(Urls.loginPath) ||
        path.contains(Urls.firebaseExchangePath) ||
        path.contains(Urls.refreshTokenPath);
  }

  bool _shouldAttemptRefresh(DioException error) {
    if (error.response?.statusCode != 401) {
      return false;
    }
    final path = error.requestOptions.path;
    return !path.contains(Urls.refreshTokenPath) &&
        !path.contains(Urls.firebaseExchangePath) &&
        !path.contains(Urls.loginPath);
  }

  Future<Response<dynamic>> _retryRequest(RequestOptions options) async {
    final newAccess = await SecureStorage.getAccessToken();
    final headers = Map<String, dynamic>.from(options.headers)
      ..['Authorization'] = 'Bearer ${newAccess ?? ''}';
    return _dio.fetch<dynamic>(options.copyWith(headers: headers));
  }

  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      if (response.statusCode == 200) {
        final data = parser != null
            ? parser(response.data)
            : response.data as T;
        return Success(data);
      }
      return Failure('Request failed with status ${response.statusCode}');
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return Failure('An unexpected error occurred: $e');
    }
  }

  Future<Result<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = parser != null
            ? parser(response.data)
            : response.data as T;
        return Success(result);
      }
      return Failure('Request failed with status ${response.statusCode}');
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return Failure('An unexpected error occurred: $e');
    }
  }

  Future<Result<T>> put<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.put(path, data: data);
      if (response.statusCode == 200 || response.statusCode == 204) {
        final result = parser != null
            ? parser(response.data)
            : response.data as T;
        return Success(result);
      }
      return Failure('Request failed with status ${response.statusCode}');
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return Failure('An unexpected error occurred: $e');
    }
  }

  Future<Result<void>> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        queryParameters: queryParameters,
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Success(null);
      }
      return Failure('Request failed with status ${response.statusCode}');
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return Failure('An unexpected error occurred: $e');
    }
  }

  String? _serverErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final err = data['error'] ?? data['message'];
      if (err != null && err.toString().isNotEmpty) {
        return err.toString();
      }
    }
    return null;
  }

  Result<T> _handleDioError<T>(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const Failure(
          'Connection timeout. Please check your internet connection.',
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final serverMsg = _serverErrorMessage(error.response?.data);
        if (statusCode == 401) {
          return Failure(
            serverMsg ?? 'Authentication failed. Please login again.',
          );
        } else if (statusCode == 403) {
          return Failure(serverMsg ?? 'Access forbidden.');
        } else if (statusCode == 404) {
          return Failure(serverMsg ?? 'Resource not found.');
        } else if (statusCode != null && statusCode >= 500) {
          return Failure(serverMsg ?? 'Server error. Please try again later.');
        }
        return Failure(serverMsg ?? 'Request failed with status $statusCode');
      case DioExceptionType.cancel:
        return const Failure('Request was cancelled.');
      case DioExceptionType.unknown:
        if (error.error?.toString().contains('SocketException') == true) {
          return const Failure(
            'No internet connection. Please check your network.',
          );
        }
        return Failure('Network error: ${error.message}');
      default:
        return Failure('An error occurred: ${error.message}');
    }
  }
}

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

class CampusNetworkCheckResult {
  const CampusNetworkCheckResult({
    required this.publicRequestOk,
    required this.publicStatusLabel,
    required this.localNetworkStatus,
    required this.localNetworkMessage,
  });

  final bool publicRequestOk;
  final String publicStatusLabel;
  final String localNetworkStatus;
  final String localNetworkMessage;
}

class CampusNetworkService {
  CampusNetworkService({Dio? dio, MethodChannel? channel})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 6),
              receiveTimeout: const Duration(seconds: 6),
              sendTimeout: const Duration(seconds: 6),
              responseType: ResponseType.plain,
              validateStatus: (status) =>
                  status != null && status >= 200 && status < 500,
            ),
          ),
      _channel = channel ?? const MethodChannel('campuslink/network_tools');

  final Dio _dio;
  final MethodChannel _channel;

  Future<CampusNetworkCheckResult> runSchoolNetworkCheck(
    String publicUrl,
  ) async {
    final publicStatusLabel = await _checkPublicUrl(publicUrl);
    final localPayload = await _requestLocalNetworkPermission();

    return CampusNetworkCheckResult(
      publicRequestOk: publicStatusLabel.startsWith('HTTP '),
      publicStatusLabel: publicStatusLabel,
      localNetworkStatus: (localPayload['status'] as String?) ?? 'unknown',
      localNetworkMessage: (localPayload['message'] as String?) ?? '已發起本地網路檢測',
    );
  }

  Future<String> _checkPublicUrl(String publicUrl) async {
    try {
      final response = await _dio.getUri<String>(Uri.parse(publicUrl));
      final statusCode = response.statusCode ?? 0;
      return 'HTTP $statusCode';
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode != null) {
        return 'HTTP $statusCode';
      }
      return '請求失敗: ${error.message ?? '無法連線'}';
    } catch (error) {
      return '請求失敗: $error';
    }
  }

  Future<Map<dynamic, dynamic>> _requestLocalNetworkPermission() async {
    try {
      final payload = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'requestLocalNetworkPermission',
      );
      return payload ?? const <dynamic, dynamic>{};
    } on MissingPluginException {
      return const <dynamic, dynamic>{
        'status': 'unsupported',
        'message': '目前平台不支援本地網路權限檢測',
      };
    } on PlatformException catch (error) {
      return <dynamic, dynamic>{
        'status': 'error',
        'message': error.message ?? '本地網路檢測失敗',
      };
    }
  }
}

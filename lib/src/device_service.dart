import 'package:flutter/services.dart';

import 'models.dart';

class DeviceService {
  static const _channel = MethodChannel('campuslink/device_info');

  Future<CurrentDeviceSnapshot> fetchCurrentDevice() async {
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>(
        'getCurrentDevice',
      );
      if (result == null) {
        return CurrentDeviceSnapshot.fallback();
      }

      final managedConfiguration =
          (result['managedConfiguration'] as Map<Object?, Object?>?)?.map(
            (key, value) => MapEntry(key.toString(), value),
          ) ??
          const <String, dynamic>{};

      return CurrentDeviceSnapshot(
        deviceName: result['deviceName'] as String? ?? '本机设备',
        model: result['model'] as String? ?? 'iPhone',
        localizedModel: result['localizedModel'] as String? ?? 'iPhone',
        systemName: result['systemName'] as String? ?? 'iOS',
        systemVersion: result['systemVersion'] as String? ?? '',
        machineIdentifier: result['machineIdentifier'] as String? ?? '',
        vendorIdentifier: result['vendorIdentifier'] as String? ?? '',
        isManaged: result['isManaged'] as bool? ?? false,
        managedConfiguration: managedConfiguration,
      );
    } on PlatformException {
      return CurrentDeviceSnapshot.fallback();
    } on MissingPluginException {
      return CurrentDeviceSnapshot.fallback();
    }
  }
}

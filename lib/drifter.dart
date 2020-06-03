import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class Drifter {
  static MethodChannel _channel = MethodChannel('me.wener.drifter')
    ..setMethodCallHandler(_handler);
  static Map<int, Function> _callbacks = {};

  static Future<dynamic> _handler(MethodCall call) async {
    var m = call.arguments as Map;
    var cb = _callbacks.remove(m['requestCode'] as int);
    cb(call);
  }

  static bool _isAndroid() {
    return defaultTargetPlatform == TargetPlatform.android;
  }

  /// Enable plugin debug
  /// Will show more info on error
  static Future<bool> debug([bool debug]) async {
    return (await _channel
        .invokeMethod('debug', <String, dynamic>{'debug': debug})) as bool;
  }

  /// Android
  /// Check has permission
  /// Permission like android.permission.READ_PHONE_STATE
  static FutureOr<bool> hasPermission(String permission) async {
    if (!_isAndroid()) {
      return false;
    }
    return (await _channel.invokeMethod(
                'hasPermission', <String, dynamic>{'permission': permission}))
            as bool ??
        false;
  }

  /// Android
  /// Check has permission
  /// Permission like android.permission.READ_PHONE_STATE
  static FutureOr<bool> requestPermission(String permission) async {
    if (!_isAndroid()) {
      return false;
    }

    var requestCode =
        (await _channel.invokeMethod('requestPermissions', <String, dynamic>{
      'permissions': [permission]
    })) as int;
    if (requestCode == null) {
      throw "Invalid permission request: $permission - enable Drifter.debug see more detail";
    }
    var c = Completer<bool>();
    _callbacks[requestCode] = (MethodCall call) {
      try {
        c.complete((call.arguments as Map)['result'] == true);
      } catch (e, st) {
        c.completeError(e, st);
      }
    };
    return c.future;
  }

  /// Android/iOS
  /// Generate random uuid v4
  static Future<String> generateRandomUuid() async {
    return (await _channel.invokeMethod('generateRandomUuid')) as String;
  }

  /// Android
  /// International Mobile Equipment Identity
  /// Return null on ios or permission deny
  static Future<String> bluetoothAddress() async {
    return (await _channel.invokeMethod('getBluetoothAddress')) as String;
  }

  /// Android
  /// Wifi address of device
  /// Return null on ios or permission deny
  static Future<String> wifiMacAddress() async {
    return (await _channel.invokeMethod('getWifiMacAddress')) as String;
  }

  /// Android
  /// International Mobile Subscriber Identity of Android Device
  /// Return null on ios or permission deny
  static Future<String> imsi({int slotIndex}) {
    return _telephonyId(slotIndex: slotIndex, method: 'getImsi');
  }

  /// Android
  /// International Mobile Equipment Identity
  /// IMEI for GSM
  static Future<String> imei({int slotIndex}) async {
    return _telephonyId(slotIndex: slotIndex, method: 'getImei');
  }

  /// Android
  /// Mobile Equipment IDentifier of Android Device
  /// MEID for CDMA
  static Future<String> meid({int slotIndex}) async {
    return _telephonyId(slotIndex: slotIndex, method: 'getMeid');
  }

  /// Android
  /// IMEI for GSM , MEID or ESN for CDMA
  static Future<String> deviceId({int slotIndex}) async {
    return _telephonyId(slotIndex: slotIndex, method: 'getDeviceId');
  }

  static Future<String> _telephonyId({int slotIndex, String method}) async {
    return (await _channel.invokeMethod(
        method, <String, dynamic>{'slotIndex': slotIndex})) as String;
  }

  /// iOS
  /// IDentifier For Vendor of iOS Device
  /// Return null on android
  static Future<String> idfv() async {
    return (await _channel.invokeMethod('getIdfv')) as String;
  }

  /// iOS
  /// IDentifier For Advertising of iOS Device
  /// May return null if device disabled advertising trace or on android
  static Future<String> idfa() async {
    return (await _channel.invokeMethod('getIdfa')) as String;
  }
}

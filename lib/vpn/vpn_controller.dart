import 'package:flutter/services.dart';

class OpenVpnControl {
  static const MethodChannel _channel = MethodChannel('pakvpn/openvpn');

  static Future<bool> isInstalled() async {
    final bool? ok = await _channel.invokeMethod<bool>('isOpenVpnInstalled');
    return ok ?? false;
  }

  static Future<void> connect({required String profileName}) async {
    await _channel.invokeMethod('connect', {'profileName': profileName});
  }

  static Future<void> disconnect() async {
    await _channel.invokeMethod('disconnect');
  }
}

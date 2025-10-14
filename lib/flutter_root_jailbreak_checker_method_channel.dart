// lib/flutter_root_jailbreak_checker_method_channel.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'flutter_root_jailbreak_checker_platform_interface.dart';
import 'models/device_integrity_result.dart';

class MethodChannelFlutterRootJailbreakChecker extends FlutterRootJailbreakCheckerPlatform {

  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_root_jailbreak_checker');

  @override
  Future<DeviceIntegrityResult> checkIntegrity() async {

    final result = await methodChannel.invokeMapMethod<String, dynamic>('checkIntegrity');

    if (result == null) {
      throw PlatformException(code: 'ERROR', message: 'Native side returned null.');
    }

    return DeviceIntegrityResult.fromMap(result);
  }
}
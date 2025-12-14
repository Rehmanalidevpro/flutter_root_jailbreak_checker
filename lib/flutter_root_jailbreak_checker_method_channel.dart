// lib/flutter_root_jailbreak_checker_method_channel.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'flutter_root_jailbreak_checker_platform_interface.dart';
import 'models/device_integrity_result.dart';

/// An implementation of [FlutterRootJailbreakCheckerPlatform] that uses method channels.
///
/// This class handles the communication between Flutter and the native platform
/// (Android/iOS) to perform integrity checks.
class MethodChannelFlutterRootJailbreakChecker
    extends FlutterRootJailbreakCheckerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_root_jailbreak_checker');

  @override
  Future<DeviceIntegrityResult> checkOfflineIntegrity() async {
    // Invoke the native method to check for root/jailbreak offline
    final result = await methodChannel.invokeMapMethod<String, dynamic>(
      'checkOfflineIntegrity',
    );

    // Ensure we received a valid response from the native side
    if (result == null) {
      throw PlatformException(
        code: 'UNAVAILABLE',
        message: 'Native side returned null for offline check.',
      );
    }

    // Convert the map result into a strongly-typed object
    return DeviceIntegrityResult.fromOfflineMap(result);
  }

  @override
  Future<bool> preparePlayIntegrity(String cloudProjectNumber) async {
    // Call the native method to warm up the Integrity API provider
    final success = await methodChannel.invokeMethod<bool>(
      'preparePlayIntegrity',
      {'cloudProjectNumber': cloudProjectNumber},
    );
    return success ?? false;
  }

  @override
  Future<String?> requestPlayIntegrityToken({
    String? cloudProjectNumber,
    String? nonce,
    String? requestHash,
  }) async {
    // Request the integrity token from the native layer
    final String? token = await methodChannel
        .invokeMethod<String>('requestPlayIntegrityToken', {
          'cloudProjectNumber': cloudProjectNumber,
          'nonce': nonce,
          'requestHash': requestHash,
        });
    return token;
  }
}

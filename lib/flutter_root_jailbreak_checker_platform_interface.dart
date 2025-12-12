// lib/flutter_root_jailbreak_checker_platform_interface.dart

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'flutter_root_jailbreak_checker_method_channel.dart';
import 'models/device_integrity_result.dart';

/// The common platform interface for the `flutter_root_jailbreak_checker` plugin.
///
/// This interface defines the contract that platform-specific implementations
/// (like Android and iOS) must adhere to.
abstract class FlutterRootJailbreakCheckerPlatform extends PlatformInterface {
  /// Constructs a [FlutterRootJailbreakCheckerPlatform].
  FlutterRootJailbreakCheckerPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterRootJailbreakCheckerPlatform _instance =
      MethodChannelFlutterRootJailbreakChecker();

  /// The default instance of [FlutterRootJailbreakCheckerPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterRootJailbreakChecker].
  static FlutterRootJailbreakCheckerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterRootJailbreakCheckerPlatform]
  /// when they register themselves.
  static set instance(FlutterRootJailbreakCheckerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Checks the device integrity offline (Root, Jailbreak, Emulator, etc.).
  ///
  /// Returns a [DeviceIntegrityResult] indicating the status.
  Future<DeviceIntegrityResult> checkOfflineIntegrity() {
    throw UnimplementedError(
      'checkOfflineIntegrity() has not been implemented.',
    );
  }

  /// Warms up the Google Play Integrity API provider (Android only).
  ///
  /// This helps reduce latency for the actual token request.
  Future<bool> preparePlayIntegrity(String cloudProjectNumber) {
    throw UnimplementedError(
      'preparePlayIntegrity() has not been implemented.',
    );
  }

  /// Requests a Google Play Integrity Token (Android only).
  ///
  /// [cloudProjectNumber] is the project ID from Google Cloud.
  /// [nonce] is a unique string for the request.
  /// [requestHash] is an optional hash of the request.
  Future<String?> requestPlayIntegrityToken({
    String? cloudProjectNumber,
    String? nonce,
    String? requestHash,
  }) {
    throw UnimplementedError(
      'requestPlayIntegrityToken() has not been implemented.',
    );
  }
}

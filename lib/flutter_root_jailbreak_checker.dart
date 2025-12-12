// lib/flutter_root_jailbreak_checker.dart

import 'flutter_root_jailbreak_checker_platform_interface.dart';
import 'models/device_integrity_result.dart';
import 'models/integrity_check_config.dart';

export 'models/device_integrity_result.dart';
export 'models/integrity_check_config.dart';

/// The main entry point for the Flutter Root and Jailbreak Checker plugin.
///
/// Use this class to perform device integrity checks on Android and iOS.
class FlutterRootJailbreakChecker {
  /// The current version of the package.
  static const String version = "2.0.0";

  /// Performs a complete device integrity check based on the provided [config].
  ///
  /// On Android, this can include both offline checks (Root, Emulator, etc.)
  /// and Google Play Integrity API checks if configured.
  ///
  /// On iOS, it performs standard Jailbreak detection checks.
  ///
  /// Returns a [DeviceIntegrityResult] containing the status of the device.
  Future<DeviceIntegrityResult> check(IntegrityCheckConfig config) async {
    try {
      // Step 1: Check basic offline indicators (Root, Hooks, Emulator)
      final offlineResult = await FlutterRootJailbreakCheckerPlatform.instance
          .checkOfflineIntegrity();

      // If Play Integrity is not requested, return offline results immediately.
      if (!config.usePlayIntegrity) {
        return offlineResult;
      }

      // Step 2: Request Google Play Integrity Token (Android only)
      final token = await FlutterRootJailbreakCheckerPlatform.instance
          .requestPlayIntegrityToken(
        cloudProjectNumber: config.cloudProjectNumber,
        nonce: config.nonce,
        requestHash: config.requestHash,
      );

      // Combine offline result with the new token
      return offlineResult.withPlayIntegrity(token: token);
    } catch (e) {
      // Gracefully handle errors and return a result indicating failure/error
      return DeviceIntegrityResult().withPlayIntegrity(error: e.toString());
    }
  }

  /// Performs only the offline checks (Root, Jailbreak, Emulator, etc.).
  ///
  /// Does not make any network calls to Google Play Integrity API.
  Future<DeviceIntegrityResult> checkOfflineIntegrity() {
    return FlutterRootJailbreakCheckerPlatform.instance.checkOfflineIntegrity();
  }

  /// Warms up the Google Play Integrity API provider (Android Only).
  ///
  /// Call this early in your app lifecycle to reduce latency during the actual check.
  /// [cloudProjectNumber] is required to link with your Google Cloud project.
  Future<bool> preparePlayIntegrity(String cloudProjectNumber) {
    return FlutterRootJailbreakCheckerPlatform.instance.preparePlayIntegrity(
      cloudProjectNumber,
    );
  }

  /// Manually requests a Google Play Integrity Token.
  ///
  /// Requires [cloudProjectNumber].
  /// You must provide either [nonce] or [requestHash].
  ///
  /// Throws an [ArgumentError] if both [nonce] and [requestHash] are null.
  Future<String?> requestPlayIntegrityToken({
    required String cloudProjectNumber,
    String? nonce,
    String? requestHash,
  }) {
    if (requestHash == null && nonce == null) {
      throw ArgumentError("Either 'requestHash' or 'nonce' must be provided.");
    }
    return FlutterRootJailbreakCheckerPlatform.instance
        .requestPlayIntegrityToken(
      cloudProjectNumber: cloudProjectNumber,
      nonce: nonce,
      requestHash: requestHash,
    );
  }
}

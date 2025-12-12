// lib/models/device_integrity_result.dart

import 'dart:io' show Platform;
import 'integrity_check_config.dart';

/// A comprehensive result model containing details from both offline and online
/// integrity checks.
class DeviceIntegrityResult {
  // --- Offline Results ---

  /// Indicates if Developer Mode (or USB Debugging) is enabled on the device.
  final bool isDeveloperModeEnabled;

  /// Indicates if the device is Rooted (Android only).
  final bool isRooted;

  /// Indicates if the app is running on an Emulator or Simulator.
  final bool isEmulator;

  /// Indicates if potentially dangerous apps (like root managers) are installed.
  final bool hasPotentiallyDangerousApps;

  /// Indicates if the device is Jailbroken (iOS only).
  final bool isJailbroken;

  /// Indicates if the device is a physical device (iOS only).
  /// For Android, this is usually inferred from [isEmulator].
  final bool isRealDevice;

  // --- Play Integrity API (Online) Results ---

  /// The token received from Google Play Integrity API (Android only).
  ///
  /// This will be null if the check failed or wasn't requested.
  final String? playIntegrityToken;

  /// Error message if the Google Play Integrity check failed.
  final String? playIntegrityError;

  /// Creates a [DeviceIntegrityResult] instance.
  DeviceIntegrityResult({
    this.isDeveloperModeEnabled = false,
    this.isRooted = false,
    this.isEmulator = false,
    this.hasPotentiallyDangerousApps = false,
    this.isJailbroken = false,
    this.isRealDevice = true,
    this.playIntegrityToken,
    this.playIntegrityError,
  });

  /// Factory method to create a result from a map returned by the native platform.
  factory DeviceIntegrityResult.fromOfflineMap(Map<String, dynamic> map) {
    if (Platform.isAndroid) {
      return DeviceIntegrityResult(
        isDeveloperModeEnabled: map['isDeveloperModeEnabled'] as bool? ?? false,
        isRooted: map['isRooted'] as bool? ?? false,
        isEmulator: map['isEmulator'] as bool? ?? false,
        hasPotentiallyDangerousApps:
            map['hasPotentiallyDangerousApps'] as bool? ?? false,
        // Android specific defaults
        isJailbroken: false,
        isRealDevice: true,
      );
    } else if (Platform.isIOS) {
      return DeviceIntegrityResult(
        isDeveloperModeEnabled: map['isDeveloperModeEnabled'] as bool? ?? false,
        isJailbroken: map['isJailbroken'] as bool? ?? false,
        isRealDevice: map['isRealDevice'] as bool? ?? true,
        // iOS specific defaults
        isRooted: false,
        isEmulator: false,
        hasPotentiallyDangerousApps: false,
      );
    }
    // Default fallback
    return DeviceIntegrityResult();
  }

  /// Returns a new instance with updated Play Integrity data.
  DeviceIntegrityResult withPlayIntegrity({String? token, String? error}) {
    return DeviceIntegrityResult(
      isDeveloperModeEnabled: isDeveloperModeEnabled,
      isRooted: isRooted,
      isEmulator: isEmulator,
      hasPotentiallyDangerousApps: hasPotentiallyDangerousApps,
      isJailbroken: isJailbroken,
      isRealDevice: isRealDevice,
      playIntegrityToken: token,
      playIntegrityError: error,
    );
  }

  /// Returns `true` if the Play Integrity API call was successful and returned a token.
  bool get wasPlayIntegritySuccessful =>
      playIntegrityToken != null && playIntegrityError == null;

  /// Determines if the device is secure based on the provided [config].
  ///
  /// Returns `true` if the device passes all configured checks.
  bool isSecure([IntegrityCheckConfig config = const IntegrityCheckConfig()]) {
    // Check Root/Jailbreak
    if (config.blockIfRootedOrJailbroken && (isRooted || isJailbroken)) {
      return false;
    }

    // Check Developer Mode
    if (config.blockIfDeveloperMode && isDeveloperModeEnabled) {
      return false;
    }

    // Check Emulator/Simulator
    if (config.blockIfEmulatorOrSimulator && (isEmulator || !isRealDevice)) {
      return false;
    }

    // Check Dangerous Apps
    if (hasPotentiallyDangerousApps) {
      return false;
    }

    // Check Play Integrity (if enabled in config)
    if (config.usePlayIntegrity && !wasPlayIntegritySuccessful) {
      return false;
    }

    return true;
  }
}

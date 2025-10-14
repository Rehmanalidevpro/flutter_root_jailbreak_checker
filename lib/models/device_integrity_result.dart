// lib/models/device_integrity_result.dart

import 'dart:io' show Platform;
import 'integrity_check_config.dart';

class DeviceIntegrityResult {

  final bool isDeveloperModeEnabled;

  final bool? isRooted;
  final bool? isEmulator;
  final bool? hasPotentiallyDangerousApps;

  final bool? isJailbroken;
  final bool? isRealDevice;

  const DeviceIntegrityResult._({
    required this.isDeveloperModeEnabled,

    this.isRooted,
    this.isEmulator,
    this.hasPotentiallyDangerousApps,

    this.isJailbroken,
    this.isRealDevice,
  });

  factory DeviceIntegrityResult.fromMap(Map<String, dynamic> map) {
    if (Platform.isAndroid) {
      return DeviceIntegrityResult._(
        isDeveloperModeEnabled: map['isDeveloperModeEnabled'] ?? false,
        isRooted: map['isRooted'] ?? false,
        isEmulator: map['isEmulator'] ?? false,
        hasPotentiallyDangerousApps: map['hasPotentiallyDangerousApps'] ?? false,
      );
    } else if (Platform.isIOS) {
      return DeviceIntegrityResult._(
        isDeveloperModeEnabled: map['isDeveloperModeEnabled'] ?? false,
        isJailbroken: map['isJailbroken'] ?? false,
        isRealDevice: map['isRealDevice'] ?? true,
      );
    }

    return DeviceIntegrityResult._(isDeveloperModeEnabled: false);
  }

  bool isSecure([IntegrityCheckConfig config = const IntegrityCheckConfig()]) {
    if (config.blockIfRootedOrJailbroken && (isRooted == true || isJailbroken == true)) {
      return false;
    }
    if (config.blockIfDeveloperMode && isDeveloperModeEnabled) {
      return false;
    }
    if (config.blockIfEmulatorOrSimulator && (isEmulator == true || isRealDevice == false)) {
      return false;
    }

    if (hasPotentiallyDangerousApps == true) {
      return false;
    }
    return true;
  }

  @override
  String toString() {
    if (Platform.isAndroid) {
      return 'AndroidIntegrityResult(\n'
          '  isRooted: $isRooted,\n'
          '  isDeveloperModeEnabled: $isDeveloperModeEnabled,\n'
          '  isEmulator: $isEmulator,\n'
          '  hasPotentiallyDangerousApps: $hasPotentiallyDangerousApps\n'
          ')';
    } else {
      return 'IOSIntegrityResult(\n'
          '  isJailbroken: $isJailbroken,\n'
          '  isRealDevice: $isRealDevice,\n'
          '  isDeveloperModeEnabled: $isDeveloperModeEnabled\n'
          ')';
    }
  }
}
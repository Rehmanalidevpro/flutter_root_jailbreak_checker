// lib/flutter_root_jailbreak_checker.dart
import 'flutter_root_jailbreak_checker_platform_interface.dart';
import 'models/device_integrity_result.dart';

export 'models/device_integrity_result.dart';
export 'models/integrity_check_config.dart';

class FlutterRootJailbreakChecker {

  Future<DeviceIntegrityResult> checkIntegrity() {
    return FlutterRootJailbreakCheckerPlatform.instance.checkIntegrity();
  }
}
// lib/flutter_root_jailbreak_checker_platform_interface.dart

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'flutter_root_jailbreak_checker_method_channel.dart';
import 'models/device_integrity_result.dart';

abstract class FlutterRootJailbreakCheckerPlatform extends PlatformInterface {

  FlutterRootJailbreakCheckerPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterRootJailbreakCheckerPlatform _instance = MethodChannelFlutterRootJailbreakChecker();

  static FlutterRootJailbreakCheckerPlatform get instance => _instance;

  static set instance(FlutterRootJailbreakCheckerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<DeviceIntegrityResult> checkIntegrity() {
    throw UnimplementedError('checkIntegrity() has not been implemented.');
  }
}
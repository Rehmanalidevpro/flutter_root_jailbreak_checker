import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_root_jailbreak_checker/flutter_root_jailbreak_checker.dart';

void main() {
  // Ensure the integration test environment is initialized
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Plugin Integration Tests', () {
    final FlutterRootJailbreakChecker plugin = FlutterRootJailbreakChecker();

    testWidgets('Verify offline integrity check returns a valid result', (WidgetTester tester) async {
      // Perform the offline integrity check
      // This is the new API implementation for Version 2.x
      final DeviceIntegrityResult result = await plugin.checkOfflineIntegrity();

      // Assertions to verify the result object is correctly populated
      // We check if the result is of type DeviceIntegrityResult
      expect(result, isA<DeviceIntegrityResult>());
      
      // Verify that the boolean indicators are initialized
      expect(result.isRooted, isA<bool>());
      expect(result.isJailbroken, isA<bool>());
    });
  });
}
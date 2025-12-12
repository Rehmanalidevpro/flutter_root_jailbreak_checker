// example/integration_test/plugin_integration_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_root_jailbreak_checker/flutter_root_jailbreak_checker.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('isDeviceRooted test', (WidgetTester tester) async {
    final FlutterRootJailbreakChecker plugin = FlutterRootJailbreakChecker();
    // Hum naye function 'isDeviceRooted' ko call kar rahe hain
    final bool isRooted = await plugin.isDeviceRooted();
    // Hum check kar rahe hain ke function ne jawab 'true' ya 'false' mein diya hai
    expect(isRooted, isA<bool>());
  });
}

// example/lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_root_jailbreak_checker/flutter_root_jailbreak_checker.dart';

void main() => runApp(const MaterialApp(home: HomePage()));

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _status = "Click the button to check device integrity";
  bool _isSafe = true;

  Future<void> _checkSecurity() async {
    // 1. Initialize the checker
    final checker = FlutterRootJailbreakChecker();

    // 2. Define configuration (Optional: Enable Play Integrity for Android)
    const config = IntegrityCheckConfig(
      blockIfRootedOrJailbroken: true,
      blockIfEmulatorOrSimulator: true,
      // usePlayIntegrity: true, // Uncomment if you have Google Cloud Project Number
      // cloudProjectNumber: "123456789",
    );

    // 3. Run the check
    final result = await checker.check(config);

    // 4. Update UI based on result
    setState(() {
      _isSafe = result.isSecure(config);
      _status = _isSafe
          ? "✅ Device is Secure"
          : "⚠️ Security Risk Detected:\n"
                "Rooted/Jailbroken: ${result.isRooted || result.isJailbroken}\n"
                "Emulator: ${result.isEmulator}\n"
                "Dangerous Apps: ${result.hasPotentiallyDangerousApps}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Root & Jailbreak Checker")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isSafe ? Icons.security : Icons.warning,
                size: 80,
                color: _isSafe ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 20),
              Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _checkSecurity,
                child: const Text("Check Integrity Now"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
  String _status = "Press the button to check device integrity.";
  bool _isSafe = true;
  bool _isLoading = false;

  // TODO: Enter your Google Cloud Project Number to enable Online Checks.
  // Example: "123456789012". Keep it null to run Offline Check only.
  final String? _googleProjectNumber = null;

  Future<void> _checkIntegrity() async {
    setState(() => _isLoading = true);

    final checker = FlutterRootJailbreakChecker();
    final bool useOnline = _googleProjectNumber != null;

    try {
      // 1. Warm up the API if using online check (Android only)
      if (useOnline) {
        await checker.preparePlayIntegrity(_googleProjectNumber!);
      }

      // 2. Configure the integrity check
      final config = IntegrityCheckConfig(
        blockIfRootedOrJailbroken: true,
        blockIfEmulatorOrSimulator: true,
        usePlayIntegrity: useOnline,
        cloudProjectNumber: _googleProjectNumber,
      );

      // 3. Execute the check
      final result = await checker.check(config);

      // 4. Update UI based on the result
      setState(() {
        _isSafe = result.isSecure(config);
        if (_isSafe) {
          _status =
              "✅ Device is Secure\n"
              "${useOnline ? '(Online Verified)' : '(Offline Check)'}";
        } else {
          _status =
              "⚠️ Security Risk Detected:\n"
              "Rooted/Jailbroken: ${result.isRooted || result.isJailbroken}\n"
              "Emulator: ${result.isEmulator}\n"
              "Tampered: ${result.playIntegrityError ?? 'No API Error'}";
        }
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Root & Jailbreak Checker")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              const CircularProgressIndicator()
            else ...[
              Icon(
                _isSafe ? Icons.security : Icons.warning_amber_rounded,
                size: 80,
                color: _isSafe ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 24),
              Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _checkIntegrity,
                child: const Text("Run Integrity Check"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

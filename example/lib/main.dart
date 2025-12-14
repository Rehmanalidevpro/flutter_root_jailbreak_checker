// example/lib/main.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_root_jailbreak_checker/flutter_root_jailbreak_checker.dart';

void main() => runApp(const MaterialApp(home: HomePage()));

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _status = "Press the button to scan.";
  bool _isSafe = true;
  bool _isLoading = false;

  // TODO: Add Google Cloud Project Number for Android Online Check (or null)
  final String? _projectNumber = "1234567890";

  Future<void> _runCheck() async {
    setState(() => _isLoading = true);
    final checker = FlutterRootJailbreakChecker();

    // Only use Play Integrity on Android if project number is provided
    final bool useOnline = Platform.isAndroid && _projectNumber != null;

    try {
      if (useOnline) {
        await checker.preparePlayIntegrity(_projectNumber!);
      }

      final config = IntegrityCheckConfig(
        blockIfRootedOrJailbroken: true,
        blockIfEmulatorOrSimulator: true,
        usePlayIntegrity: useOnline,
        cloudProjectNumber: _projectNumber,
      );

      final result = await checker.check(config);

      setState(() {
        _isSafe = result.isSecure(config);
        _status = _isSafe ? "✅ Device is Secure" : "⚠️ Security Risk Detected";

        if (!_isSafe) {
          _status +=
              "\nRoot/Jailbreak: ${result.isRooted || result.isJailbroken}";
          _status += "\nEmulator: ${result.isEmulator}";
          if (useOnline)
            _status +=
                "\nIntegrity Error: ${result.playIntegrityError ?? 'None'}";
        }
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Integrity Checker")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const CircularProgressIndicator()
              else ...[
                Icon(
                  _isSafe ? Icons.check_circle : Icons.warning_rounded,
                  size: 100,
                  color: _isSafe ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 20),
                Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _runCheck,
                    child: const Text("Scan Device Now"),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// example/lib/main.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_root_jailbreak_checker/flutter_root_jailbreak_checker.dart';

void main() => runApp(
  const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: IntegrityScannerPage(),
  ),
);

class IntegrityScannerPage extends StatefulWidget {
  const IntegrityScannerPage({super.key});

  @override
  State<IntegrityScannerPage> createState() => _IntegrityScannerPageState();
}

class _IntegrityScannerPageState extends State<IntegrityScannerPage> {
  bool _isScanning = false;
  DeviceIntegrityResult? _result;

  // TODO: Enter Google Cloud Project Number for Online Check (Android only).
  // Keep null to run Offline Check only.
  final String? _cloudProjectNumber = null; // e.g., "1234567890"

  Future<void> _startScan() async {
    setState(() => _isScanning = true);

    // 1. Initialize Checker
    final checker = FlutterRootJailbreakChecker();
    final bool useOnline = Platform.isAndroid && _cloudProjectNumber != null;

    try {
      // 2. Prepare Online API (if applicable)
      if (useOnline) {
        await checker.preparePlayIntegrity(_cloudProjectNumber!);
      }

      // 3. Configure Checks
      final config = IntegrityCheckConfig(
        blockIfRootedOrJailbroken: true,
        blockIfEmulatorOrSimulator: true,
        blockIfDeveloperMode:
            false, // We just want to detect it, not block immediately
        usePlayIntegrity: useOnline,
        cloudProjectNumber: _cloudProjectNumber,
      );

      // 4. Run Check
      final result = await checker.check(config);

      if (!mounted) return;
      setState(() => _result = result);
    } finally {
      setState(() => _isScanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Device Integrity Scanner")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- Top Status Card ---
            _buildStatusHeader(),
            const SizedBox(height: 20),

            // --- Detailed Checks List ---
            Expanded(
              child: _result == null
                  ? const Center(child: Text("Press 'Scan' to start."))
                  : ListView(
                      children: [
                        _buildCheckTile(
                          "Root / Jailbreak",
                          _result!.isRooted || _result!.isJailbroken,
                          isDanger: true,
                        ),
                        _buildCheckTile(
                          "Emulator / Simulator",
                          _result!.isEmulator || !_result!.isRealDevice,
                          isDanger: true,
                        ),
                        _buildCheckTile(
                          "Developer Mode / Debugging",
                          _result!.isDeveloperModeEnabled,
                          isDanger: true, // Mark as warning
                        ),
                        _buildCheckTile(
                          "Dangerous Apps (Root Tools)",
                          _result!.hasPotentiallyDangerousApps,
                          isDanger: true,
                        ),
                        if (_result!.playIntegrityToken != null ||
                            _result!.playIntegrityError != null)
                          _buildCheckTile(
                            "Google Play Integrity (Online)",
                            !_result!
                                .wasPlayIntegritySuccessful, // If not successful, it's bad
                            isDanger: true,
                            details:
                                _result!.playIntegrityError ??
                                "Verified & Valid",
                          ),
                      ],
                    ),
            ),

            // --- Action Button ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isScanning ? null : _startScan,
                icon: _isScanning
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.security),
                label: Text(_isScanning ? "Scanning..." : "Scan Device Now"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to display the big top status
  Widget _buildStatusHeader() {
    if (_result == null) return const SizedBox.shrink();

    // Determine overall safety based on config
    final isSafe =
        !_result!.isRooted &&
        !_result!.isJailbroken &&
        !_result!.hasPotentiallyDangerousApps &&
        (!_result!.isEmulator && _result!.isRealDevice);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isSafe ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isSafe ? Colors.green : Colors.red, width: 2),
      ),
      child: Row(
        children: [
          Icon(
            isSafe ? Icons.check_circle : Icons.gpp_bad,
            size: 50,
            color: isSafe ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isSafe ? "DEVICE SECURE" : "THREAT DETECTED",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isSafe ? Colors.green.shade800 : Colors.red.shade800,
                ),
              ),
              Text(
                isSafe ? "No integrity issues found" : "Review the list below",
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget for individual check rows
  Widget _buildCheckTile(
    String title,
    bool isDetected, {
    bool isDanger = false,
    String? details,
  }) {
    // Logic: If detecting a threat (isDanger=true), 'True' is Bad (Red).
    final bool isBad = isDanger && isDetected;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      child: ListTile(
        leading: Icon(
          isBad ? Icons.cancel : Icons.check_circle,
          color: isBad ? Colors.red : Colors.green,
          size: 30,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: details != null
            ? Text(details)
            : Text(isDetected ? "Detected (Unsafe)" : "Not Detected (Safe)"),
        trailing: isBad
            ? const Chip(
                label: Text("RISK"),
                backgroundColor: Colors.redAccent,
                labelStyle: TextStyle(color: Colors.white),
              )
            : const Chip(
                label: Text("SAFE"),
                backgroundColor: Colors.green,
                labelStyle: TextStyle(color: Colors.white),
              ),
      ),
    );
  }
}

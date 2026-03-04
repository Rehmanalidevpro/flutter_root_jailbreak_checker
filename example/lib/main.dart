import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_root_jailbreak_checker/flutter_root_jailbreak_checker.dart';

void main() {
  runApp(const RootCheckerExampleApp());
}

/// Main Application Entry Point
class RootCheckerExampleApp extends StatelessWidget {
  const RootCheckerExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Integrity Scanner Pro',
      debugShowCheckedModeBanner: false,
      home: IntegrityScannerPage(),
    );
  }
}

/// Page responsible for scanning and displaying device integrity status
class IntegrityScannerPage extends StatefulWidget {
  const IntegrityScannerPage({super.key});

  @override
  State<IntegrityScannerPage> createState() => _IntegrityScannerPageState();
}

class _IntegrityScannerPageState extends State<IntegrityScannerPage> {
  bool _isScanning = false;
  DeviceIntegrityResult? _result;

  // Cloud Project Number for Google Play Integrity (Android only)
  // Set this to your actual project number to enable online checks
  final String? _cloudProjectNumber = null; 

  /// Executes the scanning process
  Future<void> _startScan() async {
    setState(() => _isScanning = true);

    final checker = FlutterRootJailbreakChecker();
    final bool useOnlineCheck = Platform.isAndroid && _cloudProjectNumber != null;

    try {
      // Step 1: Initialize Online API if credentials are provided
      if (useOnlineCheck) {
        await checker.preparePlayIntegrity(_cloudProjectNumber);
      }

      // Step 2: Configure scan parameters
      final config = IntegrityCheckConfig(
        blockIfRootedOrJailbroken: true,
        blockIfEmulatorOrSimulator: true,
        blockIfDeveloperMode: false,
        usePlayIntegrity: useOnlineCheck,
        cloudProjectNumber: _cloudProjectNumber,
      );

      // Step 3: Perform the comprehensive integrity check
      final result = await checker.check(config);

      if (!mounted) return;
      setState(() => _result = result);
    } catch (e) {
      debugPrint("Integrity Scan Failed: $e");
    } finally {
      setState(() => _isScanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Device Integrity Scanner"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (_result != null) _buildStatusHeader(),
            const SizedBox(height: 20),
            if (_result != null) ...[
              _buildCheckTile("Root Access / Jailbreak", _result!.isRooted || _result!.isJailbroken),
              _buildCheckTile("Emulator Detection", _result!.isEmulator || !_result!.isRealDevice),
              _buildCheckTile("Developer Mode", _result!.isDeveloperModeEnabled),
              _buildCheckTile("Dangerous Applications", _result!.hasPotentiallyDangerousApps),
            ] else 
              const Center(child: Text("Ready to scan device integrity status.")),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton.icon(
          onPressed: _isScanning ? null : _startScan,
          icon: _isScanning 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
              : const Icon(Icons.security),
          label: Text(_isScanning ? "Processing..." : "Run Security Scan"),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }

  /// Displays the top-level safety status
  Widget _buildStatusHeader() {
    final bool isSafe = !(_result!.isRooted || _result!.isJailbroken || _result!.isEmulator);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isSafe ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isSafe ? Colors.green : Colors.red),
      ),
      child: Column(
        children: [
          Icon(isSafe ? Icons.verified_user : Icons.warning, size: 50, color: isSafe ? Colors.green : Colors.red),
          const SizedBox(height: 10),
          Text(isSafe ? "DEVICE SECURE" : "SECURITY RISK DETECTED", 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isSafe ? Colors.green : Colors.red)),
        ],
      ),
    );
  }

  /// Reusable tile for individual security checks
  Widget _buildCheckTile(String title, bool isDetected) {
    return Card(
      child: ListTile(
        leading: Icon(isDetected ? Icons.error_outline : Icons.check_circle_outline, 
          color: isDetected ? Colors.red : Colors.green),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(isDetected ? "Vulnerability Detected" : "Passed"),
      ),
    );
  }
}
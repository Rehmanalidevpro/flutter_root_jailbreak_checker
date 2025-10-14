// Import necessary packages.
// 'dart:io' is used to check the operating system (Android/iOS).
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
// This is the main package used to check for root or jailbreak status.
import 'package:flutter_root_jailbreak_checker/flutter_root_jailbreak_checker.dart';

// The main function, which is the entry point of the Flutter app.
void main() {
  // runApp starts the Flutter application by inflating the given widget.
  runApp(const MyApp());
}

// MyApp is the root widget of the application.
// It's a StatefulWidget because its state will change (e.g., loading status, check results).
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

// This class holds the state for the MyApp widget.
class _MyAppState extends State<MyApp> {
  // This variable will store the results of the integrity check.
  // It's nullable (?) because it won't have a value until the check is complete.
  DeviceIntegrityResult? _result;

  // A boolean to track whether the integrity check is currently running.
  // It is true by default so a loading indicator is shown on startup.
  bool _isLoading = true;

  // Configuration for the integrity check.
  // Here, we've configured it to NOT block emulators or simulators.
  // Set `blockIfEmulatorOrSimulator` to `true` if you want to treat them as "NOT SECURE".
  final _config = const IntegrityCheckConfig(
    blockIfEmulatorOrSimulator: false,
  );

  // The initState method is called once when the stateful widget is inserted into the widget tree.
  @override
  void initState() {
    super.initState();
    // We call performCheck() here to run the check as soon as the app starts.
    performCheck();
  }

  // This asynchronous function performs the device integrity check.
  Future<void> performCheck() async {
    // Set the loading state to true and update the UI.
    setState(() {
      _isLoading = true;
    });

    // Call the checker and wait for the result.
    final result = await FlutterRootJailbreakChecker().checkIntegrity();

    // After getting the result, update the state with the new result
    // and set loading to false to hide the progress indicator.
    setState(() {
      _result = result;
      _isLoading = false;
    });
  }

  // The build method describes the part of the user interface represented by this widget.
  @override
  Widget build(BuildContext context) {
    // Determine if the device is secure based on the result and configuration.
    // The `?? false` means if `_result` is null, consider it not secure.
    final isSecure = _result?.isSecure(_config) ?? false;

    // Choose the color and text based on the security status.
    final statusColor = isSecure ? Colors.green : Colors.red;
    final statusText = isSecure ? 'SECURE' : 'NOT SECURE';

    // Return the main app structure.
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Device Integrity Check'),
          // The app bar color changes based on the security status.
          backgroundColor: statusColor,
        ),
        body: Center(
          // If `_isLoading` is true, show a loading spinner. Otherwise, show the results.
          child: _isLoading
              ? const CircularProgressIndicator()
              : SingleChildScrollView( // Use SingleChildScrollView to prevent overflow on small screens.
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Display the main status text (SECURE / NOT SECURE).
                Text(
                  'Device Status: $statusText',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Detailed Report:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(), // A visual separator line.

                // Conditionally build the report based on the OS.
                // The '...' is the spread operator, which inserts all elements of a list here.
                if (Platform.isAndroid) ..._buildAndroidResults(),
                if (Platform.isIOS) ..._buildIOSResults(),

                const SizedBox(height: 24),

                // A button to allow the user to run the check again.
                ElevatedButton.icon(
                  onPressed: performCheck,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Run Check Again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // A helper method to build the list of widgets for Android-specific results.
  List<Widget> _buildAndroidResults() {
    return [
      _buildResultRow(
        'Is Device Rooted?',
        _result?.isRooted ?? false,
      ),
      _buildResultRow(
        'Is Running on Emulator?',
        _result?.isEmulator ?? false,
      ),
      _buildResultRow(
        'Has Dangerous Apps?',
        _result?.hasPotentiallyDangerousApps ?? false,
      ),
      _buildResultRow(
        'Is Developer Mode Enabled?',
        _result?.isDeveloperModeEnabled ?? false,
      ),
    ];
  }

  // A helper method to build the list of widgets for iOS-specific results.
  List<Widget> _buildIOSResults() {
    return [
      _buildResultRow(
        'Is Device Jailbroken?',
        _result?.isJailbroken ?? false,
      ),
      _buildResultRow(
        'Is Running on Simulator?',
        // `isRealDevice` is true for a real device. We negate it for the "Is Running on Simulator" check.
        !(_result?.isRealDevice ?? true),
      ),
      _buildResultRow(
        'Is Developer Mode Enabled?',
        _result?.isDeveloperModeEnabled ?? false,
      ),
    ];
  }

  // A reusable helper widget to create a consistent row for each result item.
  // It takes a title (e.g., 'Is Device Rooted?') and a boolean value.
  Widget _buildResultRow(String title, bool value) {
    // Determine the text and color based on the boolean value.
    final valueText = value ? 'Yes' : 'No';
    final valueColor = value ? Colors.red : Colors.green; // Red for "Yes" (bad), Green for "No" (good).

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Pushes children to the ends.
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Text(
            valueText,
            style: TextStyle(
              fontSize: 16,
              color: valueColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
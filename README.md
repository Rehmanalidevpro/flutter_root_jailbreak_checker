# Flutter Root & Jailbreak Checker

[![pub package](https://img.shields.io/pub/v/flutter_root_jailbreak_checker.svg)](https://pub.dev/packages/flutter_root_jailbreak_checker)

A powerful, offline-first Flutter plugin to detect rooted Android devices and jailbroken iOS devices. Designed for simplicity, performance, and providing developers with flexible control over security policies.

---

## Features

-   🛡️ **Multi-Layered Android Root Detection:** Uses several distinct checks for `su` binaries, build tags, system properties, and writable partitions to provide robust root detection.
-   🍏 **Multi-Layered iOS Jailbreak Detection:** Employs checks for common jailbreak file paths, URL schemes, and sandbox integrity to effectively detect compromised iOS devices.
-   🖥️ **Emulator & Simulator Detection:** Reliably identifies if the app is running in an emulator (Android) or a simulator (iOS).
-   🚫 **Dangerous App Check (Android):** Scans for the presence of common root management and hooking apps like Magisk, SuperSU, or Xposed Framework.
-   ⚙️ **Flexible Configuration:** Easily configure what constitutes a "secure" device. You can choose to ignore checks for developer mode, emulators, etc.
-   🚀 **Offline First:** All checks are performed locally on the device, requiring no internet connection or server-side APIs, ensuring fast and private results.
-   ✨ **Simple & Clean API:** Get a comprehensive security report or a simple `isSecure` boolean with just a single function call.

## A Crucial Note on Security: The Limits of Offline Checks

This plugin provides the best possible security checks that can be performed **offline**, directly on the device. It is designed to be a strong deterrent and will successfully stop the vast majority of users from running your app on a compromised device.

However, it's essential to understand that **no offline check can be 100% bulletproof**. All checks run in an environment that is ultimately controlled by the user. A determined and knowledgeable attacker can eventually find ways to "hide" their device's state from the app.

### For Bulletproof Security (The Professional Method)

If your application handles highly sensitive data (e.g., financial transactions, private health information) or requires the highest possible level of security, you **MUST** implement server-side verification. This is the industry-standard approach for mission-critical apps.

-   **For Android:** Use the official **[Google Play Integrity API](https://developer.android.com/google/play/integrity/overview)**.
-   **For iOS:** Use Apple's official **[DeviceCheck and App Attest Frameworks](https://developer.apple.com/documentation/devicecheck)**.

This plugin serves as an excellent and powerful **first line of defense**, but for guaranteed security, the verdict must come from a trusted server.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_root_jailbreak_checker: ^1.0.0 # Replace with the latest version
```

Then, run the command in your terminal:

```sh
flutter pub get
```

## How to Use

Using the plugin is designed to be incredibly simple and intuitive.

### Basic Usage

For a quick and easy security check using the default configuration (blocks rooted/jailbroken devices and emulators).

```dart
import 'package.flutter_root_jailbreak_checker/flutter_root_jailbreak_checker.dart';

void performSecurityCheck() async {
  final result = await FlutterRootJailbreakChecker().checkIntegrity();

  // Use the simple `isSecure` getter for a quick verdict.
  if (result.isSecure()) {
    print("✅ SUCCESS: The device is secure.");
  } else {
    print("🚨 DANGER: The device is NOT secure!");
    // You should restrict access to sensitive features or show a warning.
  }
}
```

### Advanced Usage with Custom Configuration

You have full control over the security policy. For example, if you want to allow your app to run on emulators but not on rooted devices, you can provide a custom configuration.

```dart
import 'package.flutter_root_jailbreak_checker/flutter_root_jailbreak_checker.dart';

void performCustomSecurityCheck() async {
  // 1. Create a custom configuration.
  final config = IntegrityCheckConfig(
    blockIfEmulatorOrSimulator: false, // Allow emulators/simulators
    blockIfDeveloperMode: false,       // Allow developer mode
    blockIfRootedOrJailbroken: true,   // But strictly block rooted/jailbroken devices
  );

  // 2. Get the detailed result from the plugin.
  final result = await FlutterRootJailbreakChecker().checkIntegrity();

  // 3. Pass your custom config to the `isSecure` method.
  if (result.isSecure(config)) {
    print("✅ SUCCESS: The device passes our custom security policy.");
  } else {
    print("🚨 DANGER: The device fails our custom security policy.");
  }

  // You can still access the detailed report for logging or analytics:
  print(result.toString());
}
```

## API Reference

### `DeviceIntegrityResult`

This is the main object returned by the plugin. It contains a detailed breakdown of all checks.

| Property                      | Platform | Description                                                                 |
| ----------------------------- | -------- | --------------------------------------------------------------------------- |
| `isDeveloperModeEnabled`      | Both     | `true` if Developer Mode is enabled.                                        |
| `isRooted`                    | Android  | `true` if the device is detected as rooted.                                 |
| `isEmulator`                  | Android  | `true` if the app is running on an emulator.                                |
| `hasPotentiallyDangerousApps` | Android  | `true` if apps like Magisk or Xposed are installed.                         |
| `isJailbroken`                | iOS      | `true` if the device is detected as jailbroken.                             |
| `isRealDevice`                | iOS      | `false` if the app is running on a simulator.                               |
| `isSecure(config)`            | Both     | A handy method that returns `true` or `false` based on your `IntegrityCheckConfig`. |

### `IntegrityCheckConfig`

Use this class to define your app's security rules.

| Property                     | Default | Description                                                    |
| ---------------------------- | ------- | -------------------------------------------------------------- |
| `blockIfRootedOrJailbroken`  | `true`  | Fails the check if the device is rooted or jailbroken.         |
| `blockIfDeveloperMode`       | `false` | Fails the check if Developer Mode is enabled.                  |
| `blockIfEmulatorOrSimulator` | `true`  | Fails the check if the app is on an emulator or simulator.     |

## About the Author

Developed with ❤️ by **Rehman Ali**, a passionate software developer dedicated to creating robust, secure, and easy-to-use tools for the Flutter community.

-   **GitHub:** [@rehmanalidevpro](https://github.com/rehmanalidevpro)

## Contributing

Contributions are always welcome! If you find a bug, have a suggestion for a new check, or want to improve the documentation, please feel free to open an issue or submit a pull request on the [GitHub repository](https://github.com/rehmanalidevpro/flutter_root_jailbreak_checker). 

## License

This project is licensed under the MIT License - see the `LICENSE` file for details.
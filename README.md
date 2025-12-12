# Flutter Root & Jailbreak Checker

A streamlined, offline-first Flutter plugin for detecting rooted Android devices and jailbroken iOS devices. Built for performance, clarity, and flexible security policy management.

---

## Key Capabilities

* **Comprehensive Android Root Detection:** Multiple checks including `su` binaries, build tags, system properties, and unsafe partitions.
* **Robust iOS Jailbreak Detection:** Identifies jailbreak paths, sandbox violations, and unsafe URL schemes.
* **Emulator and Simulator Detection:** Reliable identification for Android emulators and iOS simulators.
* **Unsafe App Detection (Android):** Detects common root and hooking tools such as Magisk, SuperSU, and Xposed.
* **Configurable Security Policies:** Enable or disable checks depending on your application requirements.
* **Offline Operation:** All checks execute locally without network dependency.
* **Simple API Surface:** Retrieve a complete integrity report or a single secure/unsafe verdict.

---

## Security Considerations

This plugin provides advanced device integrity checks executed entirely on the client device. It serves as a strong deterrent and is suitable for most production use cases. However, because all offline checks can be bypassed on sufficiently compromised systems, no local-only solution can guarantee complete protection.

For high‑security applications, incorporate platform‑level server‑verified solutions:

* **Android:** Google Play Integrity API
* **iOS:** DeviceCheck and App Attest

---

## Installation

Add to your project's `pubspec.yaml`:

```yaml
dependencies:
  flutter_root_jailbreak_checker: ^1.0.0
```

Then run:

```sh
flutter pub get
```

---

## Basic Usage

```dart
import 'package:flutter_root_jailbreak_checker/flutter_root_jailbreak_checker.dart';

void performSecurityCheck() async {
  final result = await FlutterRootJailbreakChecker().checkIntegrity();

  if (result.isSecure()) {
    print("Device is secure.");
  } else {
    print("Device is not secure.");
  }
}
```

---

## Advanced Usage (Custom Policy)

```dart
import 'package:flutter_root_jailbreak_checker/flutter_root_jailbreak_checker.dart';

void performCustomSecurityCheck() async {
  final config = IntegrityCheckConfig(
    blockIfEmulatorOrSimulator: false,
    blockIfDeveloperMode: false,
    blockIfRootedOrJailbroken: true,
  );

  final result = await FlutterRootJailbreakChecker().checkIntegrity();

  if (result.isSecure(config)) {
    print("Device passes custom policy.");
  } else {
    print("Device fails custom policy.");
  }

  print(result.toString());
}
```

---

## API Overview

### DeviceIntegrityResult

| Property                    | Platform     | Description                                             |
| --------------------------- | ------------ | ------------------------------------------------------- |
| isDeveloperModeEnabled      | Android, iOS | Indicates whether developer mode is active.             |
| isRooted                    | Android      | True if device is rooted.                               |
| isEmulator                  | Android      | True if running on an emulator.                         |
| hasPotentiallyDangerousApps | Android      | True if known root or hooking apps are installed.       |
| isJailbroken                | iOS          | True if jailbreak is detected.                          |
| isRealDevice                | iOS          | False if running on a simulator.                        |
| isSecure(config)            | Both         | Evaluates security based on the supplied configuration. |

### IntegrityCheckConfig

| Property                   | Default | Description                                 |
| -------------------------- | ------- | ------------------------------------------- |
| blockIfRootedOrJailbroken  | true    | Blocks rooted or jailbroken devices.        |
| blockIfDeveloperMode       | false   | Blocks devices with developer mode enabled. |
| blockIfEmulatorOrSimulator | true    | Blocks emulators and simulators.            |

---

## Author

Created by **Rehman Ali**.

GitHub: @rehmanalidevpro

---

## Contributing

Contributions are welcome. Submit issues or pull requests via the GitHub repository.

---

## License

Distributed under the MIT License. See the LICENSE file for details.

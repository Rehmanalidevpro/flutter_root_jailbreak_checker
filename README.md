# Flutter Root & Jailbreak Checker

A streamlined, offline-first Flutter plugin for detecting rooted Android devices and jailbroken iOS devices. Built for performance, clarity, and flexible security policy management.

---

## Key Capabilities

* **Comprehensive Android Root Detection:** Multiple checks including `su` binaries, build tags, system properties, and unsafe partitions.
* **Robust iOS Jailbreak Detection:** Identifies jailbreak paths, sandbox violations, and unsafe URL schemes.
* **Emulator and Simulator Detection:** Reliable identification for Android emulators and iOS simulators.
* **Unsafe App Detection (Android):** Detects common root and hooking tools such as Magisk, SuperSU, and Xposed.
* **Configurable Security Policies:** Enable or disable checks depending on your application requirements.
* **Google Play Integrity (Online):** Verifies device integrity using Google's official online API for banking-grade security.
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
  flutter_root_jailbreak_checker: ^2.1.4
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
  final result = await FlutterRootJailbreakChecker().checkOfflineIntegrity();

  if (result.isSecure()) {
    print("Device is secure.");
  } else {
    print("Device is not secure.");
  }
}
```

---

## 🛡️ Google Play Integrity (Online Check - Android)

This plugin supports Google Play Integrity API for banking-grade security. This checks if the app was installed from the Play Store and is not tampered with.

**Prerequisites:**
1. Enable **Play Integrity API** in Google Cloud Console.
2. Get your **Cloud Project Number**.

```dart
import 'package:flutter_root_jailbreak_checker/flutter_root_jailbreak_checker.dart';

void performOnlineCheck() async {
  // Initialize the checker
  final checker = FlutterRootJailbreakChecker();

  // Prepare the API (Optional but recommended for speed)
  // Replace '123456789' with your actual Google Cloud Project Number
  await checker.preparePlayIntegrity("123456789");

  // Configure the check
  final config = IntegrityCheckConfig(
    usePlayIntegrity: true,
    cloudProjectNumber: "123456789", // REQUIRED for online check
  );

  // Run the check
  final result = await checker.check(config);

  if (result.wasPlayIntegritySuccessful) {
    print("✅ Online Check Passed. Token: ${result.playIntegrityToken}");
  } else {
    print("❌ Online Check Failed: ${result.playIntegrityError}");
  }
}

```

---
##  How to Enable Google Play Integrity (Online Check)

To use the advanced online security check (Android), you need a **Google Cloud Project Number**.

1.  Go to the [Google Cloud Console](https://console.cloud.google.com/).
2.  Create a new project or select an existing one.
3.  In the search bar, type **"Play Integrity API"** and select it.
4.  Click **Enable** to activate the API for your project.
5.  Go to the **Dashboard** (Home) of your project.
6.  Look for the **Project Info** card. Copy the **Project Number** (e.g., `123456789012`).
    *   *Note: Use the "Project Number", not the "Project ID".*
7.  Pass this number to the `IntegrityCheckConfig` in your Flutter code.

```dart
final config = IntegrityCheckConfig(
  usePlayIntegrity: true,
  cloudProjectNumber: "YOUR_PROJECT_NUMBER_HERE",
);

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

  final result = await FlutterRootJailbreakChecker().checkOfflineIntegrity();

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

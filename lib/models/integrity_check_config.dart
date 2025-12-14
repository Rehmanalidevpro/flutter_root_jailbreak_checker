// lib/models/integrity_check_config.dart

/// Configuration class to control the behavior of the integrity check.
///
/// Use this to toggle specific checks like Root/Jailbreak detection,
/// Developer Mode detection, and Google Play Integrity API usage.
class IntegrityCheckConfig {
  /// If set to true, the check will flag the device as unsafe if Root (Android)
  /// or Jailbreak (iOS) is detected.
  ///
  /// Defaults to `true`.
  final bool blockIfRootedOrJailbroken;

  /// If set to true, the check will flag the device as unsafe if Developer Options
  /// or USB Debugging is enabled.
  ///
  /// Defaults to `false`.
  final bool blockIfDeveloperMode;

  /// If set to true, the check will flag the device as unsafe if it is running
  /// on an Emulator or Simulator.
  ///
  /// Defaults to `true`.
  final bool blockIfEmulatorOrSimulator;

  /// If set to true, the plugin will attempt to verify the device using
  /// the Google Play Integrity API (Android only).
  ///
  /// Requires [cloudProjectNumber] to be provided.
  /// Defaults to `false`.
  final bool usePlayIntegrity;

  /// The Google Cloud Project Number.
  ///
  /// Required if [usePlayIntegrity] is set to `true`.
  final String? cloudProjectNumber;

  /// A unique nonce string for the Play Integrity request.
  ///
  /// Used to prevent replay attacks.
  final String? nonce;

  /// An optional hash of the request to be verified by the Play Integrity API.
  final String? requestHash;

  /// Creates a new instance of [IntegrityCheckConfig].
  ///
  /// By default, it checks for Root/Jailbreak and Emulators, but ignores Developer Mode.
  const IntegrityCheckConfig({
    this.blockIfRootedOrJailbroken = true,
    this.blockIfDeveloperMode = false,
    this.blockIfEmulatorOrSimulator = true,
    this.usePlayIntegrity = false,
    this.cloudProjectNumber,
    this.nonce,
    this.requestHash,
  }) : assert(
         !usePlayIntegrity || cloudProjectNumber != null,
         'cloudProjectNumber cannot be null when usePlayIntegrity is true.',
       );
}

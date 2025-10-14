// lib/models/integrity_check_config.dart

class IntegrityCheckConfig {

  final bool blockIfRootedOrJailbroken;

  final bool blockIfDeveloperMode;

  final bool blockIfEmulatorOrSimulator;

  const IntegrityCheckConfig({
    this.blockIfRootedOrJailbroken = true,
    this.blockIfDeveloperMode = false,
    this.blockIfEmulatorOrSimulator = true,
  });
}
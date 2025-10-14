// ios/Classes/FlutterRootJailbreakCheckerPlugin.swift

import Flutter
import UIKit

public class SwiftFlutterRootJailbreakCheckerPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_root_jailbreak_checker", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterRootJailbreakCheckerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "checkIntegrity" {
            var results = [String: Any]()
            results["isJailbroken"] = isJailbroken()
            results["isRealDevice"] = isRealDevice()
            results["isDeveloperModeEnabled"] = false

            result(results)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    private func isJailbroken() -> Bool {
        return checkFilePaths() || checkURLSchemes() || canWriteOutsideSandbox()
    }

    private func checkFilePaths() -> Bool {
        let fileManager = FileManager.default
        let suspiciousPaths = [
            "/Applications/Cydia.app",
            "/Applications/Sileo.app",
            "/Applications/Zebra.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/etc/apt",
            "/private/var/lib/apt/",
            "/usr/bin/ssh"
        ]

        for path in suspiciousPaths {
            if fileManager.fileExists(atPath: path) {
                return true
            }
        }
        return false
    }

    private func checkURLSchemes() -> Bool {
        if let cydiaURL = URL(string: "cydia://package/com.example.package") {
            if UIApplication.shared.canOpenURL(cydiaURL) {
                return true
            }
        }
        return false
    }

    private func canWriteOutsideSandbox() -> Bool {
        let path = "/private/jailbreak.txt"
        do {
            try "Jailbreak Test".write(toFile: path, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(atPath: path)
            return true
        } catch {
            return false
        }
    }

    private func isRealDevice() -> Bool {
        #if targetEnvironment(simulator)
            return false
        #else
            return true
        #endif
    }
}
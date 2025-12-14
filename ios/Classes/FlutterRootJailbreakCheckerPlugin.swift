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
        // ERROR FIX 1: Method name must match Dart code ("checkOfflineIntegrity")
        if call.method == "checkOfflineIntegrity" {
            
            let jailbroken = isJailbroken()
            let realDevice = isRealDevice()
            
            // ERROR FIX 2: Return ALL keys expected by Dart Model (DeviceIntegrityResult)
            var results = [String: Any]()
            results["isJailbroken"] = jailbroken
            results["isRealDevice"] = realDevice
            results["isEmulator"] = !realDevice // Simulator = !Real
            results["isRooted"] = false // iOS never has "Root" (it has Jailbreak)
            results["hasPotentiallyDangerousApps"] = jailbroken // If jailbroken, apps are dangerous
            results["isDeveloperModeEnabled"] = false // Difficult to detect on iOS safely
            
            result(results)
            
        } else if call.method == "preparePlayIntegrity" || call.method == "requestPlayIntegrityToken" {
            // ERROR FIX 3: Handle Online Check calls gracefully on iOS
            // Return error code "UNAVAILABLE" so Dart knows it's not supported on iOS
            result(FlutterError(code: "UNAVAILABLE", message: "Google Play Integrity is Android only.", details: nil))
            
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    // --- 🛡️ REAL JAILBREAK LOGIC (YE BILKUL THEEK HAI) ---

    private func isJailbroken() -> Bool {
        // Agar Simulator hai to Jailbreak check skip karo (False positives se bachne ke liye)
        if !isRealDevice() {
            return false
        }
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
        // URL Schemes check karne ke liye Info.plist mein allow-list honi chahiye, 
        // lekin ye code safe backup hai.
        if let cydiaURL = URL(string: "cydia://package/com.example.package") {
            if UIApplication.shared.canOpenURL(cydiaURL) {
                return true
            }
        }
        return false
    }

    private func canWriteOutsideSandbox() -> Bool {
        let path = "/private/jailbreak_test.txt"
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
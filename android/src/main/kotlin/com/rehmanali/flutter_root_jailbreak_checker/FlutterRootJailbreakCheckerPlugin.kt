//com.rehmanali.flutter_root_jailbreak_checker.FlutterRootJailbreakCheckerPlugin

package com.rehmanali.flutter_root_jailbreak_checker

import android.content.Context
import android.content.pm.PackageManager
import android.provider.Settings
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
import java.io.BufferedReader
import java.io.InputStreamReader

class FlutterRootJailbreakCheckerPlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var channel : MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_root_jailbreak_checker")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "checkIntegrity") {
            val results = HashMap<String, Any>()

            results["isRooted"] = isDeviceRooted()
            results["isDeveloperModeEnabled"] = isDeveloperModeEnabled()
            results["isEmulator"] = isEmulator()

            results["hasPotentiallyDangerousApps"] = hasPotentiallyDangerousApps()

            result.success(results)
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun isDeveloperModeEnabled(): Boolean {
        return Settings.Secure.getInt(context.contentResolver, "development_settings_enabled", 0) != 0
    }

    private fun isEmulator(): Boolean {
        return (android.os.Build.FINGERPRINT.startsWith("generic")
                || android.os.Build.FINGERPRINT.startsWith("unknown")
                || android.os.Build.MODEL.contains("google_sdk")
                || android.os.Build.MODEL.contains("Emulator")
                || android.os.Build.MODEL.contains("Android SDK built for x86")
                || android.os.Build.MANUFACTURER.contains("Genymotion")
                || (android.os.Build.BRAND.startsWith("generic") && android.os.Build.DEVICE.startsWith("generic"))
                || "google_sdk" == android.os.Build.PRODUCT)
    }

    private fun hasPotentiallyDangerousApps(): Boolean {
        val dangerousApps = listOf(
            "com.topjohnwu.magisk",
            "eu.chainfire.supersu",
            "com.koushikdutta.superuser",
            "com.thirdparty.superuser",
            "com.yellowes.su",
            "com.noshufou.android.su",
            "com.kingroot.kinguser",
            "com.kingo.root",
            "com.qihoo.permmgr",
            "de.robv.android.xposed.installer",
            "io.va.exposed",
            "com.saurik.substrate"
        )
        val pm = context.packageManager
        for (appName in dangerousApps) {
            try {
                pm.getPackageInfo(appName, PackageManager.GET_ACTIVITIES)
                return true
            } catch (e: PackageManager.NameNotFoundException) {

            }
        }
        return false
    }

    private fun isDeviceRooted(): Boolean {
        return checkRootMethod1() || checkRootMethod2() || checkRootMethod3() || checkRootMethod4() || checkRootMethod5()
    }

    private fun checkRootMethod1(): Boolean {
        val buildTags = android.os.Build.TAGS
        return buildTags != null && buildTags.contains("test-keys")
    }

    private fun checkRootMethod2(): Boolean {
        val paths = arrayOf(
            "/system/app/Superuser.apk", "/sbin/su", "/system/bin/su", "/system/xbin/su",
            "/data/local/xbin/su", "/data/local/bin/su", "/system/sd/xbin/su",
            "/system/bin/failsafe/su", "/data/local/su", "/su/bin/su",
            "/system/usr/we-need-root/", "/data/data/com.noshufou.android.su/"
        )
        for (path in paths) {
            if (File(path).exists()) return true
        }
        return false
    }

    private fun checkRootMethod3(): Boolean {
        var process: Process? = null
        return try {
            process = Runtime.getRuntime().exec(arrayOf("/system/xbin/which", "su"))
            val reader = BufferedReader(InputStreamReader(process.inputStream))
            reader.readLine() != null
        } catch (e: Exception) {
            false
        } finally {
            process?.destroy()
        }
    }

    private fun checkRootMethod4(): Boolean {
        val command = "getprop ro.secure"
        try {
            val prop = Runtime.getRuntime().exec(command).inputStream.bufferedReader().readLine()
            return prop == "0"
        } catch(e: Exception) {
            return false
        }
    }

    private fun checkRootMethod5(): Boolean {
        val command = "mount"
        try {
            val process = Runtime.getRuntime().exec(command)
            val reader = BufferedReader(InputStreamReader(process.inputStream))
            var line: String?
            while (reader.readLine().also { line = it } != null) {
                if (line!!.contains("/system") && line!!.contains("rw,")) {
                    return true
                }
            }
        } catch(e: Exception) {

        }
        return false
    }
}
package com.rehmanali.flutter_root_jailbreak_checker

import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.provider.Settings
import android.os.Build

// --- GOOGLE PLAY INTEGRITY IMPORTS ---
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.StandardIntegrityManager
import com.google.android.play.core.integrity.StandardIntegrityManager.StandardIntegrityTokenProvider
import com.google.android.play.core.integrity.StandardIntegrityManager.PrepareIntegrityTokenRequest
import com.google.android.play.core.integrity.StandardIntegrityManager.StandardIntegrityTokenRequest

// --- FLUTTER IMPORTS ---
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

// --- UTILS IMPORTS ---
import java.io.BufferedReader
import java.io.File
import java.io.InputStreamReader
import kotlinx.coroutines.*
import kotlinx.coroutines.tasks.await

/**
 * FlutterRootJailbreakCheckerPlugin
 * Top-Class Implementation for Root, Emulator & Integrity Checks.
 */
class FlutterRootJailbreakCheckerPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {

    // Flutter Communication
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var activity: Activity? = null

    // Coroutine Scope for Background Tasks (Prevents UI Lag)
    private val coroutineScope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    // Cache for Play Integrity Provider
    private var standardIntegrityTokenProvider: StandardIntegrityTokenProvider? = null

    // --- LIFECYCLE METHODS ---

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_root_jailbreak_checker")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        coroutineScope.cancel() // Clean up to prevent memory leaks
    }

    // --- METHOD CHANNEL HANDLER ---

    override fun onMethodCall(call: MethodCall, result: Result) {
        // Launching a coroutine to handle async tasks safely
        coroutineScope.launch {
            try {
                when (call.method) {
                    "checkOfflineIntegrity" -> {
                        // Switch to IO thread for heavy checks
                        val checkResult = performOfflineChecks()
                        result.success(checkResult)
                    }
                    "preparePlayIntegrity" -> handlePreparePlayIntegrity(call, result)
                    "requestPlayIntegrityToken" -> handleRequestPlayIntegrityToken(call, result)
                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                // Global Error Handling: App won't crash, it sends error to Flutter
                result.error("NATIVE_ERROR", e.message ?: "Unknown error occurred", null)
            }
        }
    }

    // --- GOOGLE PLAY INTEGRITY LOGIC (ONLINE) ---

    private suspend fun handlePreparePlayIntegrity(call: MethodCall, result: Result) {
        val cloudProjectNumberStr = call.argument<String>("cloudProjectNumber")

        if (cloudProjectNumberStr.isNullOrEmpty()) {
            result.error("MISSING_ARG", "Cloud Project Number is required.", null)
            return
        }

        val cloudProjectNumber = cloudProjectNumberStr.toLongOrNull() ?: 0L

        try {
            val standardIntegrityManager = IntegrityManagerFactory.createStandard(context)

            // Build Request
            val requestBuilder = PrepareIntegrityTokenRequest.builder()
                .setCloudProjectNumber(cloudProjectNumber)
                .build()

            // Await Result from Google
            standardIntegrityTokenProvider = standardIntegrityManager.prepareIntegrityToken(requestBuilder).await()

            result.success(true)
        } catch (e: Exception) {
            result.error("PREPARE_FAILED", e.message, null)
        }
    }

    private suspend fun handleRequestPlayIntegrityToken(call: MethodCall, result: Result) {
        val cloudProjectNumberStr = call.argument<String>("cloudProjectNumber")
        val requestHash = call.argument<String>("requestHash")

        try {
            // Auto-prepare if not ready
            if (standardIntegrityTokenProvider == null) {
                if (!cloudProjectNumberStr.isNullOrEmpty()) {
                    val cloudProjectNumber = cloudProjectNumberStr.toLongOrNull() ?: 0L
                    val manager = IntegrityManagerFactory.createStandard(context)
                    val req = PrepareIntegrityTokenRequest.builder()
                        .setCloudProjectNumber(cloudProjectNumber)
                        .build()
                    standardIntegrityTokenProvider = manager.prepareIntegrityToken(req).await()
                } else {
                    result.error("PROVIDER_NOT_READY", "Call preparePlayIntegrity() first or provide cloudProjectNumber.", null)
                    return
                }
            }

            val provider = standardIntegrityTokenProvider!!

            // Build Token Request
            val tokenReqBuilder = StandardIntegrityTokenRequest.builder()
            if (requestHash != null) {
                tokenReqBuilder.setRequestHash(requestHash)
            }

            // Fetch Token
            val tokenResponse = provider.request(tokenReqBuilder.build()).await()
            result.success(tokenResponse.token())

        } catch (e: Exception) {
            result.error("TOKEN_FAILED", e.message, null)
        }
    }

    // --- OFFLINE CHECKS LOGIC (The Core Security) ---

    private suspend fun performOfflineChecks(): HashMap<String, Any> = withContext(Dispatchers.IO) {
        val results = HashMap<String, Any>()

        // Parallel checks or sequential checks on IO thread
        results["isRooted"] = isDeviceRooted()
        results["isDeveloperModeEnabled"] = isDeveloperModeEnabled()
        results["isEmulator"] = isEmulator()
        results["hasPotentiallyDangerousApps"] = hasPotentiallyDangerousApps()

        // Default values for Android
        results["isJailbroken"] = false
        results["isRealDevice"] = true

        return@withContext results
    }

    // 1. Developer Mode Check
    private fun isDeveloperModeEnabled(): Boolean {
        return Settings.Secure.getInt(
            context.contentResolver,
            Settings.Global.DEVELOPMENT_SETTINGS_ENABLED, 0
        ) != 0
    }

    // 2. Emulator Detection (Comprehensive)
    private fun isEmulator(): Boolean {
        val brand = Build.BRAND
        val device = Build.DEVICE
        val fingerprint = Build.FINGERPRINT
        val model = Build.MODEL
        val manufacturer = Build.MANUFACTURER
        val product = Build.PRODUCT
        val hardware = Build.HARDWARE

        return fingerprint.startsWith("generic")
                || fingerprint.startsWith("unknown")
                || model.contains("google_sdk")
                || model.contains("Emulator")
                || model.contains("Android SDK built for x86")
                || manufacturer.contains("Genymotion")
                || (brand.startsWith("generic") && device.startsWith("generic"))
                || "google_sdk" == product
                || hardware.contains("goldfish")
                || hardware.contains("ranchu")
                || product.contains("sdk_google")
                || product.contains("vbox86p")
                || product.contains("emulator")
                || product.contains("simulator")
    }

    // 3. Dangerous Apps Detection (Root Tools)
    private fun hasPotentiallyDangerousApps(): Boolean {
        val dangerousPackages = arrayOf(
            "com.topjohnwu.magisk",
            "com.thirdparty.superuser",
            "eu.chainfire.supersu",
            "com.noshufou.android.su",
            "com.koushikdutta.superuser",
            "com.zachspenner.zbuster",
            "com.ramdroid.appquarantine",
            "com.devadvance.rootcloak",
            "de.robv.android.xposed.installer"
        )

        val pm = context.packageManager
        for (pkg in dangerousPackages) {
            try {
                pm.getPackageInfo(pkg, 0)
                return true // Found a dangerous app
            } catch (e: PackageManager.NameNotFoundException) {
                // App not found, continue checking
            }
        }
        return false
    }

    // 4. Root Detection (Multiple Methods)
    private fun isDeviceRooted(): Boolean {
        return checkRootMethod1() || checkRootMethod2() || checkRootMethod3()
    }

    // Method 1: Check Build Tags
    private fun checkRootMethod1(): Boolean {
        val buildTags = Build.TAGS
        return buildTags != null && buildTags.contains("test-keys")
    }

    // Method 2: Check Standard SU Paths
    private fun checkRootMethod2(): Boolean {
        val paths = arrayOf(
            "/system/app/Superuser.apk",
            "/sbin/su",
            "/system/bin/su",
            "/system/xbin/su",
            "/data/local/xbin/su",
            "/data/local/bin/su",
            "/system/sd/xbin/su",
            "/system/bin/failsafe/su",
            "/data/local/su",
            "/su/bin/su"
        )
        for (path in paths) {
            if (File(path).exists()) return true
        }
        return false
    }

    // Method 3: Execute SU command
    private fun checkRootMethod3(): Boolean {
        var process: Process? = null
        return try {
            process = Runtime.getRuntime().exec(arrayOf("/system/xbin/which", "su"))
            val inStream = BufferedReader(InputStreamReader(process.inputStream))
            inStream.readLine() != null
        } catch (t: Throwable) {
            false
        } finally {
            process?.destroy()
        }
    }

    // --- Activity Aware (Required for some plugins, kept for safety) ---
    override fun onAttachedToActivity(binding: ActivityPluginBinding) { activity = binding.activity }
    override fun onDetachedFromActivity() { activity = null }
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) { activity = binding.activity }
    override fun onDetachedFromActivityForConfigChanges() { activity = null }
}
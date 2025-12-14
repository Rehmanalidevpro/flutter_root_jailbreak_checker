// android/src/main/kotlin/com/rehmanali/flutter_root_jailbreak_checker/FlutterRootJailbreakCheckerPlugin.kt

package com.rehmanali.flutter_root_jailbreak_checker

import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.provider.Settings
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.IntegrityTokenRequest
import com.google.android.play.core.integrity.IntegrityTokenResponse
import com.google.android.play.core.integrity.PrepareIntegrityTokenRequest
import com.google.android.play.core.integrity.StandardIntegrityManager
import com.google.android.play.core.integrity.StandardIntegrityToken
import com.google.android.play.core.integrity.StandardIntegrityTokenProvider
import com.google.android.play.core.integrity.StandardIntegrityTokenRequest
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.BufferedReader
import java.io.File
import java.io.InputStreamReader
import kotlinx.coroutines.*
import kotlinx.coroutines.tasks.await

class FlutterRootJailbreakCheckerPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var activity: Activity? = null
    private val coroutineScope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    private var standardIntegrityTokenProvider: StandardIntegrityTokenProvider? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_root_jailbreak_checker")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        coroutineScope.launch {
            try {
                when (call.method) {
                    "checkOfflineIntegrity" -> result.success(performOfflineChecks())
                    "preparePlayIntegrity" -> handlePreparePlayIntegrity(call, result)
                    "requestPlayIntegrityToken" -> handleRequestPlayIntegrityToken(call, result)
                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                result.error("NATIVE_ERROR", e.message ?: "Unknown native error", null)
            }
        }
    }

    private suspend fun handlePreparePlayIntegrity(call: MethodCall, result: Result) {
        val cloudProjectNumber = call.argument<String>("cloudProjectNumber")?.toLongOrNull()
            ?: return result.error("MISSING_ARG", "Cloud project number is required.", null)

        val standardIntegrityManager = IntegrityManagerFactory.createStandard(context)

        standardIntegrityTokenProvider = standardIntegrityManager.prepareIntegrityToken(
            PrepareIntegrityTokenRequest.builder()
                .setCloudProjectNumber(cloudProjectNumber)
                .build()
        ).await()

        result.success(true)
    }

    private suspend fun handleRequestPlayIntegrityToken(call: MethodCall, result: Result) {
        val cloudProjectNumber = call.argument<String>("cloudProjectNumber")?.toLongOrNull()
        val requestHash = call.argument<String>("requestHash")
        val nonce = call.argument<String>("nonce")
        val token: String?

        if (requestHash != null) {
            val provider = standardIntegrityTokenProvider
            if (provider == null) {
                // Auto-prepare if not ready (Safety Fallback)
                if (cloudProjectNumber != null) {
                   val manager = IntegrityManagerFactory.createStandard(context)
                   standardIntegrityTokenProvider = manager.prepareIntegrityToken(
                       PrepareIntegrityTokenRequest.builder().setCloudProjectNumber(cloudProjectNumber).build()
                   ).await()
                } else {
                   return result.error("PROVIDER_NOT_READY", "Call preparePlayIntegrity() first.", null)
                }
            }
            
            val tokenResponse = standardIntegrityTokenProvider!!.request(
                StandardIntegrityTokenRequest.builder().setRequestHash(requestHash).build()
            ).await()
            token = tokenResponse.token()

        } else if (nonce != null) {
            if (cloudProjectNumber == null) return result.error("MISSING_ARG", "Cloud project number required.", null)
            val integrityManager = IntegrityManagerFactory.create(context)
            val tokenResponse = integrityManager.requestIntegrityToken(
                IntegrityTokenRequest.builder()
                    .setNonce(nonce)
                    .setCloudProjectNumber(cloudProjectNumber)
                    .build()
            ).await()
            token = tokenResponse.token()
        } else {
            return result.error("MISSING_ARG", "Either 'requestHash' or 'nonce' must be provided.", null)
        }
        result.success(token)
    }

    private suspend fun performOfflineChecks(): HashMap<String, Any> = withContext(Dispatchers.IO) {
        val results = HashMap<String, Any>()
        results["isRooted"] = isDeviceRooted()
        results["isDeveloperModeEnabled"] = isDeveloperModeEnabled()
        results["isEmulator"] = isEmulator()
        results["hasPotentiallyDangerousApps"] = hasPotentiallyDangerousApps()
        // iOS specific keys (Android pe false hi rahenge)
        results["isJailbroken"] = false
        results["isRealDevice"] = true
        return@withContext results
    }

    // --- REAL LOGIC IMPLEMENTATION ---

    private fun isDeveloperModeEnabled(): Boolean {
        return Settings.Secure.getInt(context.contentResolver, Settings.Global.DEVELOPMENT_SETTINGS_ENABLED, 0) != 0
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
        val dangerousPackages = arrayOf(
            "com.topjohnwu.magisk",
            "com.thirdparty.superuser",
            "eu.chainfire.supersu",
            "com.noshufou.android.su",
            "com.koushikdutta.superuser",
            "com.zachspenner.zbuster",
            "com.ramdroid.appquarantine",
            "com.devadvance.rootcloak"
        )
        val pm = context.packageManager
        for (pkg in dangerousPackages) {
            try {
                pm.getPackageInfo(pkg, 0)
                return true
            } catch (e: PackageManager.NameNotFoundException) {
                // App not found, safe.
            }
        }
        return false
    }

    private fun isDeviceRooted(): Boolean {
        return checkRootMethod1() || checkRootMethod2() || checkRootMethod3()
    }

    private fun checkRootMethod1(): Boolean {
        val buildTags = android.os.Build.TAGS
        return buildTags != null && buildTags.contains("test-keys")
    }

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

    // --- Lifecycle Methods ---
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        coroutineScope.cancel()
    }
    override fun onAttachedToActivity(binding: ActivityPluginBinding) { activity = binding.activity }
    override fun onDetachedFromActivity() { activity = null }
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) { activity = binding.activity }
    override fun onDetachedFromActivityForConfigChanges() { activity = null }
}
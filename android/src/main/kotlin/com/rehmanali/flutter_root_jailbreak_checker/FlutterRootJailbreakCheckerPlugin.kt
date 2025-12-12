// android/src/main/kotlin/com/rehmanali/flutter_root_jailbreak_checker/FlutterRootJailbreakCheckerPlugin.kt

package com.rehmanali.flutter_root_jailbreak_checker

import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.provider.Settings
// --- FINAL & CORRECT IMPORTS FOR YOUR DEPENDENCIES ---
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.IntegrityTokenRequest
import com.google.android.play.core.integrity.IntegrityTokenResponse
import com.google.android.play.core.integrity.PrepareIntegrityTokenRequest
import com.google.android.play.core.integrity.StandardIntegrityManager
import com.google.android.play.core.integrity.StandardIntegrityToken
import com.google.android.play.core.integrity.StandardIntegrityTokenProvider
import com.google.android.play.core.integrity.StandardIntegrityTokenRequest
// --- END OF IMPORTS ---
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
    // BEST PRACTICE: Ek dedicated coroutine scope banayen jo plugin ki lifecycle ke sath manage ho.
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
                result.error("NATIVE_ERROR", e.message ?: "Unknown native error", e.stackTraceToString())
            }
        }
    }

    private suspend fun handlePreparePlayIntegrity(call: MethodCall, result: Result) {
        val cloudProjectNumber = call.argument<String>("cloudProjectNumber")?.toLongOrNull()
            ?: return result.error("MISSING_ARG", "Cloud project number is required.", null)

        val standardIntegrityManager: StandardIntegrityManager = IntegrityManagerFactory.createStandard(context)

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
                ?: return result.error("PROVIDER_NOT_READY", "StandardIntegrityTokenProvider not prepared. Call preparePlayIntegrity() first.", null)

            val tokenResponse: StandardIntegrityToken = provider.request(
                StandardIntegrityTokenRequest.builder().setRequestHash(requestHash).build()
            ).await()
            token = tokenResponse.token()
        } else if (nonce != null) {
            if (cloudProjectNumber == null) return result.error("MISSING_ARG", "Cloud project number is required for classic requests.", null)
            val integrityManager = IntegrityManagerFactory.create(context)
            val tokenResponse: IntegrityTokenResponse = integrityManager.requestIntegrityToken(
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

    // BEST PRACTICE: Blocking I/O operations (file checks) ko IO Dispatcher par chalayen.
    private suspend fun performOfflineChecks(): HashMap<String, Any> = withContext(Dispatchers.IO) {
        val results = HashMap<String, Any>()
        results["isRooted"] = isDeviceRooted()
        results["isDeveloperModeEnabled"] = isDeveloperModeEnabled() // Yeh non-blocking hai, lekin yahan rakhna theek hai.
        results["isEmulator"] = isEmulator()
        results["hasPotentiallyDangerousApps"] = hasPotentiallyDangerousApps()
        // iOS specific keys
        results["isJailbroken"] = false
        results["isRealDevice"] = true
        return@withContext results
    }

    // --- Aapka Original Offline Check Code ---
    private fun isDeveloperModeEnabled(): Boolean = Settings.Secure.getInt(context.contentResolver, "development_settings_enabled", 0) != 0
    private fun isEmulator(): Boolean = (android.os.Build.FINGERPRINT.startsWith("generic") || android.os.Build.FINGERPRINT.startsWith("unknown") || android.os.Build.MODEL.contains("google_sdk") || android.os.Build.MODEL.contains("Emulator") || android.os.Build.MODEL.contains("Android SDK built for x86") || android.os.Build.MANUFACTURER.contains("Genymotion") || (android.os.Build.BRAND.startsWith("generic") && android.os.Build.DEVICE.startsWith("generic")) || "google_sdk" == android.os.Build.PRODUCT)
    private fun hasPotentiallyDangerousApps(): Boolean { /* ... Aapka purana code yahan aayega ... */ return false }
    private fun isDeviceRooted(): Boolean = checkRootMethod1() || checkRootMethod2() || checkRootMethod3() || checkRootMethod4() || checkRootMethod5()
    private fun checkRootMethod1(): Boolean = android.os.Build.TAGS?.contains("test-keys") ?: false
    private fun checkRootMethod2(): Boolean { /* ... Aapka purana code yahan aayega ... */ return false }
    private fun checkRootMethod3(): Boolean { /* ... Aapka purana code yahan aayega ... */ return false }
    private fun checkRootMethod4(): Boolean { /* ... Aapka purana code yahan aayega ... */ return false }
    private fun checkRootMethod5(): Boolean { /* ... Aapka purana code yahan aayega ... */ return false }

    // --- Lifecycle Methods ---
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        // BEST PRACTICE: Scope ko cancel karain takay memory leaks na hon.
        coroutineScope.cancel()
    }
    override fun onAttachedToActivity(binding: ActivityPluginBinding) { activity = binding.activity }
    override fun onDetachedFromActivity() { activity = null }
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) { activity = binding.activity }
    override fun onDetachedFromActivityForConfigChanges() { activity = null }
}
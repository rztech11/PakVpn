package com.example.pakvpnn

import android.content.Intent
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "pakvpn/openvpn"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {

                    "isOpenVpnInstalled" -> {
                        result.success(isPackageInstalled("de.blinkt.openvpn"))
                    }

                    "connect" -> {
                        val profileName = call.argument<String>("profileName") ?: ""
                        try {
                            val intent = Intent(Intent.ACTION_MAIN)
                            intent.setClassName(
                                "de.blinkt.openvpn",
                                "de.blinkt.openvpn.api.ConnectVPN"
                            )
                            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            intent.putExtra("de.blinkt.openvpn.api.profileName", profileName)
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("CONNECT_FAILED", e.message, null)
                        }
                    }

                    "disconnect" -> {
                        try {
                            val intent = Intent(Intent.ACTION_MAIN)
                            intent.setClassName(
                                "de.blinkt.openvpn",
                                "de.blinkt.openvpn.api.DisconnectVPN"
                            )
                            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("DISCONNECT_FAILED", e.message, null)
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun isPackageInstalled(packageName: String): Boolean {
        return try {
            packageManager.getApplicationInfo(packageName, 0)
            true
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }
}

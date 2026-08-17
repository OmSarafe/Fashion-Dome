package com.omsarafe.fashiondome

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "fashion_dome/app_config"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getMapsApiKey" -> result.success(BuildConfig.MAPS_API_KEY)
                else -> result.notImplemented()
            }
        }
    }
}

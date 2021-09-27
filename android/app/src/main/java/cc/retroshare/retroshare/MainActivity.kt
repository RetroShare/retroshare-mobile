package cc.retroshare.retroshare

import android.annotation.TargetApi
import android.app.Activity
import android.content.Context
import android.content.Intent

import android.os.Build
// From that sample application
import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
//import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant


import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar



class MainActivity : FlutterActivity() {
    private val CHANNEL_NAME = "cc.retroshare.retroshare/retroshare"

  
   override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

       MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME).setMethodCallHandler { call, result ->
        // Note: this method is invoked on the main thread.
        handleMethodCall(call, result)
      }
    }

    override fun onDestroy() {
        super.onDestroy()

        stopService()
    }

    private fun handleMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "start" -> {
                startService()
                result.success(true)
            }
            "stop" -> {
                stopService()
                result.success(true)
            }
            "restart" -> {
                restartService()
                result.success(true)
            }
            "isRunning" -> {
                val running = RetroShareServiceAndroid.isRunning(this.getApplicationContext())
                result.success(running)
            }
            else -> result.notImplemented()
        }
    }

    @TargetApi(Build.VERSION_CODES.DONUT)
    private fun startService() {
        val intent = Intent()
        intent.setAction("cc.retroshare.retroshare.start")
        intent.setPackage("cc.retroshare.retroshare")
        sendBroadcast(intent)
    }

    @TargetApi(Build.VERSION_CODES.DONUT)
    private fun stopService() {
        val intent = Intent()
        intent.setAction("cc.retroshare.retroshare.stop")
        intent.setPackage("cc.retroshare.retroshare")
        sendBroadcast(intent)
    }

    @TargetApi(Build.VERSION_CODES.DONUT)
    private fun restartService() {
        val intent = Intent()
        intent.setAction("cc.retroshare.retroshare.restart")
        intent.setPackage("cc.retroshare.retroshare")
        sendBroadcast(intent)
    }
}
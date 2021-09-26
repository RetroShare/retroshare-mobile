package cc.retroshare.retroshare

import android.annotation.TargetApi
import android.os.Bundle
import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant

// From that sample application

import android.content.Intent
import android.os.Build
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


class MainActivity : FlutterActivity() {
    private val CHANNEL_NAME = "cc.retroshare.retroshare/retroshare"

    override fun onCreate(savedInstanceState: Bundle?) {
      super.onCreate(savedInstanceState)

     // GeneratedPluginRegistrant.registerWith(this)
      MethodChannel(flutterView, CHANNEL_NAME).setMethodCallHandler { call, result ->
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
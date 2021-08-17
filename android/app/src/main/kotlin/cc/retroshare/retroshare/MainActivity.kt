

package cc.retroshare.retroshare

//import android.annotation.TargetApi
//import android.os.Bundle
//
//import android.content.Intent
//import android.os.Build
//import io.flutter.plugin.common.MethodCall
//
//import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
//import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant


import android.annotation.TargetApi
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.annotation.NonNull;
import androidx.core.app.NotificationCompat

//import io.flutter.embedding.engine.plugins.FlutterPlugin
//import io.flutter.embedding.engine.plugins.activity.ActivityAware
//import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar


//class MainActivity : FlutterActivity() {
class MainActivity :  FlutterActivity() {
    // Add for foreground project
    private var methodChannel : MethodChannel? = null
    private var permissionHandler: PermissionHandler? = null

    companion object {
        @JvmStatic
        var notificationTitle: String? = "flutter_background foreground service"
        @JvmStatic
        var notificationText: String? = "Keeps the flutter app running in the background"
        @JvmStatic
        var notificationImportance: Int? = NotificationCompat.PRIORITY_DEFAULT

        @JvmStatic
        var notificationIconName: String? = "ic_notification_outerborder"
        @JvmStatic
        var notificationIconDefType: String? = "drawable"
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        permissionHandler = PermissionHandler(
                activity.applicationContext
        )

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, RetroShareServiceAndroid.CHANNEL_ID).setMethodCallHandler { call, result ->
//            System.out.println(call.method)
            when (call.method) {
                "getPlatformVersion" -> {
                    result.success("Android ${android.os.Build.VERSION.RELEASE}")
                }
                "hasPermissions" -> {
                    var hasPermissions = permissionHandler!!.isIgnoringBatteryOptimizations()
                            && permissionHandler!!.isWakeLockPermissionGranted()
                    result.success(hasPermissions)
                }
                "initialize" -> {
                    val title = call.argument<String>("android.notificationTitle")
                    val text = call.argument<String>("android.notificationText")
                    val importance = call.argument<Int>("android.notificationImportance")
                    val iconName = call.argument<String>("android.notificationIconName")
                    val iconDefType = call.argument<String>("android.notificationIconDefType")

                    // Set static values so the RetroShareServiceAndroid can use them later on to configure the notification
                    notificationImportance = importance ?: notificationImportance
                    notificationTitle = title ?: notificationTitle
                    notificationText = text ?: text
                    notificationIconName = iconName ?: notificationIconName
                    notificationIconDefType = iconDefType ?: notificationIconDefType

                    // Ensure wake lock permissions are granted
                    if (!permissionHandler!!.isWakeLockPermissionGranted()) {
                        result.error("PermissionError", "Please add the WAKE_LOCK permission to the AndroidManifest.xml in order to use background_sockets.", "")
                    }
                    // Ensure ignoring battery optimizations is enabled
                    if (!permissionHandler!!.isIgnoringBatteryOptimizations()) {
                        if (activity != null) {
                            permissionHandler!!.requestBatteryOptimizationsOff(result, activity!!)
                        } else {
                            result.error("NoActivityError", "The plugin is not attached to an activity", "The plugin is not attached to an activity. This is required in order to request battery optimization to be off.")
                        }
                    }
                    result.success(true)
                }
                "enableBackgroundExecution" -> {
                    // Ensure all the necessary permissions are granted
                    if (!permissionHandler!!.isWakeLockPermissionGranted()) {
                        result.error("PermissionError", "Please add the WAKE_LOCK permission to the AndroidManifest.xml in order to use background_sockets.", "")

                    } else if (!permissionHandler!!.isIgnoringBatteryOptimizations()) {
                        result.error("PermissionError", "The battery optimizations are not turned off.", "")
                    } else {
                        val intent = Intent(context, RetroShareServiceAndroid::class.java)

                        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                            context!!.startForegroundService(intent)
                        } else {
                            context!!.startService(intent)
                        }
                        result.success(true)
                    }
                }
                "disableBackgroundExecution" -> {
                    val intent = Intent(context!!, RetroShareServiceAndroid::class.java)
                    intent.action = RetroShareServiceAndroid.ACTION_SHUTDOWN
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                        context!!.startForegroundService(intent)
                    } else {
                        context!!.startService(intent)
                    }
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}


package cc.retroshare.retroshare

import android.annotation.SuppressLint
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent;
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager;
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import androidx.core.app.NotificationCompat
import android.util.Log
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.engine.FlutterEngine
import android.os.SystemClock
import android.app.AlarmManager

import org.qtproject.qt5.android.bindings.QtService

class RetroShareServiceAndroid : QtService() {

    companion object {
        @JvmStatic
        val ACTION_SHUTDOWN = "SHUTDOWN"
        @JvmStatic
        val ACTION_START = "START"
        @JvmStatic
        val WAKELOCK_TAG = "RetroShareServiceAndroid:Wakelock"
        @JvmStatic
        val CHANNEL_ID = "cc.retroshare.retroshare/retroshare"
        @JvmStatic
        private val TAG = "RetroShareServiceAndroid"
        @JvmStatic
        val EXTRA_NOTIFICATION_IMPORTANCE = " cc.retroshare.retroshare:Importance"
        @JvmStatic
        val EXTRA_NOTIFICATION_TITLE = " cc.retroshare.retroshare:Title"
        @JvmStatic
        val EXTRA_NOTIFICATION_TEXT = " cc.retroshare.retroshare:Text"
    }

    override fun onBind(intent: Intent) : IBinder? {
        return null;
    }

    @SuppressLint("WakelockTimeout")
    override public fun onCreate() {
        val pm = getApplicationContext().getPackageManager()
        val notificationIntent  =
                pm.getLaunchIntentForPackage(getApplicationContext().getPackageName())
        val pendingIntent  = PendingIntent.getActivity(
                this, 0,
                notificationIntent, 0
        )
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                    CHANNEL_ID,
                    MainActivity.notificationTitle,
                    MainActivity.notificationImportance ?: NotificationCompat.PRIORITY_DEFAULT).apply {
                description = MainActivity.notificationText
            }
            // Register the channel with the system
            val notificationManager: NotificationManager =
                    getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }

        val imageId = resources.getIdentifier(MainActivity.notificationIconName, MainActivity.notificationIconDefType, packageName)
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
                // todo(kon) : this don't work if you try to use custom strings
//                .setContentTitle(MainActivity.notificationTitle)
//                .setContentText(MainActivity.notificationText)
                .setContentTitle("retroshare mobile")
                .setContentText("This notification keeps retroshare mobile alive")
                .setSmallIcon(imageId)
                .setContentIntent(pendingIntent)
                .setPriority(MainActivity.notificationImportance ?: NotificationCompat.PRIORITY_DEFAULT)
                .build()

        (getSystemService(Context.POWER_SERVICE) as PowerManager).run {
            newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, WAKELOCK_TAG).apply {
                setReferenceCounted(false)
                acquire()
            }
        }
        startForeground(1, notification)
        super.onCreate()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int) : Int {
        if (intent?.action == ACTION_SHUTDOWN) {
            (getSystemService(Context.POWER_SERVICE) as PowerManager).run {
                newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, WAKELOCK_TAG).apply {
                    if (isHeld) {
                        release()
                    }
                }
            }
            stopForeground(true)
            stopSelf()
        }
        return START_STICKY;
    }

    // Code below is to prevent remove the task from recent apps
    override fun onTaskRemoved(rootIntent: Intent) {
        val restartServiceIntent = Intent(applicationContext, RetroShareServiceAndroid::class.java).also {
            it.setPackage(packageName)
        };
        val restartServicePendingIntent: PendingIntent = PendingIntent.getService(this, 1, restartServiceIntent, PendingIntent.FLAG_ONE_SHOT);
        applicationContext.getSystemService(Context.ALARM_SERVICE);
        val alarmService: AlarmManager = applicationContext.getSystemService(Context.ALARM_SERVICE) as AlarmManager;
        alarmService.set(AlarmManager.ELAPSED_REALTIME, SystemClock.elapsedRealtime() + 1000, restartServicePendingIntent);
    }
}

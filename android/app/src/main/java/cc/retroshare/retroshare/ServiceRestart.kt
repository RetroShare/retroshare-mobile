package cc.retroshare.retroshare

import android.app.ActivityManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class ServiceRestart : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        Log.i("ServiceRestart", "onReceive() Restarting Service")
        RetroShareServiceAndroid.stop(context)
        RetroShareServiceAndroid.start(context)
    }
}
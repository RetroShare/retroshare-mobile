package cc.retroshare.retroshare

import android.app.ActivityManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class ServiceStart : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        Log.i("ServiceStart", "onReceive() Starting Service")
        RetroShareServiceAndroid.start(context)
    }
}

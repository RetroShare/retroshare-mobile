
package cc.retroshare.retroshare

import android.app.ActivityManager
import android.content.Context
import android.content.Intent

import org.qtproject.qt5.android.bindings.QtService

class RetroShareServiceAndroid : QtService() {
    companion object {
        fun start(ctx: Context) {
            ctx.startService(Intent(ctx, RetroShareServiceAndroid::class.java))
        }

        fun stop(ctx: Context) {
            ctx.stopService(Intent(ctx, RetroShareServiceAndroid::class.java))
        }

        fun isRunning(ctx: Context): Boolean {
            val manager = ctx.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            for (service in manager.getRunningServices(Integer.MAX_VALUE))
                if (RetroShareServiceAndroid::class.java!!.getName().equals(service.service.getClassName()))
                    return true
            return false
        }
    }
}
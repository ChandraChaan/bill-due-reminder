package dev.chandra.bill_due_reminder

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.provider.Telephony
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

/** The `dev.chandra.bill_due_reminder/sms` channel used by PlatformSmsSource. */
class SmsBridge(private val context: Context, messenger: BinaryMessenger) :
    MethodChannel.MethodCallHandler {

    private val channel = MethodChannel(messenger, CHANNEL).also { it.setMethodCallHandler(this) }
    private val main = Handler(Looper.getMainLooper())
    private var pendingRequest: MethodChannel.Result? = null

    /** Set while an activity is attached; needed to show the permission dialog. */
    var activity: Activity? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "access" -> result.success(accessState())
            "requestAccess" -> requestAccess(result)
            "readInbox" -> {
                val since = call.argument<Number>("since")?.toLong() ?: 0L
                io.execute {
                    val messages = runCatching { readInbox(since) }
                    main.post {
                        messages.fold(
                            { result.success(it) },
                            { result.error("read_failed", it.message, null) },
                        )
                    }
                }
            }
            "takeArrived" -> result.success(ArrivedStore.take(context))
            "openSettings" -> {
                val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                    .setData(Uri.fromParts("package", context.packageName, null))
                    .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                context.startActivity(intent)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    /** Tells Dart in the open app that a bill SMS is waiting in [ArrivedStore]. */
    fun notifyArrived() = main.post { channel.invokeMethod("arrived", null) }

    private fun granted(): Boolean = PERMISSIONS.all {
        context.checkSelfPermission(it) == PackageManager.PERMISSION_GRANTED
    }

    private fun accessState(): String {
        if (granted()) return "granted"
        val act = activity ?: return "denied"
        val asked = prefs().getBoolean(KEY_ASKED, false)
        // After a "don't ask again", Android stops showing the rationale.
        val blocked = asked && !act.shouldShowRequestPermissionRationale(Manifest.permission.READ_SMS)
        return if (blocked) "blocked" else "denied"
    }

    private fun requestAccess(result: MethodChannel.Result) {
        val act = activity
        if (granted() || act == null || pendingRequest != null) {
            result.success(accessState())
            return
        }
        pendingRequest = result
        prefs().edit().putBoolean(KEY_ASKED, true).apply()
        act.requestPermissions(PERMISSIONS, REQUEST_CODE)
    }

    fun onPermissionResult(requestCode: Int) {
        if (requestCode != REQUEST_CODE) return
        pendingRequest?.success(accessState())
        pendingRequest = null
    }

    /** Business SMS received after [since] (epoch ms), oldest first. */
    private fun readInbox(since: Long): List<Map<String, Any>> {
        if (!granted()) return emptyList()
        val out = ArrayList<Map<String, Any>>()
        context.contentResolver.query(
            Telephony.Sms.Inbox.CONTENT_URI,
            arrayOf(Telephony.Sms.ADDRESS, Telephony.Sms.BODY, Telephony.Sms.DATE),
            "${Telephony.Sms.DATE} > ?",
            arrayOf(since.toString()),
            "${Telephony.Sms.DATE} ASC",
        )?.use { cursor ->
            while (cursor.moveToNext() && out.size < MAX_INBOX) {
                val sender = cursor.getString(0)
                // The sender check comes first: other messages are skipped
                // without reading their body.
                if (!SenderFilter.isBusiness(sender)) continue
                val body = cursor.getString(1) ?: continue
                out += mapOf("sender" to sender, "body" to body, "receivedAt" to cursor.getLong(2))
            }
        }
        return out
    }

    private fun prefs() = context.getSharedPreferences("sms_bridge", Context.MODE_PRIVATE)

    companion object {
        const val CHANNEL = "dev.chandra.bill_due_reminder/sms"
        private const val REQUEST_CODE = 4417
        private const val KEY_ASKED = "asked"
        private const val MAX_INBOX = 5000
        private val PERMISSIONS = arrayOf(Manifest.permission.READ_SMS, Manifest.permission.RECEIVE_SMS)
        private val io = Executors.newSingleThreadExecutor()
    }
}

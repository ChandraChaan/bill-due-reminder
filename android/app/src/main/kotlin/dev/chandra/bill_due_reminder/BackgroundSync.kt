package dev.chandra.bill_due_reminder

import android.content.BroadcastReceiver
import android.content.Context
import android.os.Handler
import android.os.Looper
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

/**
 * Runs `smsBackgroundMain` in lib/main.dart in a headless Flutter engine, so a
 * bill SMS gets its reminders even when the app isn't open. The engine is
 * destroyed as soon as Dart reports back, or after [TIMEOUT_MS].
 */
object BackgroundSync {
    private const val CHANNEL = "dev.chandra.bill_due_reminder/background"
    private const val TIMEOUT_MS = 9_000L

    private val main = Handler(Looper.getMainLooper())
    private var engine: FlutterEngine? = null
    private val waiting = ArrayList<BroadcastReceiver.PendingResult>()

    fun start(context: Context, pending: BroadcastReceiver.PendingResult) {
        waiting += pending
        // A run in progress reads the whole queue, including this message.
        if (engine != null) return
        val app = context.applicationContext
        val loader = FlutterInjector.instance().flutterLoader()
        loader.startInitialization(app)
        loader.ensureInitializationCompleteAsync(app, null, main) {
            val e = FlutterEngine(app)
            engine = e
            SmsBridge(app, e.dartExecutor.binaryMessenger)
            MethodChannel(e.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
                result.success(null)
                if (call.method == "done") main.post { finish() }
            }
            e.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint(loader.findAppBundlePath(), "smsBackgroundMain"),
            )
            main.postDelayed({ finish() }, TIMEOUT_MS)
        }
    }

    private fun finish() {
        main.removeCallbacksAndMessages(null)
        engine?.destroy()
        engine = null
        waiting.forEach { it.finish() }
        waiting.clear()
    }
}

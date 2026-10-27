package dev.chandra.bill_due_reminder

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var bridge: SmsBridge? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        bridge = SmsBridge(applicationContext, flutterEngine.dartExecutor.binaryMessenger).also {
            it.activity = this
            liveBridge = it
        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        if (liveBridge === bridge) liveBridge = null
        bridge?.activity = null
        bridge = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    @Deprecated("Deprecated in Android; still the callback for requestPermissions")
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        bridge?.onPermissionResult(requestCode)
    }

    companion object {
        /** The open app's bridge, if any; the SMS receiver notifies it directly. */
        @Volatile
        var liveBridge: SmsBridge? = null
    }
}

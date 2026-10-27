package dev.chandra.bill_due_reminder

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony

/**
 * Receives every incoming SMS (Android has no per-sender filter), keeps only
 * business ones and hands them to Dart: to the open app if there is one,
 * otherwise to a short-lived background engine.
 */
class SmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION) return
        val parts = Telephony.Sms.Intents.getMessagesFromIntent(intent) ?: return
        // Long SMS arrive in several parts; join them per sender.
        val bySender = LinkedHashMap<String, StringBuilder>()
        for (part in parts) {
            val sender = part?.originatingAddress ?: continue
            if (!SenderFilter.isBusiness(sender)) continue
            bySender.getOrPut(sender) { StringBuilder() }.append(part.messageBody ?: "")
        }
        if (bySender.isEmpty()) return
        val now = System.currentTimeMillis()
        for ((sender, body) in bySender) ArrivedStore.add(context, sender, body.toString(), now)

        val live = MainActivity.liveBridge
        if (live != null) {
            live.notifyArrived()
        } else {
            BackgroundSync.start(context, goAsync())
        }
    }
}

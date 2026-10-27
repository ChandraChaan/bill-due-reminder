package dev.chandra.bill_due_reminder

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

/**
 * A short queue of business SMS that arrived but haven't been read by Dart
 * yet. Each message is removed as soon as Dart takes it, and the queue is
 * capped, so bill SMS text never piles up here.
 */
object ArrivedStore {
    private const val PREFS = "arrived_sms"
    private const val KEY = "queue"
    private const val MAX = 50

    @Synchronized
    fun add(context: Context, sender: String, body: String, receivedAt: Long) {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val queue = JSONArray(prefs.getString(KEY, "[]"))
        queue.put(JSONObject().put("sender", sender).put("body", body).put("receivedAt", receivedAt))
        while (queue.length() > MAX) queue.remove(0)
        prefs.edit().putString(KEY, queue.toString()).commit()
    }

    @Synchronized
    fun take(context: Context): List<Map<String, Any>> {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val queue = JSONArray(prefs.getString(KEY, "[]"))
        prefs.edit().remove(KEY).commit()
        return (0 until queue.length()).map {
            val o = queue.getJSONObject(it)
            mapOf(
                "sender" to o.getString("sender"),
                "body" to o.getString("body"),
                "receivedAt" to o.getLong("receivedAt"),
            )
        }
    }
}

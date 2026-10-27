package dev.chandra.bill_due_reminder

/**
 * The privacy gate: only SMS from Indian business headers (`VM-HDFCBK`,
 * `JD-AIRTEL-S`) reach Dart. Phone numbers, contact names and promotional
 * `-P` headers are dropped here without their text being looked at.
 *
 * Mirrors `businessSenderId` in packages/sms_bill_parser/lib/src/sender.dart.
 */
object SenderFilter {
    private val header = Regex("^[A-Z]{2}-[A-Z0-9]{3,9}(?:-([STGP]))?$", RegexOption.IGNORE_CASE)
    private val bare = Regex("^[A-Z][A-Z0-9]{5,8}$")

    fun isBusiness(sender: String?): Boolean {
        val s = sender?.trim() ?: return false
        header.matchEntire(s)?.let { return !it.groupValues[1].equals("P", ignoreCase = true) }
        return bare.matches(s)
    }
}

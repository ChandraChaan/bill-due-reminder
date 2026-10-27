package dev.chandra.bill_due_reminder

import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

/** Must agree with test/scan_test.dart in packages/sms_bill_parser. */
class SenderFilterTest {
    @Test
    fun acceptsBusinessHeaders() {
        listOf("VM-HDFCBK", "JD-AIRTEL-S", "AX-SBICRD-T", "vk-bescom", "HDFCBK").forEach {
            assertTrue(it, SenderFilter.isBusiness(it))
        }
    }

    @Test
    fun rejectsPeopleAndPromotions() {
        listOf("+919876543210", "9876543210", "Mom", "Rahul Sharma", "VM-HDFCBK-P", "", null).forEach {
            assertFalse(it.toString(), SenderFilter.isBusiness(it))
        }
    }
}

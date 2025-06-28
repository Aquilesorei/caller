package com.example.caller

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Intent
import android.util.Log
import android.view.accessibility.AccessibilityEvent



class USSDAccessibilityService : AccessibilityService() {

    private var TAG = "XXXX"
    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        val className = event.className?.toString()
        val text = event.text.joinToString(separator = " ") { it.toString() }

        Log.d(TAG, "onAccessibilityEvent")
        Log.d(TAG, "Class Name: $className")
        Log.d(TAG, "Text: $text")

        if (className?.contains("Dialog") == true && className?.contains("Activity") == false  && className?.contains("Progress") == false) {
//            performGlobalAction(GLOBAL_ACTION_BACK)
            Log.d(TAG, "Dialog Text: $text")
            sendUSSDRefreshBroadcast(text)
        }
    }

    private fun sendUSSDRefreshBroadcast(message: String?) {
        val intent = Intent("com.times.ussd.action.REFRESH")
        intent.putExtra("message", message)
        sendBroadcast(intent)
    }


    override fun onInterrupt() {}

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d(TAG, "onServiceConnected")
        val info = AccessibilityServiceInfo()
        info.flags = AccessibilityServiceInfo.DEFAULT
        info.packageNames = arrayOf("com.android.phone")
        info.eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
        info.feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
        serviceInfo = info
    }
    companion object{
        const val ACCESSIBILITY_INTENT = "accessibility_event"
    }
}

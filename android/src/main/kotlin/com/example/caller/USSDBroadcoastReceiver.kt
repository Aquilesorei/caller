package com.example.caller

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import io.flutter.plugin.common.EventChannel
import android.util.Log

class USSDBroadcastReceiver(private val eventSink: EventChannel.EventSink?) : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent) {
        // Check if the intent contains the "message" extra
        if (intent.hasExtra("message")) {
            val msg = intent.getStringExtra("message")
            // Check if eventSink is not null before sending data
            eventSink?.success(msg)
        } else {
            // Handle the case where "message" extra is missing, e.g., log an error
            Log.e("USSDBroadcastReceiver", "Intent does not contain 'message' extra")
        }
    }
}

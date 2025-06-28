package com.example.caller

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import io.flutter.plugin.common.EventChannel
import android.util.Log

class USSDBroadcastReceiver(private val eventSink: EventChannel.EventSink?) : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent) {

        // Log the received intent
        Log.d("USSDBroadcastReceiver", "Received intent: $intent")

        // Check if the intent contains the "message" extra
        if (intent.hasExtra("message")) {
            val msg = intent.getStringExtra("message")
            // Check if eventSink is not null before sending data
            Log.d("USSDBroadcastReceiver", "Sending message: $msg")
            if(eventSink != null){
                eventSink.success(msg)
                Log.d("USSDBroadcastReceiver", "Message sent: $msg")
            }
            else{
                Log.e("USSDBroadcastReceiver", "eventSink is null")
            }
        } else {
            // Handle the case where "message" extra is missing, e.g., log an error
            Log.e("USSDBroadcastReceiver", "Intent does not contain 'message' extra")
        }
    }
}

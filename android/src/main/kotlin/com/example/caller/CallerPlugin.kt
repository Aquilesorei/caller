package com.example.caller

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.provider.Settings
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener

/** CallerPlugin */
class CallerPlugin: FlutterPlugin, MethodCallHandler, ActivityResultListener,
    EventChannel.StreamHandler,ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity

    private val CHANNEL_TAG = "caller/accessibility_channel"
    private val EVENT_TAG = "caller/accessibility_event"

    private var accessibilityReceiver: USSDBroadcastReceiver? = null
    private var eventChannel: EventChannel? = null

    private var mActivity: Activity? = null

    private var pendingResult: Result? = null
    val REQUEST_CODE_FOR_ACCESSIBILITY = 167
  private lateinit var channel : MethodChannel

  private lateinit var context : Context;

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext;
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_TAG)
    channel.setMethodCallHandler(this)
      eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, EVENT_TAG)
      eventChannel!!.setStreamHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
      pendingResult = result
    if (call.method == "call") {
      val ssid = call.argument<String>("ussd") ?: ""
      launchUssdCode(context,ssid)
      result.success(null)
    } else if (call.method == "isAccessibilityPermissionEnabled") {
        result.success(isAccessibilitySettingsOn(context))
    } else if (call.method == "requestAccessibilityPermission") {
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        mActivity!!.startActivityForResult(intent, REQUEST_CODE_FOR_ACCESSIBILITY)
    }else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
      channel.setMethodCallHandler(null)
      eventChannel!!.setStreamHandler(null)
  }

    override fun onListen(arguments: Any?, events: EventSink?) {
        if (isAccessibilitySettingsOn(context)) {
            /// Set up receiver
            val intentFilter = IntentFilter()
            intentFilter.addAction("com.times.ussd.action.REFRESH")
            accessibilityReceiver = USSDBroadcastReceiver(events)

            context.registerReceiver(accessibilityReceiver, intentFilter)

            /// Set up listener intent
            val listenerIntent = Intent(
                context,
                USSDAccessibilityService::class.java
            )
            context.startService(listenerIntent)
            Log.i("AccessibilityPlugin", "Started the accessibility tracking service.")
        }
    }

    override fun onCancel(arguments: Any?) {
        context.unregisterReceiver(accessibilityReceiver)
        accessibilityReceiver = null
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == REQUEST_CODE_FOR_ACCESSIBILITY) {
            if (resultCode == Activity.RESULT_OK) {
                pendingResult?.success(true)
            } else if (resultCode == Activity.RESULT_CANCELED) {
                pendingResult?.success(isAccessibilitySettingsOn(context))
            } else {
                pendingResult?.success(false)
            }
            return true
        }
        return false
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.mActivity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        this.mActivity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        this.mActivity = null
    }
}

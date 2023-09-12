package com.example.caller

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.Settings
import android.text.TextUtils


const val USSD_REQUEST_CODE = 123

fun launchUssdCode(context: Context, ussdCode: String) {
    val ussdUri = Uri.fromParts("tel", ussdCode, null)
    val ussdIntent = Intent(Intent.ACTION_CALL, ussdUri)

    if (context is Activity) {
        context.startActivityForResult(ussdIntent, USSD_REQUEST_CODE)
    } else {
        ussdIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(ussdIntent)
    }
}


fun isAccessibilitySettingsOn(mContext: Context): Boolean {
    var accessibilityEnabled = 0
    val service = mContext.packageName + "/" + USSDAccessibilityService::class.java.canonicalName
    try {
        accessibilityEnabled = Settings.Secure.getInt(
            mContext.applicationContext.contentResolver,
            Settings.Secure.ACCESSIBILITY_ENABLED
        )
    } catch (e: Settings.SettingNotFoundException) {
    }
    val mStringColonSplitter = TextUtils.SimpleStringSplitter(':')
    if (accessibilityEnabled == 1) {
        val settingValue = Settings.Secure.getString(
            mContext.applicationContext.contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        )
        if (settingValue != null) {
            mStringColonSplitter.setString(settingValue)
            while (mStringColonSplitter.hasNext()) {
                val accessibilityService = mStringColonSplitter.next()
                if (accessibilityService.equals(service, ignoreCase = true)) {
                    return true
                }
            }
        }
    } else {
    }
    return false
}
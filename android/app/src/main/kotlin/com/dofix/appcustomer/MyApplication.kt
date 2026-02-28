package com.dofix.appcustomer

import android.app.Application
import com.appsflyer.AppsFlyerLib

class MyApplication : Application() {
  override fun onCreate() {
    super.onCreate()

    val appsFlyerDevKey = "QPsc9zfWKAjutYjJgPVLWi"

    // Initialize AppsFlyer
    AppsFlyerLib.getInstance().init(appsFlyerDevKey, null, this)

    // Start tracking
    AppsFlyerLib.getInstance().start(this)

    // Enable debug logs
    AppsFlyerLib.getInstance().setDebugLog(true)
  }
}
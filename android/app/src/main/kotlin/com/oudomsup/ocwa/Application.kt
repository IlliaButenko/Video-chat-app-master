package com.oudomsup.ocwa

import com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin
import `in`.jvapps.system_alert_window.SystemAlertWindowPlugin
import io.flutter.app.FlutterApplication
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback
import io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin
import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService
import io.flutter.plugins.firebase.storage.FlutterFirebaseStoragePlugin
import io.flutter.plugins.firebase.firestore.FlutterFirebaseFirestorePlugin
import io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin
import io.inway.ringtone.player.FlutterRingtonePlayerPlugin
import com.geekyants.launch_vpn.LaunchVpnPlugin
import io.flutter.view.FlutterMain

class Application : FlutterApplication(), PluginRegistrantCallback {

    override fun onCreate() {
        super.onCreate()
        FlutterFirebaseMessagingService.setPluginRegistrant(this);
        SystemAlertWindowPlugin.setPluginRegistrant(this);
        FlutterMain.startInitialization(this);
    }

    override fun registerWith(registry: PluginRegistry?) {
        FlutterFirebaseCorePlugin.registerWith(registry?.registrarFor("io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin"));
        if (!registry!!.hasPlugin("io.flutter.plugins.firebasemessaging")) {
            FirebaseMessagingPlugin.registerWith(registry!!.registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin"));
        }
        FlutterLocalNotificationsPlugin.registerWith(registry?.registrarFor("com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin"));
        FlutterFirebaseStoragePlugin.registerWith(registry?.registrarFor("io.flutter.plugins.firebase.storage.FlutterFirebaseStoragePlugin"));
        FlutterFirebaseFirestorePlugin.registerWith(registry?.registrarFor("io.flutter.plugins.firebase.firestore.FlutterFirebaseFirestorePlugin"));
        FlutterRingtonePlayerPlugin.registerWith(registry?.registrarFor("io.inway.ringtone.player.FlutterRingtonePlayerPlugin"));
        SystemAlertWindowPlugin.registerWith(registry.registrarFor("in.jvapps.system_alert_window"));
        LaunchVpnPlugin.registerWith(registry.registrarFor("com.geekyants.launch_vpn.LaunchVpnPlugin"));
    }

}
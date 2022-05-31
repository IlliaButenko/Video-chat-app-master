//package com.oudomsup.ocwa
//
//import android.app.Activity
//import android.app.KeyguardManager
//import android.app.NotificationManager
//import android.content.Context
//import android.content.Intent
//import android.content.SharedPreferences
//import android.media.Ringtone
//import android.media.RingtoneManager
//import android.os.Build.VERSION.SDK_INT
//import android.os.Build.VERSION_CODES
//import android.os.Bundle
//import android.os.Vibrator
//import android.util.Log
//import android.view.View
//import android.view.WindowManager.LayoutParams.FLAG_FULLSCREEN
//import android.view.WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
//import android.view.WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
//import android.view.WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
//import android.widget.TextView
//import com.google.android.gms.tasks.Continuation
//import com.google.android.gms.tasks.Task
//import com.google.firebase.firestore.DocumentReference
//import com.google.firebase.firestore.DocumentSnapshot
//import com.google.firebase.firestore.EventListener
//import com.google.firebase.firestore.FirebaseFirestore
//import com.google.firebase.firestore.FirebaseFirestoreException
//import com.google.firebase.functions.FirebaseFunctions
//import com.google.firebase.functions.HttpsCallableResult
//import io.flutter.Log
//import java.util.HashMap
//import kotlin.reflect.jvm.internal.impl.load.kotlin.JvmType.Object
//
//
//class IncomingCallActivity() : Activity() {
//    var callId: String? = null
//    var callUuid: String? = null
//    var callerHandle: String? = null
//    var notificationId = 0
//    var ringtone: Ringtone? = null
//    var application: Application? = null
//    @Override
//    protected fun onCreate(savedInstanceState: Bundle?) {
//        super.onCreate(savedInstanceState)
//        try {
//            Log.d("done", "Done, IncomingCallActivity, onCreate();")
//            application = getApplication() as Application?
//            val intent: Intent = getIntent()
//            callId = intent.getStringExtra("your.apps.id.CALL_ID")
//            callUuid = intent.getStringExtra("your.apps.id.CALL_UUID")
//            callerHandle = intent.getStringExtra("your.apps.id.CALLER_HANDLE")
//            notificationId = intent.getIntExtra("your.notification.callkeep.NOTIFICATION_ID", 0)
//            if (SDK_INT >= VERSION_CODES.O_MR1) {
//                setShowWhenLocked(true)
//                setTurnScreenOn(true)
//            } else {
//                getWindow().addFlags(FLAG_SHOW_WHEN_LOCKED or FLAG_TURN_SCREEN_ON)
//            }
//
//            // Note that this shouldn't be needed on O_MR1 and higher, but setTurnScreenOn doesn't
//            // seem to have any effect on our Samsung Galaxy A40.
//            getWindow().addFlags(FLAG_TURN_SCREEN_ON)
//            getWindow().addFlags(FLAG_KEEP_SCREEN_ON or FLAG_FULLSCREEN)
//            val action: String = intent.getStringExtra("your.notification.callkeep.ACTION")
//            when (action ?: "") {
//                "answer" -> onAnswer(null)
//                "decline" -> onDecline(null)
//                else -> setup()
//            }
//        } catch (e: Exception) {
//            Log.d("done", "Done, IncomingCallActivity, onCreate " + e.toString())
//        }
//    }
//
//    @Override
//    protected fun onStart() {
//        super.onStart()
//        startRinging()
//    }
//
//    @Override
//    protected fun onStop() {
//        super.onStop()
//        stopRinging()
//    }
//
//    @Override
//    fun onWindowFocusChanged(hasFocus: Boolean) {
//        super.onWindowFocusChanged(hasFocus)
//        if (hasFocus) {
//            hideSystemUI()
//        }
//    }
//
//    private fun hideSystemUI() {
//        try {
//            // Enables regular immersive mode.
//            // For "lean back" mode, remove SYSTEM_UI_FLAG_IMMERSIVE.
//            // Or for "sticky immersive," replace it with SYSTEM_UI_FLAG_IMMERSIVE_STICKY
//            Log.d("done", "done, IncomingCallActivity, hideSystemUI")
//            val decorView: View = getWindow().getDecorView()
//            decorView.setSystemUiVisibility(
//                    View.SYSTEM_UI_FLAG_IMMERSIVE // Set the content to appear under the system bars so that the
//                            // content doesn't resize when the system bars hide and show.
//                            or View.SYSTEM_UI_FLAG_LAYOUT_STABLE
//                            or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
//                            or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN // Hide the nav bar and status bar
//                            or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
//                            or View.SYSTEM_UI_FLAG_FULLSCREEN)
//        } catch (e: Exception) {
//            Log.e("done", "done, IncomingCallActivity, hidesystemui " + e.toString())
//        }
//    }
//
//    private fun setup() {
//        try {
//            Log.d("done", "done, IncomingCallActivity, setup")
//            setContentView(R.layout.activity_incoming_call)
//            val caller: TextView = findViewById(R.id.txt_caller) as TextView
//            caller.setText(callerHandle)
//            val db: FirebaseFirestore = FirebaseFirestore.getInstance()
//            val ref: DocumentReference = db.collection("yourCallsCollection").document(callId)
//            ref.addSnapshotListener(object : EventListener<DocumentSnapshot?>() {
//                @Override
//                fun onEvent(snapshot: DocumentSnapshot?, e: FirebaseFirestoreException?) {
//                    if (e != null) {
//                        Log.e(TAG, "Listen to call snapshots failed", e)
//                        return
//                    }
//                    if ((snapshot == null) || !snapshot.exists() || snapshot.contains("answer")) {
//                        dismissNotification()
//                        finish()
//                    }
//                }
//            })
//        } catch (e: Exception) {
//            Log.e("done", "done, IncomingCallActivity, setup " + e.toString())
//        }
//    }
//
//    private fun startRinging() {
//        try {
//            Log.d("done", "done, IncomingCallActivity, setup ")
//            val toneUri: android.net.Uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
//            ringtone = RingtoneManager.getRingtone(getApplicationContext(), toneUri)
//            ringtone.play()
//            val v: Vibrator = getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
//            v.vibrate(DEFAULT_VIBRATE_PATTERN, 0)
//        } catch (e: Exception) {
//            e.printStackTrace()
//        }
//    }
//
//    private fun stopRinging() {
//        try {
//            Log.d("done", "done, IncomingCallActivity, stopRinging ")
//            if (ringtone != null) {
//                ringtone.stop()
//            }
//            val v: Vibrator = getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
//            v.cancel()
//        } catch (e: Exception) {
//            Log.e("done", "done, IncomingCallActivity, stop ringing " + e.toString())
//        }
//    }
//
//    private fun dismissNotification() {
//        try {
//            Log.d("done", "done, IncomingCallActivity, dismissNotification ")
//            val notificationManager: NotificationManager = getApplicationContext().getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
//            notificationManager.cancel(notificationId)
//        } catch (e: Exception) {
//            Log.e("done", "done, IncomingCallActivity, dismissNotification " + e.toString())
//        }
//    }
//
//    private fun launchMainActivity() {
//        try {
//            Log.d("done", "done, IncomingCallActivity, dismissNotification ")
//            val preferences: SharedPreferences = getApplicationContext().getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
//            preferences.edit().putBoolean("flutter.$callUuid:answer", true).commit()
//            Log.d("Done", "SharedPreferences committed")
//            val packageName: String = getApplicationContext().getPackageName()
//            val launchIntent: Intent = getApplicationContext().getPackageManager().getLaunchIntentForPackage(packageName).cloneFilter()
//            launchIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
//            Log.d("Done", "Starting activity")
//            getApplicationContext().startActivity(launchIntent)
//            Log.d("Done", "Activity started")
//        } catch (e: Exception) {
//            Log.e("done", "done, IncomingCallActivity, launchMainActivity " + e.toString())
//        }
//    }
//
//    fun onAnswer(view: View?) {
//        try {
//            Log.d("Done", "done, IncomingCallActivity, onAnswer started")
//            dismissNotification()
//
//            //1) check if MainActivity already present in stack
//            //* if the app is already running it means we've answered trough notification
//            if (application.isAppRunning()) {
//                val call = CallAnsweredTroughNotification(callId, callUuid, callerHandle, notificationId)
//                application.setCallAnsweredTroughNotification(call)
//                Log.d("done", "IncomingCallActivity about to finish with call")
//                finish()
//                return
//            }
//            val manager: KeyguardManager = getSystemService(KEYGUARD_SERVICE) as KeyguardManager
//            if (!manager.isKeyguardLocked()) {
//                Log.d("Done", "Keyguard not locked, launch main activity")
//                launchMainActivity()
//                return
//            }
//            if (SDK_INT >= VERSION_CODES.O) {
//                manager.requestDismissKeyguard(this, object : KeyguardDismissCallback() {
//                    @Override
//                    fun onDismissSucceeded() {
//                        super.onDismissSucceeded()
//                        launchMainActivity()
//                    }
//
//                    @Override
//                    fun onDismissError() {
//                        launchMainActivity()
//                        super.onDismissError()
//                    }
//
//                    @Override
//                    fun onDismissCancelled() {
//                        launchMainActivity()
//                        super.onDismissCancelled()
//                    }
//                })
//            } else {
//                // Just launch the activity and rely on it setting FLAG_DISMISS_KEYGUARD to trigger keyguard unlock
//                launchMainActivity()
//            }
//        } catch (e: Exception) {
//            Log.e("done", "done, IncomingCallActivity, onAnswer " + e.toString())
//        }
//    }
//
//    fun onDecline(view: View?) {
//        endCallOnFirebase()
//        dismissNotification()
//        finish()
//    }
//
//    fun endCallOnFirebase() {
//        val functions: FirebaseFunctions = FirebaseFunctions.getInstance("europe-west1")
//        val data: HashMap<String, Object> = HashMap()
//        data.put("callId", callId)
//        //* backend logic, we call cloud functions to end call
//    }
//
//    companion object {
//        private val TAG = "IncomingCallActivity"
//        private val DEFAULT_VIBRATE_PATTERN = longArrayOf(0, 250, 250, 250)
//    }
//}

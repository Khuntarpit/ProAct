package com.zeriuxlabs.proact

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.*
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.view.View
import androidx.core.app.NotificationCompat
import org.json.JSONArray
import org.json.JSONObject
import java.util.*


class ForegroundService : Service() {
    override fun onBind(intent: Intent): IBinder? {
        throw UnsupportedOperationException("")
    }

    var timer: Timer = Timer()
    var isTimerStarted = false
    var timerReload: Long = 500
    var currentAppActivityList = arrayListOf<String>()
    private var mHomeWatcher = HomeWatcher(this)

    override fun onCreate() {
        super.onCreate()
        val channelId = "AppLock-10"
        val channel = NotificationChannel(
            channelId, "Channel human readable title", NotificationManager.IMPORTANCE_DEFAULT
        )
        (getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager).createNotificationChannel(
            channel
        )
        val notification =
            NotificationCompat.Builder(this, channelId).setContentTitle("").setContentText("")
                .build()
        startForeground(1, notification)
        startMyOwnForeground()

    }

    override fun onStartCommand(intent: Intent, flags: Int, startId: Int): Int {
        return super.onStartCommand(intent, flags, startId)
    }

    private fun startMyOwnForeground() {
        val window = Window(this)
        mHomeWatcher.setOnHomePressedListener(object : HomeWatcher.OnHomePressedListener {
            override fun onHomePressed() {
                println("onHomePressed")
                currentAppActivityList.clear()
                if (window.isOpen()) {
                    window.close()
                }
            }

            override fun onHomeLongPressed() {
                println("onHomeLongPressed")
                currentAppActivityList.clear()
                if (window.isOpen()) {
                    window.close()
                }
            }
        })
        mHomeWatcher.startWatch()
        timerRun(window)
    }

    override fun onDestroy() {
        timer.cancel()
        mHomeWatcher.stopWatch()
        super.onDestroy()
    }

    private fun timerRun(window: Window) {
        timer.scheduleAtFixedRate(object : TimerTask() {
            override fun run() {
                isTimerStarted = true
                isServiceRunning(window)
            }
        }, 0, timerReload)
    }


    fun isServiceRunning(window: Window) {

        val saveAppData: SharedPreferences =
            applicationContext.getSharedPreferences("save_app_data", Context.MODE_PRIVATE)
        val lockedAppList: List<*> =
            saveAppData.getString("app_data", "AppList")!!.replace("[", "").replace("]", "")
                .split(",")

        val mUsageStatsManager = getSystemService(USAGE_STATS_SERVICE) as UsageStatsManager
        val time = System.currentTimeMillis()

        val usageEvents = mUsageStatsManager.queryEvents(time - timerReload, time)
        val event = UsageEvents.Event()

        run breaking@{
            while (usageEvents.hasNextEvent()) {
                usageEvents.getNextEvent(event)
                for (element in lockedAppList) if (event.packageName.toString()
                        .trim() == element.toString().trim()
                ) {

                    val verifyAppLock = verifyAppLockEvent()
                    println("${event.className} $element ${event.eventType}-----------Event Type")
                    if (event.eventType == UsageEvents.Event.ACTIVITY_RESUMED && currentAppActivityList.isEmpty() && verifyAppLock) {

                        currentAppActivityList.add(event.className)
                        println("$currentAppActivityList-----List--added 1")
                        window.txtView!!.visibility = View.INVISIBLE
                        Handler(Looper.getMainLooper()).post {
                            window.open()
                        }
                        return@breaking
                    } else if (event.eventType == UsageEvents.Event.ACTIVITY_RESUMED) {
                        if (!currentAppActivityList.contains(event.className)) {
                            currentAppActivityList.add(event.className)
                            println("$currentAppActivityList-----List--added 2")
                        }
                    } else if (event.eventType == UsageEvents.Event.ACTIVITY_STOPPED) {
                        if (currentAppActivityList.contains(event.className)) {
                            currentAppActivityList.remove(event.className)
                            println("$currentAppActivityList-----List--remained 3")
                        }
                    }
                }
            }
        }
    }

    fun verifyAppLockEvent(): Boolean {
        var appplyLock = false;
        val sharedPrefs =
            getSharedPreferences("save_app_data", Context.MODE_PRIVATE)
        val eventDataStr: String? = sharedPrefs.getString("event_data", "[]")
        val eventDataArr: JSONArray = JSONArray(eventDataStr)

        val cal: Calendar = Calendar.getInstance()
        val currDay = cal.get(Calendar.DAY_OF_MONTH)
        val currMonth = cal.get(Calendar.MONTH)
        val currYear = cal.get(Calendar.YEAR)
        val currHour = cal.get(Calendar.HOUR_OF_DAY)
        val currMin = cal.get(Calendar.MINUTE)
        val currStartTime = (currHour * 100) + currMin

        println("${currDay} , ${currMonth}, ${currYear}, ${currHour}, ${currMin}")

        for (i in 0 until eventDataArr.length()) {
            val event: JSONObject = eventDataArr[i] as JSONObject;
            val eventTimeInMillis = event.getString("currenttimeinmillis");
            cal.timeInMillis = eventTimeInMillis.toLong()

            val eventDay = cal.get(Calendar.DAY_OF_MONTH)
            val eventMonth = cal.get(Calendar.MONTH)
            val eventYear = cal.get(Calendar.YEAR)
            val eventStartTime = event.getString("startTime").replace(":", "").toInt()
            val eventEndTime = event.getString("endTime").replace(":", "").toInt()
//            val eventSHour = startTime.get(0).toInt();
//            val eventSMin = startTime.get(1).toInt();
//            val eventEHour = endTime.get(0).toInt();
//            val eventEMin = endTime.get(1).toInt();

            println("${eventDay} , ${eventMonth}, ${eventYear}, ${eventStartTime}, ${eventEndTime}")

            if (currDay == eventDay && currMonth == eventMonth && currYear == eventYear) {
                println("Enter 1")
                if (eventStartTime <= currStartTime && currStartTime < eventEndTime) {
                    println("Enter 2")
                    appplyLock = true
                }
            }
        }

        println("applylock ${appplyLock}")

        return appplyLock
    }
}


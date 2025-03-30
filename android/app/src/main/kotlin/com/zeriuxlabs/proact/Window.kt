package com.zeriuxlabs.proact

import android.annotation.SuppressLint
import android.content.Context
import android.content.SharedPreferences
import android.graphics.PixelFormat
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.*
import android.widget.TextView
import androidx.appcompat.widget.AppCompatTextView
import androidx.core.content.ContextCompat
import com.zeriuxlabs.proact.R
import org.json.JSONArray
import org.json.JSONObject
import java.util.Calendar

//import com.andrognito.pinlockview.IndicatorDots
//import com.andrognito.pinlockview.PinLockListener
//import com.andrognito.pinlockview.PinLockView


@SuppressLint("InflateParams")
class Window(
		private val context: Context
) {
	private val mView: View
	var pinCode: String = ""
	var txtView: TextView? = null
	private var mParams: WindowManager.LayoutParams? = null
	private val mWindowManager: WindowManager
	private val layoutInflater: LayoutInflater

//	private var mPinLockView: PinLockView? = null
//	private var mIndicatorDots: IndicatorDots? = null
//	private val mPinLockListener: PinLockListener = object : PinLockListener {
//
//		@SuppressLint("LogConditional")
//		override fun onComplete(pin: String) {
//			Log.d(PinCodeActivity.TAG, "Pin complete: $pin")
//			pinCode = pin
//			doneButton()
//		}
//
//		override fun onEmpty() {
//			Log.d(PinCodeActivity.TAG, "Pin empty")
//		}
//
//		@SuppressLint("LogConditional")
//		override fun onPinChange(pinLength: Int, intermediatePin: String) {}
//	}

	fun open() {
		try {
			if (mView.windowToken == null) {
				if (mView.parent == null) {
					mWindowManager.addView(mView, mParams)
				}
			}
		} catch (e: Exception) {
			e.printStackTrace()
		}
	}

	fun isOpen():Boolean{
		return (mView.windowToken != null && mView.parent != null)
	}

	fun close() {
		try {
			Handler(Looper.getMainLooper()).postDelayed({
				(context.getSystemService(Context.WINDOW_SERVICE) as WindowManager).removeView(mView)
				mView.invalidate()
			},500)

		} catch (e: Exception) {
			e.printStackTrace()
		}
	}

	fun doneButton(){
		try {
//			mPinLockView!!.resetPinLockView()
			val saveAppData: SharedPreferences = context.getSharedPreferences("save_app_data", Context.MODE_PRIVATE)
			val dta: String = saveAppData.getString("password", "PASSWORD")!!
			if(pinCode == dta){
				println("$pinCode---------------pincode")
				close()
			}else{
				txtView!!.visibility = View.VISIBLE
			}
		} catch (e: Exception) {
			println("$e---------------doneButton")
		}
	}

	init {

		mParams = WindowManager.LayoutParams(
				WindowManager.LayoutParams.MATCH_PARENT,
				WindowManager.LayoutParams.MATCH_PARENT,
				WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
				WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
				PixelFormat.TRANSLUCENT
		)
		layoutInflater = context.getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater
		mView = layoutInflater.inflate(R.layout.pin_activity, null)

		mParams!!.gravity = Gravity.CENTER
		mWindowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager

//		mPinLockView = mView.findViewById(R.id.pin_lock_view)
//		mIndicatorDots = mView.findViewById(R.id.indicator_dots)
		txtView = mView.findViewById(R.id.alertError) as TextView
		val appLockMsgTV = mView.findViewById(R.id.app_lock_msg) as AppCompatTextView
		val appLockMsg = getAppLockEvent()
		appLockMsgTV.text = appLockMsg

//		mPinLockView!!.attachIndicatorDots(mIndicatorDots)
//		mPinLockView!!.setPinLockListener(mPinLockListener)
//		mPinLockView!!.pinLength = 6
//		mPinLockView!!.textColor = ContextCompat.getColor(context, R.color.ic_launcher_background)
//		mIndicatorDots!!.indicatorType = IndicatorDots.IndicatorType.FILL_WITH_ANIMATION

	}

	fun getAppLockEvent(): String {
		var appplyLockText = "";
		val sharedPrefs =
			context.getSharedPreferences("save_app_data", Context.MODE_PRIVATE)
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
			val eventName = event.getString("name");
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
					appplyLockText = "Please be informed that your task \"${eventName}\" is scheduled to commence at " +
							"${event.getString("startTime")} and conclude at ${event.getString("endTime")}."
					break
//					appplyLock = true
				}
			}
		}

		println("applylock ${appplyLockText}")

		return appplyLockText
	}

}
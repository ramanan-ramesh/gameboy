package com.rareapps.gameboy

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.animation.LinearInterpolator
import android.widget.ImageView
import android.widget.RelativeLayout
import android.widget.TextView

class MainActivity: Activity(){
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.splash_screen)

        val appLogoView = findViewById<ImageView>(R.id.app_logo)
        appLogoView.scaleX = 2f
        appLogoView.scaleY = 2f

        appLogoView.animate()
            .scaleX(1f)
            .scaleY(1f)
            .rotation(1080f)
            .setDuration(3000)
            .setInterpolator(LinearInterpolator())
            .withEndAction {
                val splashScreenRoot = findViewById<RelativeLayout>(R.id.splash_screen_root)
                splashScreenRoot.setBackgroundColor(0xFF53655A.toInt())
                val appDescription = findViewById<TextView>(R.id.app_description)
                var appDescriptionText = resources.getString(R.string.app_description)

                typeWriterEffect(appDescription, appDescriptionText, 100) {
                    startActivity(Intent(this, FlutterAppActivity::class.java))
                    finish()
                }
            }
            .start()
    }

    private fun typeWriterEffect(textView: TextView, fullText: String, delay: Long, onComplete: () -> Unit) {
        val handler = Handler(Looper.getMainLooper())
        var index = 0

        val runnable = object : Runnable {
            override fun run() {
                if (index <= fullText.length) {
                    textView.text = fullText.substring(0, index)
                    index++
                    handler.postDelayed(this, delay)
                } else {
                    onComplete()
                }
            }
        }
        handler.post(runnable)
    }
}

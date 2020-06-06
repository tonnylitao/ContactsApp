package com.tonnysunm.contacts

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.tonnysunm.contacts.ui.main.MainFragment
import timber.log.Timber

class MainActivity : AppCompatActivity(R.layout.main_activity) {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (BuildConfig.DEBUG) {
            Timber.plant(Timber.DebugTree())
        }

        if (savedInstanceState == null) {
            supportFragmentManager.beginTransaction()
                .replace(R.id.container, MainFragment.newInstance())
                .commitNow()
        }
    }
}

package com.tonnysunm.contacts.model

import android.content.Context

class Repository(private val application: Context) {

    val userDao by lazy { AppRoomDatabase.getDatabase(application).userDao() }

}


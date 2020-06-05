package com.tonnysunm.contacts.room

import android.content.Context

class DBRepository(private val application: Context) {

    val userDao by lazy { AppRoomDatabase.getDatabase(application).userDao() }

}


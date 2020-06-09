package com.tonnysunm.contacts.room

import android.content.Context

class DBRepository(private val application: Context) {
    val db by lazy { AppRoomDatabase.getDatabase(application) }

    val userDao by lazy { db.userDao() }
    
}


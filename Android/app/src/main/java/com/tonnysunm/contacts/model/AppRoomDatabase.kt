package com.tonnysunm.contacts.model

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import androidx.room.*
import androidx.sqlite.db.SupportSQLiteDatabase
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import timber.log.Timber
import java.lang.reflect.Type
import java.util.*

private val TAG = AppRoomDatabase::class.simpleName

@Database(
    entities = [User::class],
    version = 1
)
abstract class AppRoomDatabase : RoomDatabase() {

    abstract fun userDao(): UserDao

    //
    companion object {
        @Volatile
        private var INSTANCE: AppRoomDatabase? = null

        fun getDatabase(context: Context): AppRoomDatabase {
            val tempInstance = INSTANCE
            if (tempInstance != null) {
                return tempInstance
            }

            synchronized(this) {
                val instance = Room
                    .databaseBuilder(
                        context.applicationContext,
                        AppRoomDatabase::class.java,
                        "contacts_db"
                    )
                    .build()

                INSTANCE = instance

                return instance
            }
        }
    }
}
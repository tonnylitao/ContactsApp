package com.tonnysunm.contacts.model

import android.content.Context
import androidx.room.*

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
package com.tonnysunm.contacts.room

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase

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
//                    .addCallback(object : RoomDatabase.Callback() {
//                        override fun onCreate(db: SupportSQLiteDatabase) {
//                            val data =
//                                "(1,'Mr.','Tonny','L','male','https://www.avis.co.nz/content/dam/avis/oc/nz/common/offers/avis-nz-social-tag-2440x1600.jpg')"
//                            db.execSQL("INSERT INTO user_table (id, title, first_name, last_name, avatar, gender) VALUES $data;")
//
//                            super.onCreate(db)
//                        }
//                    })
                    .build()

                INSTANCE = instance

                return instance
            }
        }
    }
}
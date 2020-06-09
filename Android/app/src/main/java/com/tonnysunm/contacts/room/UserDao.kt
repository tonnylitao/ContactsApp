package com.tonnysunm.contacts.room

import androidx.room.Dao
import androidx.room.Query


@Dao
interface UserDao : BaseDao<User> {

    @Query("SELECT * FROM user_table ORDER BY id ASC LIMIT :limit OFFSET :offset")
    suspend fun allUsersById(offset: Int, limit: Int): List<User>

}

//TODO UIUser
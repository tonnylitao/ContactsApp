package com.tonnysunm.contacts.room

import androidx.paging.DataSource
import androidx.room.Dao
import androidx.room.Query


@Dao
interface UserDao : BaseDao<User> {

    @Query("SELECT * FROM user_table ORDER BY id ASC")
    fun allUsersById(): DataSource.Factory<Int, User>

}
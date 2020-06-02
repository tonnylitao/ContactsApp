package com.tonnysunm.contacts.model

import androidx.lifecycle.LiveData
import androidx.paging.DataSource
import androidx.room.Dao
import androidx.room.Query


@Dao
interface UserDao : BaseDao<User> {

    @Query("SELECT * FROM user_table")
    fun getPagingAll(): DataSource.Factory<Int, User>

}
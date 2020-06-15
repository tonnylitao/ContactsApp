package com.tonnysunm.contacts.room

import androidx.lifecycle.LiveData
import androidx.paging.DataSource
import androidx.room.Dao
import androidx.room.Query
import androidx.room.Transaction
import com.tonnysunm.contacts.ui.main.UserUIModel

@Dao
interface UserDao : BaseDao<User> {
    @Query("SELECT id, title, firstName, lastName, pictureThumbnail, nationality FROM user_table WHERE ('' = :nationality OR nationality = :nationality) AND '%%' != :target AND (firstName LIKE :target OR lastName LIKE :target) ORDER BY id ASC")
    fun searchUsers(target: String, nationality: String): DataSource.Factory<Int, UserInSearch>

    @Query("SELECT id, title, firstName, lastName, pictureThumbnail, nationality, gender FROM user_table ORDER BY id ASC LIMIT :limit OFFSET :offset")
    suspend fun queryUsers(offset: Int, limit: Int): List<UserUIModel>

    @Query("SELECT * FROM user_table WHERE id = :id")
    fun queryUser(id: Int): LiveData<User>

    @Query("SELECT id FROM user_table ORDER BY id ASC LIMIT 1 OFFSET :offset")
    suspend fun queryUserOffset(offset: Int): Int?

    @Query("DELETE from user_table")
    suspend fun deleteAll()

    @Query("DELETE from user_table WHERE id > :id")
    suspend fun deleteAllAfter(id: Int)

    @Transaction
    suspend fun upsert(entity: User) {
        if (insertIfNotExisted(entity) == -1L) {
            update(entity)
        }
    }

    @Transaction
    suspend fun upsert(entities: List<User>) {
        val rowIDs = insertIfNotExisted(entities)
        val toUpdate = rowIDs.mapIndexedNotNull { index, rowID ->
            if (rowID == -1L) entities[index] else null
        }
        toUpdate.forEach { update(it) }
    }

    @Transaction
    suspend fun deleteAllOffset(offset: Int) {
        queryUserOffset(offset)?.let {
            deleteAllAfter(it)
        }
    }
}

//TODO UIUser
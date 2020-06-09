package com.tonnysunm.contacts.room

import androidx.room.Dao
import androidx.room.Query
import androidx.room.Transaction


@Dao
interface UserDao : BaseDao<User> {

    @Query("SELECT * FROM user_table ORDER BY id ASC LIMIT :limit OFFSET :offset")
    suspend fun queryUsers(offset: Int, limit: Int): List<User>

    @Query("SELECT * FROM user_table WHERE id = :id")
    suspend fun queryUser(id: Int): User?

    @Query("SELECT id FROM user_table ORDER BY id ASC LIMIT 1 OFFSET :offset")
    suspend fun queryUserOffset(offset: Int): Int?

    @Query("DELETE from user_table")
    suspend fun deleteAll()

    @Query("DELETE from user_table WHERE id > :id")
    suspend fun deleteAllAfter(id: Int)

    @Transaction
    suspend fun upsert(entity: User) {
        val id = insert(entity)

        if (id == -1L) {
            update(entity)
        }
    }

    @Transaction
    suspend fun upsert(entities: List<User>) {
        val rowIDs = insert(entities)
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
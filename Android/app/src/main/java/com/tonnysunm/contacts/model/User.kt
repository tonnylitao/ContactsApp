package com.tonnysunm.contacts.model

import androidx.room.*

@Entity(
    tableName = "user_table"
)
data class User(
    @PrimaryKey(autoGenerate = true)
    var id: Int = 0,

    @ColumnInfo(name="first_name")
    var firstName: String,

    @ColumnInfo(name="last_name")
    var lastName: String,

    var title: String,

    var avatar: String


)
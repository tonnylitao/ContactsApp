package com.tonnysunm.contacts.model

import androidx.room.*
import com.tonnysunm.contacts.library.IDEquable

@Entity(
    tableName = "user_table"
)
data class User(
    @PrimaryKey(autoGenerate = true)
    override var id: Int = 0,

    @ColumnInfo(name = "first_name")
    var firstName: String,

    @ColumnInfo(name = "last_name")
    var lastName: String,

    var title: String,

    var avatar: String
) : IDEquable {

    @Ignore
    val fullName = "$title $firstName $lastName"

}
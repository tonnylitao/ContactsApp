package com.tonnysunm.contacts.room

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.Ignore
import androidx.room.PrimaryKey
import com.tonnysunm.contacts.BR
import com.tonnysunm.contacts.R
import com.tonnysunm.contacts.library.RecyclerItem

@Entity(
    tableName = "user_table"
)
data class User(
    @PrimaryKey(autoGenerate = true)
    var id: Int = 0,

    @ColumnInfo(name = "first_name")
    var firstName: String,

    @ColumnInfo(name = "last_name")
    var lastName: String,

    var title: String,

    var avatar: String
) : RecyclerItem {

    @Ignore
    val fullName = "$title $firstName $lastName"

    override val layoutId: Int
        get() = R.layout.list_item_user

    override val variableId: Int
        get() = BR.user

    override val uniqueId: Int
        get() = id
}
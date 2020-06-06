package com.tonnysunm.contacts.room

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
    @PrimaryKey
    var id: Int = 0,

    var title: String?,

    var firstName: String?,

    var lastName: String?,

    var dayOfBirth: String?,

    var gender: String?,

    var email: String?,

    var phone: String?,

    var cell: String?,

    var address: String?,

    var nationality: String?,

    var pictureThumbnail: String?,

    var pictureLarge: String?
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
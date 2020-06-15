package com.tonnysunm.contacts.room

import android.graphics.Color
import android.text.Spannable
import android.text.SpannableString
import android.text.style.ForegroundColorSpan
import android.text.style.RelativeSizeSpan
import androidx.room.Embedded
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
) {
    @Ignore
    val fullName =
        SpannableString("$title. $firstName $lastName").apply {
            val length = title?.length ?: return@apply

            setSpan(RelativeSizeSpan(0.8f), 0, length + 1, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)
            setSpan(
                ForegroundColorSpan(Color.GRAY),
                0,
                length + 1,
                Spannable.SPAN_EXCLUSIVE_EXCLUSIVE
            )
        }
}

/**
 * UI model of user in home recycler view
 */
data class UserInHome(
    @Embedded val user: User
) : RecyclerItem {
    override val layoutId: Int
        get() = R.layout.list_item_user

    override val variableId: Int
        get() = BR.user

    override val dataToBind: Any
        get() = user

    override val uniqueId: Int
        get() = user.id
}

/**
 * UI model of user in search recycler view
 */
data class UserInSearch(
    @Embedded val user: User
) : RecyclerItem {

    override val layoutId: Int
        get() = R.layout.list_item_user_simple

    override val variableId: Int
        get() = BR.user

    override val dataToBind: Any
        get() = user

    override val uniqueId: Int
        get() = user.id
}
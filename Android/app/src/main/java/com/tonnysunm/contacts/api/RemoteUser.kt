package com.tonnysunm.contacts.api

import com.tonnysunm.contacts.room.User


data class RemoteUserResponse(var results: List<RemoteUser>) {

    fun createDBUserWithFakeId(offset: Int): List<User> {
        return results.mapIndexed { index, remoteUser ->
            remoteUser.toDBUser(offset + index + 1)
        }
    }
    
}

data class RemoteUser(
    val fakeId: Int?,

    val name: Name?,
    val dob: Dob?,
    val gender: String?,

    val email: String?,

    val phone: String?,
    val cell: String?,

    val location: Location?,
    val nat: String?,

    val picture: Picture?
)

data class Dob(
    val date: String?
)

data class Name(
    val title: String?,

    val first: String?,
    val last: String?
)

data class Picture(
    val thumbnail: String?,
    val large: String?
)

data class Location(
    val city: String?,
    val country: String?,
    val postcode: String?,
    val state: String?,
    val street: Street?
) {
    override fun toString(): String {
        return listOfNotNull(
            street?.number,
            street?.name,
            city,
            state,
            country,
            postcode
        ).joinToString(" ")
    }
}

data class Street(
    val name: String?,
    val number: Int?
)

fun RemoteUser.toDBUser(id: Int): User {
    return User(
        id = id,
        title = name?.title,
        firstName = name?.first,
        lastName = name?.last,
        dayOfBirth = dob?.date,
        gender = gender,
        email = email,
        phone = phone,
        cell = cell,
        address = location.toString(),
        nationality = nat,
        pictureThumbnail = picture?.thumbnail,
        pictureLarge = picture?.large
    )
}
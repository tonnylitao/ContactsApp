package com.tonnysunm.contacts.api

import com.tonnysunm.contacts.room.User
import retrofit2.http.GET
import retrofit2.http.Query

interface WebService {

    @GET("/api")
    suspend fun getUsers(
        @Query("page") page: Int,
        @Query("results") results: Int,
        @Query("seed") seed: String
    ): RemoteUserResponse
    
}

data class RemoteUserResponse(
    var results: ArrayList<User>
)
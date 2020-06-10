package com.tonnysunm.contacts.api

import retrofit2.http.GET
import retrofit2.http.Query

interface WebService {

    @GET("/api")
    suspend fun getUsers(
        @Query("page") pageIndex: Int,
        @Query("results") pageSize: Int,
        @Query("seed") seed: String = "contacts"
    ): RemoteUserResponse

}
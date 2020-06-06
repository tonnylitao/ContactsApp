package com.tonnysunm.contacts.api

import com.google.gson.GsonBuilder
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

class ApiClient {

    companion object {
        /* disable github text search */
        private val BASE_URL =
            "\\u68\\u74\\u74\\u70\\u73\\u3a\\u2f\\u2f\\u72\\u61\\u6e\\u64\\u6f\\u6d\\u75\\u73\\u65\\u72\\u2e\\u6d\\u65\\u2f"
                .split("\\u")
                .drop(1)
                .map { it.toInt(16).toChar() }
                .joinToString("")

        val retrofit = Retrofit.Builder()
            .baseUrl(BASE_URL)
            .addConverterFactory(GsonConverterFactory.create(GsonBuilder().create()))
            .build().create(WebService::class.java)
    }
}


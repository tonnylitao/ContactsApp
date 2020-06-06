package com.tonnysunm.contacts.api

import com.google.gson.GsonBuilder
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import timber.log.Timber


class ApiClient {

    companion object {

        val retrofit: WebService by lazy {
            /* disable github text search */
            val BASE_URL =
                "\\u68\\u74\\u74\\u70\\u73\\u3a\\u2f\\u2f\\u72\\u61\\u6e\\u64\\u6f\\u6d\\u75\\u73\\u65\\u72\\u2e\\u6d\\u65\\u2f"
                    .split("\\u")
                    .drop(1)
                    .map { it.toInt(16).toChar() }
                    .joinToString("")

            val client = OkHttpClient.Builder()
                .addInterceptor(
                    HttpLoggingInterceptor(object : HttpLoggingInterceptor.Logger {
                        override fun log(message: String) {
                            Timber.tag("OkHttp").d(message)
                        }
                    }).apply {
                        level = HttpLoggingInterceptor.Level.BODY
                    }
                )
                .build()

            Retrofit.Builder()
                .baseUrl(BASE_URL)
                .client(client)
                .addConverterFactory(GsonConverterFactory.create(GsonBuilder().create()))
                .build()
                .create(WebService::class.java)
        }
    }
}


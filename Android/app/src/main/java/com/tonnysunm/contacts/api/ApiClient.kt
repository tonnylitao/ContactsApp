package com.tonnysunm.contacts.api

import com.google.gson.GsonBuilder
import com.simplemented.okdelay.DelayInterceptor
import com.tonnysunm.contacts.BuildConfig
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import okhttp3.logging.HttpLoggingInterceptor.Level
import okhttp3.logging.HttpLoggingInterceptor.Logger
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import timber.log.Timber
import java.util.concurrent.TimeUnit
import kotlin.random.Random


class ApiClient {

    companion object {
        val retrofit: WebService by lazy {

            /* disable github text search */
            val baseUrl =
                "\\u68\\u74\\u74\\u70\\u73\\u3a\\u2f\\u2f\\u72\\u61\\u6e\\u64\\u6f\\u6d\\u75\\u73\\u65\\u72\\u2e\\u6d\\u65\\u2f"
                    .split("\\u")
                    .drop(1)
                    .map { it.toInt(16).toChar() }
                    .joinToString("")


            val client = OkHttpClient.Builder()
                .addInterceptor(HttpLoggingInterceptor(object : Logger {
                    override fun log(message: String) {
                        Timber.tag("OkHttp").d(message)
                    }
                }).apply {
                    level = Level.BASIC
                })

            if (BuildConfig.DEBUG) {
                client.addInterceptor(
                    DelayInterceptor(Random.nextLong(100L, 1000L), TimeUnit.MILLISECONDS)
                )
            }

            Retrofit.Builder()
                .baseUrl(baseUrl)
                .client(client.build())
                .addConverterFactory(GsonConverterFactory.create(GsonBuilder().create()))
                .build()
                .create(WebService::class.java)
        }
    }
}

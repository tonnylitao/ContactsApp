package com.tonnysunm.contacts.library

import android.app.Application
import androidx.lifecycle.switchMap
import androidx.paging.Config
import androidx.paging.LivePagedListBuilder
import com.tonnysunm.contacts.Constant
import com.tonnysunm.contacts.api.ApiClient
import com.tonnysunm.contacts.room.DBRepository
import com.tonnysunm.contacts.room.User
import kotlinx.coroutines.CoroutineScope

class Repository(app: Application, scope: CoroutineScope) {

    private val remoteRepository = ApiClient.retrofit
    private val localRepository by lazy { DBRepository(app) }

    val factory = UserDataSourceFactory(localRepository, remoteRepository, scope)


    fun getUsers(): Listing<User> {
        val config = Config(
            pageSize = Constant.defaultPagingSize,
            initialLoadSizeHint = Constant.defaultPagingSize
        )

        return Listing<User>(
            pagedList = LivePagedListBuilder(factory, config).build(),
            refreshState = factory.sourceLiveData.switchMap {
                it.initialState
            },
            networkState = factory.sourceLiveData.switchMap {
                it.networkState
            },
            retry = {
                factory.sourceLiveData.value?.retryAllFailed()
            },
            refresh = {
                factory.invalidate()
            })

    }

}
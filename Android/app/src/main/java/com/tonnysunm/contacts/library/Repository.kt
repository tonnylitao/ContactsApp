package com.tonnysunm.contacts.library

import android.app.Application
import androidx.lifecycle.LiveData
import androidx.lifecycle.switchMap
import androidx.paging.Config
import androidx.paging.LivePagedListBuilder
import androidx.paging.PagedList
import androidx.paging.toLiveData
import com.tonnysunm.contacts.Constant
import com.tonnysunm.contacts.api.ApiClient
import com.tonnysunm.contacts.room.DBRepository
import com.tonnysunm.contacts.room.SearchedUser
import com.tonnysunm.contacts.room.User
import com.tonnysunm.contacts.ui.search.Filter
import kotlinx.coroutines.CoroutineScope

class Repository(app: Application, scope: CoroutineScope) {

    private val remoteRepository = ApiClient.retrofit
    private val localRepository by lazy { DBRepository(app) }

    private val factory =
        UserDataSourceFactory(localRepository, remoteRepository, scope)

    /**
     * from networking, and update local database through room for offline
     */
    fun getPageKeyedListing(): Listing<User> {
        return Listing(
            pagedList = LivePagedListBuilder(
                factory,
                Config(Constant.defaultPagingSize)
            ).build(),
            initialState = factory.sourceLiveData.switchMap {
                it.initialState
            },
            networkState = factory.sourceLiveData.switchMap {
                it.networkState
            },
            refresh = {
                factory.invalidate()
            })
    }

    /**
     * only from local database through room
     * this api does not support search by like firstName and like LastName,
     * otherwise use boundaryCallback to load remote data from api
     */
    fun getPositionalPageList(target: String, filter: Filter): LiveData<PagedList<SearchedUser>> {
        return localRepository.userDao.searchUsers("%$target%", filter.value())
            .toLiveData(pageSize = Constant.defaultPagingSize)
    }
}

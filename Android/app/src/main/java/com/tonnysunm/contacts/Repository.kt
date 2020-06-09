package com.tonnysunm.contacts

import android.app.Application
import androidx.lifecycle.LiveData
import androidx.paging.Config
import androidx.paging.LivePagedListBuilder
import androidx.paging.PagedList
import com.tonnysunm.contacts.api.ApiClient
import com.tonnysunm.contacts.library.UserDataSourceFactory
import com.tonnysunm.contacts.room.DBRepository
import com.tonnysunm.contacts.room.User
import kotlinx.coroutines.CoroutineScope

class Repository(app: Application, seed: String, scope: CoroutineScope) {

    private val remoteRepository = ApiClient.retrofit

    private val localRepository by lazy { DBRepository(app) }

//    private val diskIO = Executors.newSingleThreadExecutor()
//
//    // thread pool used for network requests
//    private val netWorkIO = Executors.newFixedThreadPool(5)

    /**
     * recycler view's dataSource
     * the data comes from local db which will be inserted, deleted and updated by the succeeding api
     */
    val userDataSource = UserDataSourceFactory(localRepository, remoteRepository, seed, scope)

    fun getUsers(pageSize: Int): LiveData<PagedList<User>> {

        val config = Config(
            pageSize = pageSize,
            initialLoadSizeHint = Constant.defaultPagingSize
        )

        return LivePagedListBuilder(userDataSource, config).build()
    }

}
package com.tonnysunm.contacts

import android.app.Application
import androidx.lifecycle.LiveData
import androidx.paging.PagedList
import androidx.paging.toLiveData
import com.tonnysunm.contacts.api.ApiClient
import com.tonnysunm.contacts.library.BoundaryCallback
import com.tonnysunm.contacts.room.DBRepository
import com.tonnysunm.contacts.room.User
import kotlinx.coroutines.CoroutineScope

class Repository(app: Application) {

    private val remoteRepository = ApiClient.retrofit

    private val localRepository by lazy { DBRepository(app) }

    fun getUsers(pageSize: Int, seed: String, scope: CoroutineScope): LiveData<PagedList<User>> {
        /**
         * recycler view's dataSource
         * the data comes from local db which will be inserted, deleted and updated by the succeeding web api
         */
        val userDataSource = localRepository.userDao.allUsersById()

        val callback = BoundaryCallback<User>(remoteRepository, localRepository, seed, scope)

        return userDataSource.toLiveData(
            pageSize = pageSize,
            boundaryCallback = callback
        )
    }

}
package com.tonnysunm.contacts

import android.app.Application
import androidx.lifecycle.LiveData
import androidx.paging.PagedList
import androidx.paging.toLiveData
import com.tonnysunm.contacts.api.ApiClient
import com.tonnysunm.contacts.api.WebService
import com.tonnysunm.contacts.room.DBRepository
import com.tonnysunm.contacts.room.User

class Repository(app: Application) {

    private var client: WebService = ApiClient.retrofit

    private val dbRepository by lazy { DBRepository(app) }

    var dataSource = dbRepository.userDao.allUsersById()

//    val firstTodo: LiveData<RemoteUserResponse> = liveData(Dispatchers.IO) {
//        val retrivedTodo = client.getTodo()
//        emit(retrivedTodo)
//    }

    fun getDBUsers(offset: Int, limit: Int): LiveData<PagedList<User>> {
//        val a = BoundaryCallback<User>()

        return dataSource.toLiveData(
            pageSize = limit
//            boundaryCallback = a
        )
    }
}
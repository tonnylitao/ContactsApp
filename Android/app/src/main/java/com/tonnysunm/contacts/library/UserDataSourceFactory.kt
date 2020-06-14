package com.tonnysunm.contacts.library

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.paging.DataSource
import com.tonnysunm.contacts.api.WebService
import com.tonnysunm.contacts.room.DBRepository
import com.tonnysunm.contacts.room.HomeUser
import kotlinx.coroutines.CoroutineScope
import timber.log.Timber


class UserDataSourceFactory(
    private val localRepository: DBRepository,
    private val remoteRepository: WebService,
    private val scope: CoroutineScope
) : DataSource.Factory<Int, HomeUser>() {

    private val _dataSourceLiveData = MutableLiveData<UserDataSource>()

    val sourceLiveData: LiveData<UserDataSource> = _dataSourceLiveData

    override fun create(): DataSource<Int, HomeUser> {
        Timber.d("create new PagedList/DataSource pair")

        val source = UserDataSource(localRepository, remoteRepository, scope)

        _dataSourceLiveData.postValue(source)

        return source
    }

    fun invalidate() {
        _dataSourceLiveData.value?.invalidate()
    }
}
package com.tonnysunm.contacts.library

import androidx.lifecycle.MutableLiveData
import androidx.paging.PageKeyedDataSource
import androidx.room.withTransaction
import com.tonnysunm.contacts.BuildConfig
import com.tonnysunm.contacts.Constant
import com.tonnysunm.contacts.api.RemoteUserResponse
import com.tonnysunm.contacts.api.WebService
import com.tonnysunm.contacts.room.DBRepository
import com.tonnysunm.contacts.room.User
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import timber.log.Timber

class UserDataSource(
    private val localRepository: DBRepository,
    private val remoteRepository: WebService,
    private val scope: CoroutineScope
) : PageKeyedDataSource<Int, User>() {

    val initialState = MutableLiveData(false)
    val networkState = MutableLiveData<NetworkState>()

    private var retry: (() -> Any)? = null

    fun retryAllFailed() {
        val prevRetry = retry; retry = null

        prevRetry?.let {
            scope.launch(Dispatchers.IO) {
                it.invoke()
            }
        }
    }

    override fun loadInitial(
        params: LoadInitialParams<Int>,
        callback: LoadInitialCallback<Int, User>
    ) {
        Timber.d("loadInitial")
        if (BuildConfig.DEBUG && params.requestedLoadSize != Constant.defaultPagingSize) {
            error("initialLoadSizeHint expected same as Constant.defaultPagingSize")
        }

        val offset = 0
        val limit = params.requestedLoadSize

        val dao = localRepository.userDao

        scope.launch(Dispatchers.IO) {
            /**
             * load data from local
             */
            networkState.postValue(NetworkState.LOADING)

            val localData = dao.queryUsers(offset, limit)

            /**
             * load data from api
             */
            val response: RemoteUserResponse
            try {
                response = remoteRepository.getUsers(Constant.firstPageIndex, limit)
            } catch (error: Exception) {
                Timber.e(error)

                val nextPageKey = if (localData.size == limit) 2 else null
                callback.onResult(localData, null, nextPageKey)

                Timber.d("local [0-${limit}] ${localData.size}")

                retry = {
                    loadInitial(params, callback)
                }

                initialState.postValue(true)
                networkState.postValue(NetworkState.error(error.message ?: "api unknown error"))
                return@launch
            }

            val remoteData = response.createDBUserWithFakeId(offset)

            /**
             * insert, update, delete the remoteData into db
             */
            if (localData.isEmpty()) {
                dao.insertIfNotExisted(remoteData)
            } else {
                val count = remoteData.size
                localRepository.db.withTransaction {
                    when (count) {
                        0 -> {
                            dao.deleteAll()
                        }
                        1 -> {
                            val first = remoteData.first()

                            dao.upsert(first)
                            dao.deleteAllAfter(first.id)
                        }
                        else -> {
                            dao.upsert(remoteData)

                            val last = remoteData.last()
                            if (count < limit) {
                                dao.deleteAllAfter(last.id)
                            }
                        }
                    }
                }
            }

            Timber.d("remote [0-${limit}] ${remoteData.size}")

            Timber.d(remoteData.map { it.id }.joinToString(" "))
            /**
             * use remoteData to update UI
             */
            val nextPageKey = if (remoteData.size == limit) 2 else null
            callback.onResult(remoteData, null, nextPageKey)

            initialState.postValue(true)
            networkState.postValue(NetworkState.LOADED)
        }
    }

    override fun loadAfter(params: LoadParams<Int>, callback: LoadCallback<Int, User>) {
        Timber.d("loadAfter")

        val pageIndex = params.key.dec()
        val offset = pageIndex * params.requestedLoadSize
        val limit = Constant.defaultPagingSize

        val dao = localRepository.userDao

        scope.launch(Dispatchers.IO) {
            networkState.postValue(NetworkState.LOADING)

            val localData = dao.queryUsers(offset, limit)

            Timber.d("local [${offset}-${offset + limit}] ${localData.size}")
            
            /**
             * load data from api
             */
            val response: RemoteUserResponse
            try {
                response = remoteRepository.getUsers(pageIndex, limit)
            } catch (error: Exception) {
                Timber.e(error)

                val nextPageKey = if (localData.size == limit) params.key.inc() else null
                callback.onResult(localData, nextPageKey)

                networkState.postValue(NetworkState.error(error.message ?: "api unknown error"))

                Timber.d("local [$offset-${offset + limit}] ${localData.size}")
                return@launch
            }

            val remoteData = response.createDBUserWithFakeId(offset)

            Timber.d(remoteData.map { it.id }.joinToString(" "))

            /**
             * insert, update, delete the remoteData into db
             */
            if (localData.isEmpty()) {
                dao.insertIfNotExisted(remoteData)
            } else {
                val count = remoteData.size
                localRepository.db.withTransaction {
                    when (count) {
                        0 -> {
                            dao.deleteAllOffset(offset - 1)
                        }
                        1 -> {
                            val first = remoteData.first()

                            dao.upsert(first)
                            dao.deleteAllAfter(first.id)
                        }
                        else -> {
                            dao.upsert(remoteData)

                            val last = remoteData.last()
                            if (count < limit) {
                                dao.deleteAllAfter(last.id)
                            }
                        }
                    }
                }
            }

            Timber.d("remote [$offset-${offset + limit}] ${remoteData.size}")

            /**
             * use remoteData to update UI
             */
            val nextPageKey = if (remoteData.size == limit) params.key.inc() else null
            callback.onResult(remoteData, nextPageKey)

            networkState.postValue(NetworkState.LOADED)
        }
    }

    override fun loadBefore(params: LoadParams<Int>, callback: LoadCallback<Int, User>) {}

}


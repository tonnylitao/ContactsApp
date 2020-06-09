package com.tonnysunm.contacts.library

import androidx.lifecycle.MutableLiveData
import androidx.paging.DataSource
import androidx.paging.PageKeyedDataSource
import androidx.room.withTransaction
import com.tonnysunm.contacts.BuildConfig
import com.tonnysunm.contacts.Constant
import com.tonnysunm.contacts.api.RemoteUserResponse
import com.tonnysunm.contacts.api.WebService
import com.tonnysunm.contacts.room.DBRepository
import com.tonnysunm.contacts.room.User
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch
import timber.log.Timber
import java.lang.Exception

class UserDataSource(
    private val localRepository: DBRepository,
    private val remoteRepository: WebService,
    private val seed: String,
    private val scope: CoroutineScope
) : PageKeyedDataSource<Int, User>() {

    override fun loadInitial(
        params: LoadInitialParams<Int>,
        callback: LoadInitialCallback<Int, User>
    ) {
        if (BuildConfig.DEBUG && params.requestedLoadSize != Constant.defaultPagingSize) {
            error("initialLoadSizeHint expected same as Constant.defaultPagingSize")
        }

        val offset = 0
        val limit = params.requestedLoadSize

        val dao = localRepository.userDao

        scope.launch {
            /**
             * load data from local
             */
            val localData = dao.queryUsers(offset, limit)

            /**
             * load data from api
             */
            val response: RemoteUserResponse
            try {
                response = remoteRepository.getUsers(Constant.firstPageIndex, limit, seed)
            }catch (error: Exception) {
                Timber.e(error)

                val nextPageKey = if (localData.size == limit) 2 else null
                callback.onResult(localData, null, nextPageKey)

                Timber.d("local [0-${limit}] ${localData.size}")
                return@launch
            }

            val remoteData = response.createDBUserWithFakeId(offset)

            /**
             * insert, update, delete the remoteData into db
             */
            if (localData.isEmpty()) {
                dao.insert(remoteData)
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
        }
    }

    override fun loadAfter(params: LoadParams<Int>, callback: LoadCallback<Int, User>) {
        val pageIndex = params.key.dec()
        val offset = pageIndex * params.requestedLoadSize
        val limit = Constant.defaultPagingSize

        val dao = localRepository.userDao

        scope.launch {
            val localData = dao.queryUsers(offset, limit)

            Timber.d("local [${offset}-${offset + limit}] ${localData.size}")

            /**
             * load data from api
             */
            val response: RemoteUserResponse
            try {
                response = remoteRepository.getUsers(pageIndex, limit, seed)
            }catch (error: Exception) {
                Timber.e(error)

                val nextPageKey = if (localData.size == limit) params.key.inc() else null
                callback.onResult(localData, nextPageKey)

                Timber.d("local [$offset-${offset+limit}] ${localData.size}")
                return@launch
            }

            val remoteData = response.createDBUserWithFakeId(offset)

            Timber.d(remoteData.map { it.id }.joinToString(" "))

            /**
             * insert, update, delete the remoteData into db
             */
            if (localData.isEmpty()) {
                dao.insert(remoteData)
            } else {
                val count = remoteData.size
                localRepository.db.withTransaction {
                    when (count) {
                        0 -> {
                            dao.deleteAllOffset(offset-1)
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

            Timber.d("remote [$offset-${offset+limit}] ${remoteData.size}")

            /**
             * use remoteData to update UI
             */
            val nextPageKey = if (remoteData.size == limit) params.key.inc() else null
            callback.onResult(remoteData, nextPageKey)
        }
    }

    override fun loadBefore(params: LoadParams<Int>, callback: LoadCallback<Int, User>) {}
}

class UserDataSourceFactory(
    private val localRepository: DBRepository,
    private val remoteRepository: WebService,
    private val seed: String,
    private val scope: CoroutineScope
) : DataSource.Factory<Int, User>() {

    val sourceLiveData = MutableLiveData<UserDataSource>()

    override fun create(): DataSource<Int, User> {
        val source = UserDataSource(localRepository, remoteRepository, seed, scope)

        sourceLiveData.postValue(source)

        return source
    }
}
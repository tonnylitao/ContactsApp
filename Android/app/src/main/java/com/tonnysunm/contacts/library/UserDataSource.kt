package com.tonnysunm.contacts.library

import androidx.lifecycle.MutableLiveData
import androidx.paging.PageKeyedDataSource
import androidx.room.withTransaction
import com.tonnysunm.contacts.Constant
import com.tonnysunm.contacts.api.RemoteUserResponse
import com.tonnysunm.contacts.api.WebService
import com.tonnysunm.contacts.room.DBRepository
import com.tonnysunm.contacts.room.User
import com.tonnysunm.contacts.room.UserDao
import com.tonnysunm.contacts.ui.main.UserUIModel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import timber.log.Timber

class UserDataSource(
    private val localRepository: DBRepository,
    private val remoteRepository: WebService,
    private val scope: CoroutineScope
) : PageKeyedDataSource<Int, UserUIModel>() {

    val initialState = MutableLiveData<State>()
    val networkState = MutableLiveData<State>()

    override fun loadInitial(
        params: LoadInitialParams<Int>,
        callback: LoadInitialCallback<Int, UserUIModel>
    ) {
        Timber.d("loadInitial ${params.requestedLoadSize}")

        initialState.postValue(State.Loading)

        val offset = 0
        val limit = params.requestedLoadSize

        val dao = localRepository.userDao

        scope.launch(Dispatchers.IO) {
            /**
             * load data from local
             */
            networkState.postValue(State.Loading)

            val localData = dao.queryUsers(offset, limit)

            /**
             * load data from api
             */
            val response: RemoteUserResponse
            try {
                response = remoteRepository.getUsers(Constant.firstPageIndex, limit)
            } catch (error: Exception) {
                Timber.e(error)

                val nextPageKey =
                    if (localData.size == limit) limit / Constant.defaultPagingSize else null
                callback.onResult(localData, 0, 5000, null, nextPageKey)
//                callback.onResult(localData, null, nextPageKey)

                Timber.d("local [0-${limit}] ${localData.size}")

                initialState.postValue(State.Success(Source.LOCAL))
                networkState.postValue(State.Error(error.message ?: "api unknown error"))
                return@launch
            }

            val remoteData = response.createDBUserWithFakeId(offset)

            Timber.d("remote [0-${limit}] ${remoteData.size} ${remoteData.map { it.id }
                .joinToString(" ")}")

            /**
             * use remoteData to update UI
             */
            val nextPageKey =
                if (remoteData.size == limit) limit / Constant.defaultPagingSize else null
            callback.onResult(remoteData.map { UserUIModel(it) }, 0, 5000, null, nextPageKey)

            initialState.postValue(State.Success(Source.REMOTE))
            networkState.postValue(State.Success(Source.REMOTE))

            /**
             * update local db
             */
            updateLocalDB(dao, localData, remoteData, offset, limit)
        }
    }

    override fun loadAfter(params: LoadParams<Int>, callback: LoadCallback<Int, UserUIModel>) {
        Timber.d("loadAfter ${params.key} ${params.requestedLoadSize}")

        val pageIndex = params.key
        val offset = pageIndex * params.requestedLoadSize
        val limit = params.requestedLoadSize

        val dao = localRepository.userDao

        val state = initialState.value
        if (state is State.Success && state.source == Source.LOCAL) {
            scope.launch(Dispatchers.IO) {
                val localData = dao.queryUsers(offset, limit)

                Timber.d("local [${offset}-${offset + limit}] ${localData.size}")

                val nextPageKey = if (localData.size == limit) params.key.inc() else null
                callback.onResult(localData, nextPageKey)
            }
            return
        }

        networkState.postValue(State.Loading)

        scope.launch(Dispatchers.IO) {
            val localData = dao.queryUsers(offset, limit)

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

                networkState.postValue(State.Error(error.message ?: "api unknown error"))

                Timber.d("local [$offset-${offset + limit}] ${localData.size}")
                return@launch
            }

            val remoteData = response.createDBUserWithFakeId(offset)

            Timber.d("remote [$offset-${offset + limit}] ${remoteData.size} ${remoteData.map { it.id }
                .joinToString(" ")}")

            /**
             * use remoteData to update UI
             */
            val nextPageKey = if (remoteData.size == limit) params.key.inc() else null
            callback.onResult(remoteData.map { UserUIModel(it) }, nextPageKey)

            networkState.postValue(State.Success(Source.REMOTE))

            updateLocalDB(dao, localData, remoteData, offset, limit)
        }
    }

    override fun loadBefore(params: LoadParams<Int>, callback: LoadCallback<Int, UserUIModel>) {}

    private suspend fun updateLocalDB(
        dao: UserDao,
        localData: List<UserUIModel>,
        remoteData: List<User>,
        offset: Int,
        limit: Int
    ) {
        /**
         * insert, update, delete the remoteData into db
         */
        if (localData.isEmpty()) {
            dao.insertIfNotExisted(remoteData)
        } else {
            val count = remoteData.size
            localRepository.db.withTransaction {
                if (count == 0) {
                    val isInitial = offset == 0
                    if (isInitial) {
                        dao.deleteAll()
                    } else {
                        dao.deleteAllOffset(offset)
                    }
                } else {
                    dao.upsert(remoteData)

                    if (count < limit) {
                        dao.deleteAllAfter(remoteData.last().id)
                    }
                }
            }
        }
    }
}

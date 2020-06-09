package com.tonnysunm.contacts.library

import androidx.lifecycle.MutableLiveData
import androidx.paging.DataSource
import androidx.paging.PageKeyedDataSource
import com.tonnysunm.contacts.BuildConfig
import com.tonnysunm.contacts.Constant
import com.tonnysunm.contacts.api.WebService
import com.tonnysunm.contacts.api.toDBUser
import com.tonnysunm.contacts.room.DBRepository
import com.tonnysunm.contacts.room.User
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch
import timber.log.Timber

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
        scope.launch {
            if (BuildConfig.DEBUG && params.requestedLoadSize != Constant.defaultPagingSize) {
                error("initialLoadSizeHint expected same as Constant.defaultPagingSize")
            }

            val limit = params.requestedLoadSize
            val list = localRepository.userDao.allUsersById(0, limit)

            Timber.d("[0-${limit}] ${list.size}")

            callback.onResult(list, null, 2)
//            callback.onResult(list, 0, 5000, null, 2)


            /**
             * load data from api
             */
            val result = remoteRepository.getUsers(Constant.firstPageIndex, limit, seed)

            val users = result.results.mapIndexed { index, remoteUser ->
                remoteUser.toDBUser(index + 1)
            }

            if (list.isEmpty()) {
                localRepository.userDao.insert(users)
                //TODO create a new PagedList / DataSource pair
            } else {
                //update delete
            }

        }
    }

    override fun loadAfter(params: LoadParams<Int>, callback: LoadCallback<Int, User>) {
        scope.launch {
            val offset = params.key.dec() * params.requestedLoadSize
            val limit = Constant.defaultPagingSize

            val list = localRepository.userDao.allUsersById(offset, limit)

            Timber.d("[${offset}-${offset + limit}] ${list.size}")

            callback.onResult(list, params.key.inc())
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
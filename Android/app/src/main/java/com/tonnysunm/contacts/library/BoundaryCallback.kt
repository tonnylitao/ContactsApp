package com.tonnysunm.contacts.library

import androidx.paging.PagedList
import com.tonnysunm.contacts.Constant
import com.tonnysunm.contacts.api.WebService
import com.tonnysunm.contacts.room.DBRepository
import com.tonnysunm.contacts.room.User
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import timber.log.Timber

class BoundaryCallback<T : RecyclerItem>(
    private val remoteRepository: WebService,
    private val localRepository: DBRepository,
    private val seed: String,
    private val scope: CoroutineScope
) : PagedList.BoundaryCallback<T>() {

    /**
     * first time load data from db
     */
    override fun onZeroItemsLoaded() {
        Timber.d("onZeroItemsLoaded")

        scope.launch(Dispatchers.IO) {
            val result = remoteRepository.getUsers(
                Constant.firstPageIndex,
                Constant.defaultPagingSize,
                seed
            )

            val users = result.results.mapIndexed { index, remoteUser ->
                User(id = index + 1, title = "", firstName = "", lastName = "", avatar = "")
            }
            
            localRepository.userDao.insert(users)
        }
    }

    override fun onItemAtEndLoaded(itemAtEnd: T) {
        Timber.d("onItemAtEndLoaded $itemAtEnd")
    }
}
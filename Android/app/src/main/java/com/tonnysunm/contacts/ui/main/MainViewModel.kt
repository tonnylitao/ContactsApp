package com.tonnysunm.contacts.ui.main

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.switchMap
import androidx.paging.PagedList
import com.tonnysunm.contacts.Constant
import com.tonnysunm.contacts.Repository
import com.tonnysunm.contacts.room.User


class MainViewModel(app: Application, val seed: String) : AndroidViewModel(app) {
    private val repository: Repository by lazy { Repository(app) }

    var currentPage = MutableLiveData<Int>(Constant.firstPageIndex)

    val data: LiveData<PagedList<User>> = currentPage.switchMap {
        repository.getDBUsers(0, it * Constant.defaultPagingSize)
    }


}
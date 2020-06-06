package com.tonnysunm.contacts.ui.main

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import androidx.paging.PagedList
import com.tonnysunm.contacts.Constant
import com.tonnysunm.contacts.Repository
import com.tonnysunm.contacts.room.User


class MainViewModel(app: Application, val seed: String) : AndroidViewModel(app) {
    private val repository: Repository by lazy { Repository(app) }

    var currentPage = MutableLiveData(Constant.firstPageIndex)

    val data: LiveData<PagedList<User>> =
        repository.getUsers(Constant.defaultPagingSize, seed, viewModelScope)

}
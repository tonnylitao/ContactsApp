package com.tonnysunm.contacts.ui.main

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import com.tonnysunm.contacts.Constant
import com.tonnysunm.contacts.Repository
import timber.log.Timber


class MainViewModel(app: Application, val seed: String) : AndroidViewModel(app) {
    private val repository: Repository by lazy { Repository(app, seed, viewModelScope) }

    var currentPage = MutableLiveData(Constant.firstPageIndex)

    fun getData() = repository.getUsers(Constant.defaultPagingSize)

    fun invalidateDataSource() {
        Timber.d("invalidateDataSource")

        repository.factory.sourceLiveData.value?.invalidate()
    }

}
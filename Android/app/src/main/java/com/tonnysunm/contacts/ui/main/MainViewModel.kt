package com.tonnysunm.contacts.ui.main

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.tonnysunm.contacts.library.Repository
import timber.log.Timber


class MainViewModel(app: Application) : AndroidViewModel(app) {

    private val repository: Repository by lazy { Repository(app, viewModelScope) }
    
    fun getListing() = repository.getUsers()

    fun invalidateDataSource() {
        Timber.d("invalidateDataSource")

        repository.factory.invalidate()
    }

}
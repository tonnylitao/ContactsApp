package com.tonnysunm.contacts.ui.main

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.tonnysunm.contacts.library.Repository
import com.tonnysunm.contacts.room.HomeUser

typealias UserUIModel = HomeUser

class MainViewModel(app: Application) : AndroidViewModel(app) {

    private val repository: Repository by lazy { Repository(app, viewModelScope) }

    fun getPageKeyedListing() = repository.getPageKeyedListing()

}

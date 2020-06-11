package com.tonnysunm.contacts.ui.main

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.tonnysunm.contacts.library.Repository


class MainViewModel(app: Application) : AndroidViewModel(app) {

    private val repository: Repository by lazy { Repository(app, viewModelScope) }

    fun getUserListing() = repository.getUserListing()

}

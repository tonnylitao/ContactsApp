package com.tonnysunm.contacts.ui.detail

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import com.tonnysunm.contacts.room.DBRepository

class DetailViewModel(app: Application) : AndroidViewModel(app) {
    
    private val localRepository by lazy { DBRepository(app) }

    fun getUser(id: Int) = localRepository.userDao.queryUser(id)
}
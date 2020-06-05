package com.tonnysunm.contacts.ui.main

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.LiveData
import androidx.paging.PagedList
import androidx.paging.toLiveData
import com.tonnysunm.contacts.BR
import com.tonnysunm.contacts.R
import com.tonnysunm.contacts.library.RecyclerItem
import com.tonnysunm.contacts.model.Repository
import com.tonnysunm.contacts.model.User


class MainViewModel(app: Application, val seed: String) : AndroidViewModel(app) {

    private val _repository: Repository by lazy { Repository(app) }

    val data: LiveData<PagedList<RecyclerItem<User>>> by lazy {
        _repository.userDao.getPagingAll().map {
            it.recyclerItem()
        }.toLiveData(pageSize = 5)
    }
}

fun User.recyclerItem() = RecyclerItem(
    data = this, layoutId = R.layout.list_item_user, variableId = BR.user
)
package com.tonnysunm.contacts.ui.search

import android.app.Application
import android.os.Bundle
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.switchMap
import androidx.lifecycle.viewModelScope
import com.tonnysunm.contacts.library.Repository


class SearchViewModel(
    app: Application,
    sharedViewModel: SearchSharedViewModel,
    arguments: Bundle
) : AndroidViewModel(app) {

    private val filter: Filter =
        Filter.valueBy(arguments.getInt(SearchFragment.ARG_FILTER_VALUE, -1))

    private val repository: Repository by lazy { Repository(app, viewModelScope) }

    val pageList = sharedViewModel.targetLiveData.switchMap {
        repository.getPositionalPageList(it, filter)
    }

}

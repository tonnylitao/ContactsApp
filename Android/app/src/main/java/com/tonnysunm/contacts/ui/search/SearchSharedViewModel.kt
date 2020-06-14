package com.tonnysunm.contacts.ui.search

import androidx.annotation.MainThread
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel

class SearchSharedViewModel : ViewModel() {

    private val _targetLiveData = MutableLiveData<String>()

    val targetLiveData: LiveData<String>
        get() = _targetLiveData

    @MainThread
    fun setTarget(target: String?) {
        _targetLiveData.value = target ?: ""
    }
}

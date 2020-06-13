package com.tonnysunm.contacts.library

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import kotlin.reflect.full.primaryConstructor

class AndroidViewModelFactory(private vararg val args: Any?) :
    ViewModelProvider.NewInstanceFactory() {

    override fun <T : ViewModel> create(modelClass: Class<T>) = requireNotNull(
        modelClass.kotlin.primaryConstructor?.call(*args),
        { "$modelClass primaryConstructor is null" })

}



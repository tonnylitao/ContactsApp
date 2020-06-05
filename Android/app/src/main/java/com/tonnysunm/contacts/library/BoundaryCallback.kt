package com.tonnysunm.contacts.library

import androidx.paging.PagedList

class BoundaryCallback<T : RecyclerItem> : PagedList.BoundaryCallback<T>() {

    override fun onZeroItemsLoaded() {

    }

    override fun onItemAtEndLoaded(itemAtEnd: T) {

    }
}
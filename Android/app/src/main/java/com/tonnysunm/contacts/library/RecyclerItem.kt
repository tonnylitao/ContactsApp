package com.tonnysunm.contacts.library;

import androidx.recyclerview.widget.DiffUtil

interface Equatable {
    override fun equals(other: Any?): Boolean
}

interface RecyclerItem : Equatable {

    /**
     * for areItemsTheSame
     */
    val uniqueId: Int

    /**
     * layout of item in recycler view
     */
    val layoutId: Int

    /**
     * data-binding variable of the above layout
     */
    val variableId: Int

    companion object {

        fun <M : RecyclerItem> diffCallback() = object : DiffUtil.ItemCallback<M>() {

            override fun areItemsTheSame(old: M, aNew: M) =
                old === aNew || old.uniqueId == aNew.uniqueId

            override fun areContentsTheSame(old: M, aNew: M) = old == aNew

        }
    }
}
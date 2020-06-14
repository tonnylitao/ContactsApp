package com.tonnysunm.contacts.library

import androidx.recyclerview.widget.DiffUtil

interface RecyclerItem {
    /**
     * layout of item in recycler view, layoutId presents the itemType of recyclerview
     */
    val layoutId: Int

    /**
     * data-binding variable of the above layout
     */
    val variableId: Int

    /**
     * the real data to bind
     */
    val dataToBind: Any

    /**
     * make sure equality in areItemsTheSame
     */
    val uniqueId: Int

    /**
     * make sure equality in areContentsTheSame
     */
    override fun equals(other: Any?): Boolean

    companion object {

        fun <M : RecyclerItem> diffCallback() = object : DiffUtil.ItemCallback<M>() {

            override fun areItemsTheSame(old: M, aNew: M) =
                old === aNew || old.uniqueId == aNew.uniqueId

            override fun areContentsTheSame(old: M, aNew: M) = old == aNew

        }

    }
}
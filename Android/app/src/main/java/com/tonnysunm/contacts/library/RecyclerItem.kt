package com.tonnysunm.contacts.library;

import androidx.databinding.ViewDataBinding
import androidx.recyclerview.widget.DiffUtil

interface RecyclerItem {
    /**
     * layout of item in recycler view
     */
    val layoutId: Int

    /**
     * data-binding variable of the above layout
     */
    val variableId: Int

    /**
     * equality in areItemsTheSame
     */
    val uniqueId: Int
    
    /**
     * equality in areContentsTheSame
     */
    override fun equals(other: Any?): Boolean

    companion object {

        fun <M : RecyclerItem> diffCallback() = object : DiffUtil.ItemCallback<M>() {

            override fun areItemsTheSame(old: M, aNew: M) =
                old === aNew || old.uniqueId == aNew.uniqueId

            override fun areContentsTheSame(old: M, aNew: M) = old == aNew

        }

    }

    fun bind(binding: ViewDataBinding) {
        binding.setVariable(variableId, this)
        binding.executePendingBindings()
    }
}
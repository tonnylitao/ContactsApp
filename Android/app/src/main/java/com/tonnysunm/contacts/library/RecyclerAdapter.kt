package com.tonnysunm.contacts.library

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.databinding.ViewDataBinding
import androidx.paging.PagedListAdapter
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.RecyclerView

class RecyclerAdapter<M : RecyclerItem>(
    diffCallback: DiffUtil.ItemCallback<M>,
    private val clickListener: ((M) -> Unit)? = null
) : PagedListAdapter<M, RecyclerAdapter<M>.ViewHolder>(diffCallback) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int) =
        ViewHolder(
            DataBindingUtil.inflate(LayoutInflater.from(parent.context), viewType, parent, false)
        ).apply {
            itemView.setOnClickListener {
                val item = getItem(this.absoluteAdapterPosition) ?: return@setOnClickListener
                clickListener?.invoke(item)
            }
        }

    override fun getItemViewType(position: Int) =
        requireNotNull(getItem(position)?.layoutId) { "item at $position is null" }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        getItem(position)?.bind(holder.binding)
    }

    /* ViewHolder */
    inner class ViewHolder(val binding: ViewDataBinding) : RecyclerView.ViewHolder(binding.root)
}


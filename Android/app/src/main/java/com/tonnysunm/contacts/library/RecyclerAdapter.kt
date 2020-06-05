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
        getItem(position)?.layoutId ?: throw IllegalArgumentException("position $position")

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val item = getItem(position) ?: return

        holder.binding.setVariable(item.variableId, item)
        holder.binding.executePendingBindings()

    }

    /* ViewHolder */
    inner class ViewHolder(val binding: ViewDataBinding) : RecyclerView.ViewHolder(binding.root)
}


package com.tonnysunm.contacts.library

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.databinding.ViewDataBinding
import androidx.paging.PagedListAdapter
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.RecyclerView
import com.tonnysunm.contacts.R

class RecyclerAdapter<M : RecyclerItem>(
    diffCallback: DiffUtil.ItemCallback<M>,
    private val clickListener: ((RecyclerAdapter<M>, Int, M) -> Unit)? = null
) : PagedListAdapter<M, RecyclerAdapter<M>.ViewHolder>(diffCallback) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int) =
        if (viewType != -1)
            ViewHolder(
                DataBindingUtil.inflate(
                    LayoutInflater.from(parent.context),
                    viewType,
                    parent,
                    false
                )
            ).apply {
                itemView.setOnClickListener {
                    val item = getItem(this.absoluteAdapterPosition) ?: return@setOnClickListener

                    clickListener?.invoke(this@RecyclerAdapter, this.absoluteAdapterPosition, item)
                }
            }
        else ViewHolder(
            DataBindingUtil.inflate(
                LayoutInflater.from(parent.context),
                R.layout.list_item_user_shimmer,
                //R.layout.list_item_user_placeholder,
                parent,
                false
            )
        )

    override fun getItemViewType(position: Int) = getItem(position)?.layoutId ?: -1
//        requireNotNull() { "item at $position is null" }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        getItem(position)?.run(holder.binding::bind)
    }

    /* ViewHolder */
    inner class ViewHolder(val binding: ViewDataBinding) : RecyclerView.ViewHolder(binding.root)
}

private fun ViewDataBinding.bind(item: RecyclerItem) {
    setVariable(item.variableId, item)
    executePendingBindings()
}
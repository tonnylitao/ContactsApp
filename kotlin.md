### Good practise in Kotlin

* one generic RecyclerAdapter rather than duplicated adapters

```kotlin
//users RecyclerView in Fragment
val adapter1 = RecyclerAdapter(RecyclerItem.diffCallback<User>())

//messages RecyclerView in another Fragment
val adapter2 = RecyclerAdapter(RecyclerItem.diffCallback<Messages>())

```

* utilize itemViewType with data-binding to simplify ViewHolder

```kotlin
override fun getItemViewType(position: Int) = 
	getItem(position)?.layoutId ?: throw IllegalArgumentException("position $position")

override fun onBindViewHolder(holder: ViewHolder, position: Int) {
    val item = getItem(position) ?: return

    holder.binding.setVariable(item.variableId, item)
    holder.binding.executePendingBindings()
}

/* slim viewholder */
inner class ViewHolder(val binding: ViewDataBinding) : RecyclerView.ViewHolder(binding.root)
```
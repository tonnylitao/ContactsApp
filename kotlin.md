### Good practices in Android development

---
#### A generic RecyclerAdapter rather than duplicated adapters

```kotlin
//users RecyclerView in Fragment
val adapter1 = RecyclerAdapter(RecyclerItem.diffCallback<User>())

//messages RecyclerView in another Fragment
val adapter2 = RecyclerAdapter(RecyclerItem.diffCallback<Messages>())

```

---
#### Utilize itemViewType with data-binding to simplify ViewHolder

```kotlin
override fun getItemViewType(position: Int) =
	requireNotNull(getItem(position)?.layoutId, { "item at $position is null" })
            
override fun onBindViewHolder(holder: ViewHolder, position: Int) {
    getItem(position)?.bind(holder.binding)
}

/* slim viewholder */
inner class ViewHolder(val binding: ViewDataBinding) : RecyclerView.ViewHolder(binding.root)
```

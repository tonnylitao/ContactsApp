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
#### UI Model implement RecyclerItem

```kotlin

data class UserInHome(
    @Embedded val user: User
) : RecyclerItem {
    override val layoutId: Int
        get() = R.layout.list_item_user

    override val variableId: Int
        get() = BR.user

    override val dataToBind: Any
        get() = user

    override val uniqueId: Int
        get() = user.userId
}

data class AdminInSearch(
    @Embedded val admin: Admin
) : RecyclerItem {

    override val layoutId: Int
        get() = R.layout.list_item_admin

    override val variableId: Int
        get() = BR.admin

    override val dataToBind: Any
        get() = admin.mappingToOtherModel()

    override val uniqueId: Int
        get() = admin.adminId
}
```

---
#### Utilize itemViewType with data-binding to simplify ViewHolder

```kotlin
override fun getItemViewType(position: Int) =
	requireNotNull(getItem(position)?.layoutId, { "item at $position is null" })
            
override fun onBindViewHolder(holder: ViewHolder, position: Int) {
    getItem(position)?.run(holder.binding::bind)
}

/* slim viewholder */
inner class ViewHolder(val binding: ViewDataBinding) : RecyclerView.ViewHolder(binding.root)
```

---
#### One ViewModelFactory creates varible ViewModels

```kotlin

class AndroidViewModelFactory(private vararg val args: Any?) :
    ViewModelProvider.NewInstanceFactory() {

    override fun <T : ViewModel> create(modelClass: Class<T>) = requireNotNull(
        modelClass.kotlin.primaryConstructor?.call(*args),
        { "$modelClass primaryConstructor is null" })

}

//Fragment1

private val viewModel by viewModels<IntViewModel> {
    AndroidViewModelFactory( requireActivity().application, 1)
}

//Fragment2

private val viewModel by viewModels<StringViewModel> {
    AndroidViewModelFactory( requireActivity().application, "Hello")
}
```

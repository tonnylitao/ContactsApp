package com.tonnysunm.contacts.ui

import android.widget.ImageView
import androidx.core.view.isGone
import androidx.databinding.BindingAdapter
import com.tonnysunm.contacts.GlideApp


@BindingAdapter("imageUrl")
fun loadImage(view: ImageView, url: String?) {
    if (view.isGone || url == null) return

    if (!view.clipToOutline) {
        view.clipToOutline = true
    }

    GlideApp.with(view.context)
        .load(url)
        .into(view)
}
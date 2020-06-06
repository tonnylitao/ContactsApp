package com.tonnysunm.contacts.ui

import android.graphics.drawable.Drawable
import android.widget.ImageView
import androidx.core.view.isGone
import androidx.databinding.BindingAdapter
import com.bumptech.glide.load.resource.bitmap.CircleCrop
import com.jwang123.flagkit.FlagKit
import com.tonnysunm.contacts.GlideApp
import com.tonnysunm.contacts.R
import java.util.*


@BindingAdapter("imageUrl")
fun loadImage(view: ImageView, url: String?) {
    url ?: return //TODO placeholder

    GlideApp.with(view.context)
        .load(url)
        .transform(CircleCrop())
        .into(view)
}

@BindingAdapter("genderImage")
fun setGenderImage(view: ImageView, gender: String?) {
    view.isGone = gender == null

    gender ?: return

    val genderImage = if (gender == "male") R.drawable.ic_male else R.drawable.ic_female
    view.setImageResource(genderImage)
}

@BindingAdapter("flag")
fun setFlag(view: ImageView, nationality: String?) {
    view.isGone = nationality == null

    nationality ?: return

    val drawable: Drawable
    try {
        drawable = FlagKit.drawableWithFlag(view.context, nationality.toLowerCase(Locale.ROOT))
    } catch (error: Exception) {
        view.isGone = true
        return
    }

    view.setImageDrawable(drawable)
}


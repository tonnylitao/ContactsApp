package com.tonnysunm.contacts.ui

import android.graphics.drawable.Drawable
import android.widget.ImageView
import android.widget.TextView
import androidx.core.view.isGone
import androidx.databinding.BindingAdapter
import com.bumptech.glide.load.resource.bitmap.CircleCrop
import com.jwang123.flagkit.FlagKit
import com.tonnysunm.contacts.GlideApp
import com.tonnysunm.contacts.R
import java.text.SimpleDateFormat
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

@BindingAdapter("ddMMyyyy")
fun dateFormat(view: TextView, date: String?) {
    view.isGone = date == null

    date ?: return

    view.text = date.date()?.localString("dd/MM/yyyy")
}

fun String.date(): Date? {
    val dateFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.getDefault())
    dateFormat.timeZone = TimeZone.getTimeZone("GMT")

    return try {
        dateFormat.parse(this)
    } catch (e: java.lang.Exception) {
        null
    }
}

fun Date.localString(format: String): String =
    SimpleDateFormat(format, Locale.getDefault()).format(this)



package com.tonnysunm.contacts.ui.search

import android.content.Context
import com.tonnysunm.contacts.R

enum class Filter(val index: Int) {
    All(0),
    NZ(1),
    US(2);

    fun value(): String = when (this) {
        All -> ""
        NZ -> "NZ"
        US -> "US"
    }

    fun title(context: Context): String? {
        val res = when (this) {
            Filter.All -> R.string.tab_text_1
            Filter.NZ -> R.string.tab_text_2
            Filter.US -> R.string.tab_text_3
        }

        return context.resources.getString(res)
    }

    companion object {
        fun valueBy(index: Int): Filter {
            return values().first { it.index == index }
        }
    }
}
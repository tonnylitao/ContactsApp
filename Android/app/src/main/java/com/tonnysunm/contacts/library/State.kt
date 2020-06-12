package com.tonnysunm.contacts.library

enum class Source {
    LOCAL,
    REMOTE
}

fun Source.tips() =
    if (this == Source.LOCAL) {
        "📴 OFFLINE"
    } else {
        "✅ ONLINE"
    }

sealed class State {
    object Loading : State()

    class Success(val source: Source) : State()

    class Error(val message: String?) : State()
}

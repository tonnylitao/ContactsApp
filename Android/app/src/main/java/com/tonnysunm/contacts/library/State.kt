package com.tonnysunm.contacts.library

enum class Source {
    LOCAL,
    REMOTE
}

sealed class State {
    object Loading : State()

    class Success(val source: Source) : State()

    class Error(val message: String?) : State()
}

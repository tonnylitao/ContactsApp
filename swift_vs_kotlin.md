### Comparison between Swift and Kotlin
There are many similarities and differences between Swift and Kotlin. I'll pick some good parts of each language and compare them.

---
#### Swift's @autoclosure

In Swift. An autoclosure is a closure that is automatically created to wrap an expression that’s being passed as an argument to a function. And the advantage is to lazy the caculation of closure.

```swift
func require(_ value: Bool, _ lazyMessage: @autoclosure () -> String) {
    if !value {
        let message = lazyMessage()
        fatalError(message)
    }
}

let count = -1
require(count >= 0, "Count must be non-negative, was \(count)")
```

And there is no equivalent to `@autoclosure` in Kotlin, it means there is no auto wrapping, we have to call the high-order function explicitly.

```kotlin
fun require(value: Boolean, lazyMessage: () -> Any): Unit {
    ...
    
    if (!value) {
        val message = lazyMessage()
        throw IllegalArgumentException(message.toString())
    }
}

require(count >= 0) { "Count must be non-negative, was $count" }
```

---
#### Dance with IO background thread and UI main thread

In swift, the task cannot be canceld once it enque.

```swift
DispatchQueue.global().async {
    //background task
    
    DispatchQueue.main.async {
        //ui thread    
    }
}
```

if you need to cancel it:

```swift
let workItem = DispatchWorkItem {
    //background task
    
    DispatchQueue.main.async {
        //ui thread
    }
}

DispatchQueue.global().async(execute: workItem)

workItem.cancel()
```

In Kotlin, 

```kotlin
viewModelScope.launch(Dispatchers.IO) {
    //background task
    
    viewModelScope.launch(Dispatchers.Main) {
        //ui thread    
    }
}
```
if you cancel scope, all the routines with that scope will be canceled automatically. And the life owner of viewModel will cancel the scope when necessary, e.g. when the activity or fragment is destroyed.

---
#### guard

In Swift,

```swift

func someMethod() {
    guard let id = id else { return }
    
    //id is not nil here
}


completion { [weak self] in 
    guard let self = self else { return }

    //self is not nil here
}

```

In Kotlin,

```kotlin

fun someMethod() {
    id ?: return
    
    //id is not null here
}

completion {
    id ?: return@completion

    //id is not null here
}

```




### Comparison between Swift and Kotlin
There are many similarities and differences between Swift and Kotlin. I'll pick some good parts of each language and compare them.

#### Swift's @autoclosure

In Swift. An autoclosure is a closure that is automatically created to wrap an expression that’s being passed as an argument to a function.

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


### Kotlin for iOS developer

- [TODO](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin/-t-o-d-o.html)

```kotlin
//kotlin

fun TODO(reason: String): Nothing
```

```
//swift global function

func TODO(_ message: String = "") {
    #if DEBUG
    	fatalError(message)
    #endif
}

```

- [apply scope function](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin/apply.html)

```kotlin
//kotlin

inline fun <T> T.apply(block: T.() -> Unit): T
```

```swift
//swift Protocol-oriented programming

protocol Dao {}

extension NSObject: Dao {}

extension Dao where Self: NSObject {

    typealias Decorator = (Self) -> Void

    @discardableResult
    func apply(_ decorators: Decorator...) -> Self {

        decorators.forEach {
            $0(self)
        }

        return self
    }
}

```

```swift
//old way

private lazy var viewModel: UserTableViewModel = {
    let temp = UserTableViewModel()
    temp.tableView = self.tableView
    return temp
}()

```

```swift
//new way, kotlin's scope function in swift

private lazy var viewModel = UserTableViewModel().apply {
    $0.tableView = self.tableView
}

```

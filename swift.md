### Good practices in iOS development
---
#### Use compactMap to join optionals

```swift
//old way

var text = ""
if let value = particulars {
    text += value
}

if let value = code {
    text += " " + value
}

if let value = reference {
    text += " " + value
}
```

```swift
//swift way

var text = [particulars, code, reference]
    .compactMap { $0 }
    .joined(separator: " ")

```
---
#### Use @autoclosure to wrap expression which doesn't need to be caculated in release environment

```swift
func print(_ item: @autoclosure () -> Any) {
    #if DEBUG
    Swift.print(item(), terminator: "\n")
    #endif
}
```
---
#### Result in chain

```swift
extension Result {
    
    @discardableResult
    func onSuccess(_ handler: (Success) -> ()) -> Self {
        if case let .success(value) = self { handler(value) }
        return self
    }
    
    @discardableResult
    func onFailure(_ handler: (Failure) -> ()) -> Self {
        if case let .failure(error) = self { handler(error) }
        return self
    }
}
```

```swift
result.onSuccess {
    ...
} .onFailure {
    ...
}
```


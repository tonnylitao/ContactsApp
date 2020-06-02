### Good practise in Swift

* Use compactMap to join optionals

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

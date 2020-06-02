### Good practise in Swift

* Use compactMap to join optionals

```
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

```
//swift way

var text = [particulars, code, reference]
    .compactMap { $0 }
    .joined(separator: " ")

```

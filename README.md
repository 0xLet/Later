# Later

Promise and do work later.

## Later.Methods

#### do

```swift
do<T>(withDelay delay: UInt32 = 0,
      work: @escaping () -> T) -> LaterValue<T>

do(withDelay delay: UInt32 = 0,
   work: @escaping () -> Void) -> LaterValue<Void>
```

#### fetch

```swift
fetch(url: URL) -> LaterValue<(Data?, URLResponse?, Error?)>

fetch(url: URL,
      work: @escaping (Data?, URLResponse?, Error?) -> Void) -> LaterValue<Void>

fetch(url: URL,
      errorHandler: ((Error) -> Void)? = nil,
      responseHandler: ((URLResponse) -> Void)? = nil,
      dataHandler: ((Data) -> Void)? = nil) -> LaterValue<Void>
```

#### promise

```swift
promise<T>(work: @escaping (LaterPromise<T>) -> Void) -> LaterValue<T>
    
promise(work: @escaping (LaterPromise<Void>) -> Void) -> LaterValue<Void>
```

****

## Examples

#### do
```swift
Later.do(withDelay: 2) {
    DispatchQueue.main.async {
        label.text = "Later!"
    }
}
```

#### fetch
```swift
Later.fetch(url: URL(string: "https://jsonplaceholder.typicode.com/todos/1")!)
    .whenSuccess { (data, response, error) in
    guard let data = data else {
        return
    }
    
    self.value = String(data: data, encoding: .utf8) ?? "-1"
}
```

#### promise
```swift
let promise = Later.promise { (promise) in
    sleep(10)
    promise.succeed(())
}

promise.whenSuccess { page in
    print("Page received")
}


promise.whenFailure { error in
    print("Error: \(error)")
}
```


### promise + fetch
```swift
private lazy var futureImage: LaterValue<UIImage?> = Later.promise { (promise) in
    URL(string: self.imageURL).map { url in
        Later.fetch(url: url) { data in
            guard let image = UIImage(data: data) else {
                promise.succeed(nil)
                return
            }
            promise.succeed(image)
        }
    }
}
```

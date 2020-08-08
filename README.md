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

#### post

```swift
/// ["Content-Type": "application/json; charset=utf-8"]
post(url: URL, withData data: () -> Data) -> LaterValue<(Data?, URLResponse?, Error?)>
```

#### promise

```swift
promise<T>(work: @escaping (LaterPromise<T>) -> Void) -> LaterValue<T>
    
promise(work: @escaping (LaterPromise<Void>) -> Void) -> LaterValue<Void>
```

#### main

```swift
main(withDelay delay: UInt32 = 0,
     work: @escaping () -> Void) -> LaterValue<Void>
```

## LaterValue

```swift
and: Later.Type { Later.self }
when(value: @escaping (LaterValue<Value>) -> Void) -> Later.Type
```

****

## Examples

#### do
```swift
Later.do(withDelay: 2) {
    Later.main {
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

#### post
```swift
Later.post(url: URL(string: "https://postman-echo.com/post")!) {
    "Some Data".data(using: .utf8)!
}
.when { event in
    event
        .whenSuccess { (data, reponse, _) in
            print(String(data: data!, encoding: .utf8) ?? "-1")
            print(reponse)
    }
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

#### main
```swift
Later.main { 
    self.value = "Fetching Again..." 
}
```

#### and
```swift
Later
    .do { print("Do Something") }
    .and
    .do { print("Do Something Else") }
```

#### when
```swift
Later
    .do { print("Do First") }
    .when { event in
        event
            .whenComplete { _ in
                print("Do Last")
        }
    }
    .do { print("Do Something Else") }
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

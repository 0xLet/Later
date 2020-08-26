# Later
<img src="assets/later.png" width="256">

Promise and do work later.

## [Swift-NIO EventLoops](https://github.com/apple/swift-nio#eventloops-and-eventloopgroups)

## typealiases
```swift
public typealias LaterValue = EventLoopFuture
public typealias LaterPromise = EventLoopPromise
public typealias RepeatedScheduledTask = RepeatedTask
public typealias ScheduledTask = Scheduled
```

## Later.Methods

#### promise

```swift
promise<T>(work: @escaping (LaterPromise<T>) -> Void) -> LaterValue<T>
    
promise(work: @escaping (LaterPromise<Void>) -> Void) -> LaterValue<Void>
```

#### do

```swift
do<T>(withDelay delay: UInt32 = 0,
      work: @escaping () throws -> T) -> LaterValue<T>

do(withDelay delay: UInt32 = 0,
   work: @escaping () throws -> Void) -> LaterValue<Void>
```

#### schedule

```swift
scheduleRepeatedTask(initialDelay: TimeAmount = TimeAmount.seconds(0),
                    delay: TimeAmount = TimeAmount.seconds(0),
                    work: @escaping (RepeatedScheduledTask) -> Void) -> RepeatedScheduledTask
                    
scheduleTask(in time: TimeAmount = TimeAmount.seconds(0),
            work: @escaping () -> Void) -> ScheduledTask<Void>
```

#### main

```swift
main(withDelay delay: UInt32 = 0,
     work: @escaping () throws -> Void) -> LaterValue<Void>
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

## LaterValue

```swift
and: Later.Type { Later.self }
when(value: @escaping (LaterValue<Value>) -> Void) -> Later.Type
```

## Contract

```swift
public class Contract<Value> {
    public init(initialValue: Value? = nil,
                onResignHandler: ((Value?) -> Void)? = nil,
                onChangeHandler: ((Value?) -> Void)? = nil) {
        onResign = onResignHandler
        onChange = onChangeHandler
        value = initialValue
        start()
        promise?.succeed(value)
    }
}
```

****

## Examples

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

#### do
```swift
Later.do(withDelay: 2) {
    work()
}
```

#### schedule
```swift
let task = Later.scheduleRepeatedTask(initialDelay: .seconds(0),
               delay: .seconds(1)) { (task) in
               work()
}

Later.scheduleTask(in: .seconds(3)) {
    task.cancel()
}
```

#### main
```swift
Later.main { 
    // Update UI
    self.value = "Fetching Again..." 
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
    .do { print("Do Something") }
    .when { event in
        event
            .whenComplete { _ in
                print("Do Last")
        }
    }
    .do { print("Do Something Else") }
```

### Contract
```swift
let textContract = Contract<String>()
let label = Label("❗️👀")
    
textContract
    .onChange { value in
        Later.main { [weak self] in
            self?.label.text = value
        }
}
.onResign { lastValue in
    Later.main { [weak self] in
        self?.label.text = "Contract was Resigned\nLast Value: \(lastValue ?? "-1")"
    }
}

textContract.value = "Hello, World!"
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

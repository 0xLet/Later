import XCTest
import NIO

@testable import Later

final class LaterTests: XCTestCase {
func testExample() {
    var bag = [EventLoopFuture<Void>]()
    var sema = DispatchSemaphore(value: 0)
    
    print("System cores: \(System.coreCount)")
    let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    let ev = group.next()
    
    let promise = ev.promise { (promise) in
        sleep(10)
        print("PROMISE!")
        sema.signal()
        promise.succeed(())
    }
    
    promise.whenSuccess { page in
        print("Page received")
    }
    
    
    promise.whenFailure { error in
        print("Error: \(error)")
    }
    
//    Later.default.store(future: promise)
    
    var spam = true
    
    let result = ev.do(withDelay: 5) {
        spam = false
        print("Hello World!")
    }
    
    bag.append(result)
    
    print("First")
    
    while spam {
        sleep(1)
        print("Spam!")
    }
    
    ev.do {
        print("last?")
    }
    
    print("Waiting for Promise...")
    
    sema.wait()
    
    try! group.syncShutdownGracefully()
}
    
    static var allTests = [
        ("testExample", testExample),
    ]
}

import XCTest
import NIO

@testable import Later

final class LaterTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        var bag = [EventLoopFuture<Void>]()
//        let later: Later<String> = Later()
//        XCTAssertEqual(later, "Hello, World!")
        print("System cores: \(System.coreCount)\n")
        let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        let ev = group.next()
        
    
        let promise = ev.promise { (promise) in
            sleep(6)
            print("PROMISE!")
            promise.succeed(())
        }
        
        promise.whenSuccess { page in
            print("Page received")
        }
        
        
        promise.whenFailure { error in
            print("Error: \(error)")
        }

        
        let result = ev.do(withDelay: 5) {
            print("Hello World!")
        }
        
        bag.append(result)
        
        print("First")
        
        ev.do {
            print("last?")
        }
        
        try! group.syncShutdownGracefully()
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}

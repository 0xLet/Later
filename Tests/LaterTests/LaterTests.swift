import XCTest
import NIO

@testable import Later

final class LaterTests: XCTestCase {
func testExample() {
    let sema = DispatchSemaphore(value: 0)
    
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
    
    var spam = true
    
    let result = ev.do(withDelay: 5) {
        spam = false
        print("Hello World!")
    }
    
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
    
    func testFetch() {
        let sema = DispatchSemaphore(value: 0)
        
        Later.do(withDelay: 2) {
            Later.fetch(url: URL(string: "https://avatars0.githubusercontent.com/u/10639145?s=200&v=4")!, work:  { (data, response, error) in
                print(data)
            })
        }
        
        var spam = true
        
        Later.do(withDelay: 5) {
            spam = false
            print("Hello World!")
            sema.signal()
        }
        
        print("First")
        
        Later.do {
            while spam {
                sleep(1)
                print("Spam!")
            }
        }
        
        print("FETCH")
        
        Later.fetch(url: URL(string: "https://avatars0.githubusercontent.com/u/8268288?s=460&u=2cb09673ea7f5230fa929b9b14a438cb2a65751c&v=4")!) { (data, response, error) in
            print(response)
        }
        

        sema.wait()
    }
    
    func testDo() {
        Later.do(withDelay: 2) {
            "Hello World"
        }
        .whenSuccess {
            print($0)
        }
        
        sleep(3)
        
        print("end")
    }
    
    func test100Do() {
        let sema = DispatchSemaphore(value: 0)
        
        var count = 0
        var maxCount = 0
        
        let start = Date().timeIntervalSince1970
        for i in 0 ..< 100 {
            if count > maxCount {
                maxCount = count
            }
            Later.do {
                count += 1
                sleep(3)
                count -= 1
                if i == 99 {
                    sema.signal()
                }
            }
        }
        sema.wait()
        let end = Date().timeIntervalSince1970
        
        print(maxCount)
        print(end - start)
    }
    
    func test1000Do() {
        let sema = DispatchSemaphore(value: 0)
        
        var count = 0
        var maxCount = 0
        
        let start = Date().timeIntervalSince1970
        for i in 0 ..< 1000 {
            if count > maxCount {
                maxCount = count
            }
            Later.do {
                count += 1
                sleep(3)
                count -= 1
                if i == 999 {
                    sema.signal()
                }
            }
        }
        sema.wait()
        let end = Date().timeIntervalSince1970
        
        print(maxCount)
        print(end - start) // 1000 / 80 * 3 ~= 37.5
    }
    
    static var allTests = [
        ("testExample", testExample),
        ("testFetch", testFetch),
        ("testDo", testDo)
    ]
}

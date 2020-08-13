import XCTest

@testable import Later

final class LaterTests: XCTestCase {
    func testLaterPromise_success() throws {
        let sema = DispatchSemaphore(value: 0)
        
        let promise = Later.promise { (promise) in
            sleep(5)
            promise.succeed(())
        }
        
        promise.whenSuccess { page in
            XCTAssert(true)
        }
        
        promise.whenFailure { error in
            XCTAssert(false)
        }
        
        promise.whenComplete { result in
            sema.signal()
        }
        
        sema.wait()
    }
    
    func testLaterPromise_failure() throws {
        let sema = DispatchSemaphore(value: 0)
        
        let promise = Later.promise { (promise) in
            sleep(5)
            promise.fail(NSError(domain: "Later", code: -1, userInfo: nil))
        }
        
        promise.whenSuccess { page in
            XCTAssert(false)
        }
        
        promise.whenFailure { error in
            XCTAssert(true)
        }
        
        promise.whenComplete { result in
            sema.signal()
        }
        
        sema.wait()
    }
    
    func testLaterDo_success() throws {
        let sema = DispatchSemaphore(value: 0)
        
        let result = Later.do(withDelay: 5) {
            print("Hello World!")
        }
        
        result.whenSuccess { _ in
            XCTAssert(true)
        }
        
        result.whenFailure { error in
            XCTAssert(false)
        }
        
        result.whenComplete { result in
            sema.signal()
        }
        
        sema.wait()
    }
    
    func testLaterDo_failure() throws {
        let sema = DispatchSemaphore(value: 0)
        
        let result = Later.do(withDelay: 5) {
            throw NSError(domain: "Later", code: -1, userInfo: nil)
        }
        
        result.whenSuccess { _ in
            XCTAssert(false)
        }
        
        result.whenFailure { error in
            XCTAssert(true)
        }
        
        result.whenComplete { result in
            sema.signal()
        }
        
        sema.wait()
    }
    
    func testFetch() {
        let sema = DispatchSemaphore(value: 0)
        
        let fetchRequest = Later.fetch(url: URL(string: "https://avatars0.githubusercontent.com/u/8268288?s=460&u=2cb09673ea7f5230fa929b9b14a438cb2a65751c&v=4")!)
        
        fetchRequest.whenSuccess { (data, response, error) in
            XCTAssert(true)
        }
        
        fetchRequest.whenFailure { (error) in
            XCTAssert(false)
        }
        
        fetchRequest.whenComplete { (result) in
            sema.signal()
        }
        
        sema.wait()
    }
    
    func testPost_success() {
        let sema = DispatchSemaphore(value: 0)
        
        Later.post(url: URL(string: "https://postman-echo.com/post")!) {
            "Some Data".data(using: .utf8)!
        }
        .when { (future) in
            future
                .whenFailure { (error) in
                    XCTAssert(false)
            }
            
            future
                .whenSuccess { (data, reponse) in
                    XCTAssert(true)
            }
            
            future.whenComplete { result in
                sema.signal()
            }
        }
        
        sema.wait()
    }
    
    func testPost_failure() {
        let sema = DispatchSemaphore(value: 0)
        
        Later.post(url: URL(string: "localhost")!)
            .when { (future) in
                future
                    .whenFailure { (error) in
                        XCTAssert(true)
                }
                
                future
                    .whenSuccess { (data, reponse) in
                        XCTAssert(false)
                }
                
                future.whenComplete { result in
                    sema.signal()
                }
        }
        
        sema.wait()
    }
    
    func testWhen() {
        let sema = DispatchSemaphore(value: 0)
        let correctOrder = [0, 1, 2, 3, 4, 5]
        var order: [Int] = []
        
        Later.do(withDelay: 3) {
            Later.fetch(url: URL(string: "https://github.com/0xLeif/Later")!)
                .when { event in
                    event
                        .whenSuccess { (data, response, error) in
                            order.append(5)
                            sema.signal()
                    }
            }
        }
        .when { event in
            event
                .whenComplete { _ in
                    order.append(4)
            }
        }
        .do(withDelay: 2) {
            order.append(2)
        }
        .when { event in
            event
                .whenSuccess { _ in
                    order.append(3)
            }
        }
        .do {
            order.append(0)
        }
        .and
        .do(withDelay: 1) {
            order.append(1)
        }
        
        sema.wait()
        XCTAssertEqual(order, correctOrder)
    }
    
    func testSchedule() {
        var count = 0
        let sema = DispatchSemaphore(value: 0)
        
        Later.scheduleRepeatedTask(initialDelay: .seconds(0),
                                   delay: .seconds(1)) { (task) in
                                    Later.do(withDelay: 4) {
                                        task.cancel()
                                        sema.signal()
                                    }
                                    count += 1
        }
        Later.scheduleTask(in: .seconds(3)) {
            count += 1
        }
        sema.wait()
        
        XCTAssertEqual(count, 5)
    }
    
    static var allTests = [
        ("testLaterPromise_success", testLaterPromise_success),
        ("testLaterPromise_failure", testLaterPromise_failure),
        ("testLaterDo_success", testLaterDo_success),
        ("testLaterDo_failure", testLaterDo_failure),
        ("testFetch", testFetch),
        ("testPost_success", testPost_success),
        ("testPost_failure", testPost_failure),
        ("testWhen", testWhen),
        ("testSchedule", testSchedule)
    ]
}

//
//  EventLoopTests.swift
//  LaterTests
//
//  Created by CRi on 8/13/20.
//

import XCTest
import NIO

class EventLoopTests: XCTestCase {
    var group: EventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    var ev: EventLoop {
        group.next()
    }
    
    override func setUp() {
        group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    }
    
    override func tearDown() {
        try! group.syncShutdownGracefully()
    }
    
    func testEVPromise_success() throws {
        let sema = DispatchSemaphore(value: 0)
        
        let promise = ev.promise { (promise) in
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
    
    func testEVPromise_failure() throws {
        let sema = DispatchSemaphore(value: 0)
        
        let promise = ev.promise { (promise) in
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
    
    func testEVDo_success() throws {
        let sema = DispatchSemaphore(value: 0)
        
        let result = ev.do(withDelay: 5) {
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
    
    func testEVDo_failure() throws {
        let sema = DispatchSemaphore(value: 0)
        
        let result = ev.do(withDelay: 5) {
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
    
    static var allTests = [
        ("testEVPromise_success", testEVPromise_success),
        ("testEVPromise_failure", testEVPromise_failure),
        ("testEVDo_success", testEVDo_success),
        ("testEVDo_failure", testEVDo_failure)
    ]
}

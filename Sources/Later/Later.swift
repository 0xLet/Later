import Foundation
import NIO

// MARK: typealiases

public typealias LaterValue = EventLoopFuture
public typealias LaterPromise = EventLoopPromise

// MARK: LaterValue

public extension LaterValue {
    var and: Later.Type {
        Later.self
    }
    
    @discardableResult
    func when(value: @escaping (LaterValue<Value>) -> Void) -> Later.Type {
        let _ = whenComplete { _ in
            value(self)
        }
        
        return Later.self
    }
}

// MARK: Later

public class Later {
    deinit {
        do {
            try group.syncShutdownGracefully()
        } catch {
            print("Later: \(error.localizedDescription)")
        }
    }
    
    private static var `default`: Later = Later()
    
    private let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    private var ev: EventLoop {
        group.next()
    }
}

// MARK: promise

public extension Later {
    @discardableResult
    static func promise<T>(work: @escaping (LaterPromise<T>) -> Void) -> LaterValue<T> {
        Later.default.ev
            .promise(work: work)
    }
    
    @discardableResult
    static func promise(work: @escaping (LaterPromise<Void>) -> Void) -> LaterValue<Void> {
        Later.default.ev
            .promise(work: work)
    }
}

// MARK: do

public extension Later {
    @discardableResult
    static func `do`<T>(withDelay delay: UInt32 = 0,
                        work: @escaping () -> T) -> LaterValue<T> {
        Later.default.ev
            .do(withDelay: delay,
                work: work)
    }
    
    @discardableResult
    static func `do`(withDelay delay: UInt32 = 0,
                     work: @escaping () -> Void) -> LaterValue<Void> {
        Later.default.ev
            .do(withDelay: delay,
                work: work)
    }
    
}

// MARK: main

public extension Later {
    @discardableResult
    static func main(withDelay delay: UInt32 = 0,
                     work: @escaping () -> Void) -> LaterValue<Void> {
        Later.do(withDelay: delay) {
            DispatchQueue.main.async {
                work()
            }
        }
    }
}


// MARK: schedule

public extension Later {
    @discardableResult
    static func schedule(withInitialDelay initialDelay: TimeAmount = TimeAmount.seconds(0),
                         delay: TimeAmount = TimeAmount.seconds(0),
                         work: @escaping (RepeatedTask) -> Void) -> RepeatedTask {
        Later.default.ev
            .scheduleRepeatedTask(initialDelay: initialDelay,
                                  delay: delay) { (task) in
                                    work(task)
        }
    }
}

// MARK: post

public extension Later {
    static func post(url: URL, withData data: () -> Data) -> LaterValue<(Data?, URLResponse?, Error?)> {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = data()
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json; charset=utf-8"
        ]
        
        return Later.default.ev.promise { promise in
            URLSession.shared
                .dataTask(with: request) { (data, response, error) in
                    promise.succeed((data, response, error))
            }
            .resume()
        }
    }
}

// MARK: fetch

public extension Later {
    @discardableResult
    static func fetch(url: URL) -> LaterValue<(Data?, URLResponse?, Error?)> {
        Later.default.ev
            .promise { promise in
                URLSession.shared
                    .dataTask(with: url) { (data, response, error) in
                        promise.succeed((data, response, error))
                }
                .resume()
        }
    }
    
    @discardableResult
    static func fetch(url: URL,
                      work: @escaping (Data?, URLResponse?, Error?) -> Void) -> LaterValue<Void> {
        Later.default.ev
            .do {
                URLSession.shared
                    .dataTask(with: url,
                              completionHandler: work)
                    .resume()
        }
    }
    
    @discardableResult
    static func fetch(url: URL,
                      errorHandler: ((Error) -> Void)? = nil,
                      responseHandler: ((URLResponse) -> Void)? = nil,
                      dataHandler: ((Data) -> Void)? = nil) -> LaterValue<Void> {
        fetch(url: url) { (data, response, error) in
            if let error = error {
                errorHandler?(error)
            }
            
            guard let response = response else {
                return
            }
            
            responseHandler?(response)
            
            guard let data = data else {
                return
            }
            
            dataHandler?(data)
        }
    }
}

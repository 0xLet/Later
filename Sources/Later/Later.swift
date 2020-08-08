import Foundation
import NIO

public typealias LaterValue = EventLoopFuture
public typealias LaterPromise = EventLoopPromise

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

public class Later {
    fileprivate static var `default`: Later = Later()
    
    private let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    private lazy var ev = group.next()
}

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

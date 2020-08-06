import Foundation
import NIO

public typealias LaterValue = EventLoopFuture
public typealias LaterPromise = EventLoopPromise

public class Later {
    fileprivate static var `default`: Later = Later()
    
    private let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    private lazy var ev = group.next()
}

public extension Later {
    static func fetch(url: URL,
               work: @escaping (Data?, URLResponse?, Error?) -> Void) -> LaterValue<Void> {
        Later.default.ev.do {
            URLSession.shared.dataTask(with: url, completionHandler: work).resume()
        }
    }
    
    static func `do`(withDelay delay: UInt32 = 0,
              work: @escaping () -> Void) -> LaterValue<Void> {
        Later.default.ev.do(withDelay: delay,
              work: work)
    }
    
    static func promise<T>(work: @escaping (LaterPromise<T>) -> Void) -> LaterValue<T> {
        Later.default.ev.promise(work: work)
    }
    
    static func promise(work: @escaping (LaterPromise<Void>) -> Void) -> LaterValue<Void> {
        Later.default.ev.promise(work: work)
    }
}

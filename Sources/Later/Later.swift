import NIO
import Foundation

public class Later {
    private let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    private lazy var ev = group.next()
    
    public static var `default`: Later = Later()
}

public extension Later {
    func `do`(withDelay delay: UInt32 = 0,
              work: @escaping () -> Void) -> EventLoopFuture<Void> {
        ev.do(withDelay: delay,
              work: work)
    }
    
    func promise<T>(work: @escaping (EventLoopPromise<T>) -> Void) -> EventLoopFuture<T> {
        ev.promise(work: work)
    }
    
    func promise(work: @escaping (EventLoopPromise<Void>) -> Void) -> EventLoopFuture<Void> {
        ev.promise(work: work)
    }
}

public extension EventLoop {
    func `do`(withDelay delay: UInt32 = 0,
              work: @escaping () -> Void) -> EventLoopFuture<Void> {
        
        let promise = submit {
            sleep(delay)
            work()
            return
        }
        
        return promise
    }
    
    func promise<T>(work: @escaping (EventLoopPromise<T>) -> Void) -> EventLoopFuture<T> {
        let promise = makePromise(of: T.self)
        
        
        DispatchQueue.global().async {
            work(promise)
        }
        
        return promise.futureResult
    }
    
    func promise(work: @escaping (EventLoopPromise<Void>) -> Void) -> EventLoopFuture<Void> {
        let promise = makePromise(of: Void.self)
        
        DispatchQueue.global().async {
            let _ = work(promise)
        }
        
        return promise.futureResult
    }
}

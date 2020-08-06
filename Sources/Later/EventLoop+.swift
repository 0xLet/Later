import Foundation
import NIO

public extension EventLoop {
    func `do`(withDelay delay: UInt32 = 0,
              work: @escaping () -> Void) -> EventLoopFuture<Void> {
        
        let promise = submit {
            DispatchQueue.global().async {
                sleep(delay)
                work()
            }
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

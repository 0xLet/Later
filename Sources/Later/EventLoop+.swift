import Foundation
import NIO

public extension EventLoop {
    @discardableResult
    func `do`<T>(withDelay delay: UInt32 = 0,
              work: @escaping () -> T) -> EventLoopFuture<T> {
        promise { (promise) in
            DispatchQueue.global().async {
                sleep(delay)
                let data = work()
                promise.succeed(data)
            }
        }
    }
    
    @discardableResult
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
    
    @discardableResult
    func promise<T>(work: @escaping (EventLoopPromise<T>) -> Void) -> EventLoopFuture<T> {
        let promise = makePromise(of: T.self)
        
        
        DispatchQueue.global().async {
            work(promise)
        }
        
        return promise.futureResult
    }
    
    @discardableResult
    func promise(work: @escaping (EventLoopPromise<Void>) -> Void) -> EventLoopFuture<Void> {
        let promise = makePromise(of: Void.self)
        
        DispatchQueue.global().async {
            let _ = work(promise)
        }
        
        return promise.futureResult
    }
}

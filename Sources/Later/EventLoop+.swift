import Foundation
import NIO

public extension EventLoop {
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
    
    @discardableResult
    func `do`<T>(withDelay delay: UInt32 = 0,
              work: @escaping () throws -> T) -> EventLoopFuture<T> {
        promise { promise in
            DispatchQueue.global().async {
                sleep(delay)
                do {
                    let data = try work()
                    promise.succeed(data)
                } catch {
                    promise.fail(error)
                }
            }
        }
    }
    
    @discardableResult
    func `do`(withDelay delay: UInt32 = 0,
              work: @escaping () throws -> Void) -> EventLoopFuture<Void> {
        promise { promise in
            DispatchQueue.global().async {
                sleep(delay)
                do {
                    try work()
                    promise.succeed(())
                } catch {
                    promise.fail(error)
                }
            }
        }
    }
}

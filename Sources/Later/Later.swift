import NIO

public class Later {
    public static var `default`: Later = Later()
    
    private var futures: [EventLoopFuture<Any>] = []
    
    public func store(future: EventLoopFuture<Any>) {
        futures.append(future)
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
        
        work(promise)
        
        return promise.futureResult
    }
    
    func promise<Void>(work: @escaping (EventLoopPromise<Void>) -> Void) -> EventLoopFuture<Void> {
        let promise = makePromise(of: Void.self)
        
        work(promise)
        
        return promise.futureResult
    }
}
 

public extension EventLoopFuture {
    func store() {
//        Later.default.store(future: self)
    }
}

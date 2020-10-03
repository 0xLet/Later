public class Contract<Value> {
    public enum ContractError: Error {
        case resigned
    }
    
    private var isValid = true
    private var promise: LaterPromise<Value?>?
    
    private var onResign: ((Value?) -> Void)?
    private var onChange: ((Value?) -> Void)?
    
    public var value: Value? {
        didSet {
            promise?.succeed(value)
        }
    }
    
    public init(initialValue: Value? = nil,
                onResignHandler: ((Value?) -> Void)? = nil,
                onChangeHandler: ((Value?) -> Void)? = nil) {
        onResign = onResignHandler
        onChange = onChangeHandler
        value = initialValue
        start()
        promise?.succeed(value)
    }
    
    @discardableResult
    public func onChange(onChangeHandler: ((Value?) -> Void)? = nil) -> Self {
        onChange = onChangeHandler
        onChange?(value)
        
        return self
    }
    
    @discardableResult
    public func onResign(onResignHandler: ((Value?) -> Void)? = nil) -> Self {
        onResign = onResignHandler
        
        return self
    }
    
    public func resign() {
        guard isValid else {
            return
        }
        
        isValid = false
        
        onResign?(value)
        promise?.fail(ContractError.resigned)
        
        promise = nil
        onChange = nil
        value = nil
    }
    
    private func start() {
        guard isValid else {
            return
        }
        
        Later.promise { (promise) in
            self.promise = promise
        }
        .whenSuccess { [weak self] (value) in
            self?.onChange?(value)
            self?.start()
        }
    }
}

import XCTest

@testable import Later

class ContractTests: XCTestCase {
    func testContractInitialValue() {
        let sema = DispatchSemaphore(value: 0)
        let contract = Contract(initialValue: "Hello, World!")
        
        sleep(1)
        
        contract.onChange { value in
            XCTAssertEqual(value, "Hello, World!")
            sema.signal()
        }
        .onResign { lastValue in
            XCTAssertEqual(lastValue, "Hello, World!")
        }
        
        sema.wait()
        
        contract.resign()
        
        XCTAssertNil(contract.value)
    }
    
    func testContractCount() {
        let sema = DispatchSemaphore(value: 0)
        var count = 0
        let contract = Contract(initialValue: "Hello, World!", onChangeHandler:  { _ in
            print("\tCount: \(count)")
            
            if count >= 8 {
                sema.signal()
                return
            }
            
            count += 2
        })
        
        let task = Later.scheduleRepeatedTask(initialDelay: .seconds(3), delay: .milliseconds(100)) { (task) in
            contract.value = "Some Value"
        }
        
        contract.onResign { lastValue in
            XCTAssertEqual(lastValue, "Some Value")
            task.cancel()
        }
        
        sema.wait()
        
        contract.resign()
        
        XCTAssertNil(contract.value)
        XCTAssertEqual(count, 8)
    }
    
    func testContractContract() {
        let sema = DispatchSemaphore(value: 0)
        let countContract = Contract(initialValue: 0, onChangeHandler:  { (value) in
            print("New Value: \(value ?? -1)")
            XCTAssert(((value?.isMultiple(of: 2)) != nil))
        })
        let contract = Contract(initialValue: "Hello, World!", onChangeHandler:  { _ in
            print("\tCount: \(countContract.value ?? -1)")
            
            if (countContract.value ?? -1) >= 16 {
                sema.signal()
                return
            }
            
            countContract.value! += 2
        })
        
        let task = Later.scheduleRepeatedTask(delay: .milliseconds(100)) { (task) in
            contract.value = "Some Value"
        }
        
        countContract.onResign { lastValue in
            task.cancel()
            XCTAssertEqual(lastValue, 16)
        }
        
        contract.onResign { lastValue in
            countContract.resign()
            XCTAssertEqual(lastValue, "Some Value")
        }
        
        sema.wait()
        
        contract.resign()
        
        XCTAssertNil(countContract.value)
        XCTAssertNil(contract.value)
    }
    
    static var allTests = [
        ("testContractCount", testContractCount),
        ("testContractContract", testContractContract)
    ]
}

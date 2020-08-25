import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(LaterTests.allTests),
        testCase(EventLoopTests.allTests),
        testCase(ContractTests.allTests)
    ]
}
#endif

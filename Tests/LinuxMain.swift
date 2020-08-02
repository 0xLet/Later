import XCTest

import LaterTests

var tests = [XCTestCaseEntry]()
tests += LaterTests.allTests()
XCTMain(tests)

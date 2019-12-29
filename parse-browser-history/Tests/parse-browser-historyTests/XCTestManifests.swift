import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(parse_browser_historyTests.allTests),
    ]
}
#endif

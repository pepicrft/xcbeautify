// Information about the JUNIT Schema/specification used in this file can be found here:
// * https://stackoverflow.com/a/9410271
// * https://github.com/bazelbuild/bazel/blob/45092bb122b840e3410845522df9fe89c59db465/src/java_tools/junitrunner/java/com/google/testing/junit/runner/model/AntXmlResultWriter.java#L29
// * http://windyroad.com.au/dl/Open%20Source/JUnit.xsd

#if compiler(>=6.0)
package import Foundation
#else
import Foundation
#endif
import XMLCoder

package final class JunitReporter {
    private var components: [JunitComponent] = []
    // Parallel output does not guarantee order - so it is _very_ hard
    // to match to the parent suite. We can still capture test success/failure
    // and output a generic result file.
    private var parallelComponents: [JunitComponent] = []

    package init() { }

    // TODO: Delete `line` parameter
    package func add(captureGroup: any CaptureGroup, line: String) {
        switch captureGroup {
        case let group as FailingTestCaptureGroup:
            guard let testCase = generateFailingTest(group: group) else { return }
            components.append(.failingTest(testCase))
        case let group as RestartingTestCaptureGroup:
            guard let testCase = generateRestartingTest(group: group, line: line) else { return }
            components.append(.failingTest(testCase))
        case let group as TestCasePassedCaptureGroup:
            guard let testCase = generatePassingTest(group: group) else { return }
            components.append(.testCasePassed(testCase))
        case let group as TestCaseSkippedCaptureGroup:
            guard let testCase = generateSkippedTest(group: group) else { return }
            components.append(.skippedTest(testCase))
        case let group as TestSuiteStartCaptureGroup:
            guard let testStart = generateSuiteStart(group: group) else { return }
            components.append(.testSuiteStart(testStart))
        case let group as ParallelTestCaseFailedCaptureGroup:
            guard let testCase = generateParallelFailingTest(group: group) else { return }
            parallelComponents.append(.failingTest(testCase))
        case let group as ParallelTestCasePassedCaptureGroup:
            guard let testCase = generatePassingParallelTest(group: group) else { return }
            parallelComponents.append(.testCasePassed(testCase))
        case let group as ParallelTestCaseSkippedCaptureGroup:
            guard let testCase = generateSkippedParallelTest(group: group) else { return }
            parallelComponents.append(.testCasePassed(testCase))
        default:
            return
        }
    }

    private func generateFailingTest(group: FailingTestCaptureGroup) -> TestCase? {
        TestCase(classname: group.testSuite, name: group.testCase, time: nil, failure: .init(message: "\(group.file) - \(group.reason)"))
    }

    // TODO: Delete `line` parameter
    private func generateRestartingTest(group: RestartingTestCaptureGroup, line: String) -> TestCase? {
        TestCase(classname: group.testSuite, name: group.testCase, time: nil, failure: .init(message: line))
    }

    private func generateParallelFailingTest(group: ParallelTestCaseFailedCaptureGroup) -> TestCase? {
        // Parallel tests do not provide meaningful failure messages
        TestCase(classname: group.suite, name: group.testCase, time: nil, failure: .init(message: "Parallel test failed"))
    }

    private func generatePassingTest(group: TestCasePassedCaptureGroup) -> TestCase? {
        TestCase(classname: group.suite, name: group.testCase, time: group.time)
    }

    private func generateSkippedTest(group: TestCaseSkippedCaptureGroup) -> TestCase? {
        TestCase(classname: group.suite, name: group.testCase, time: group.time, skipped: .init(message: nil))
    }

    private func generatePassingParallelTest(group: ParallelTestCasePassedCaptureGroup) -> TestCase? {
        TestCase(classname: group.suite, name: group.testCase, time: group.time)
    }

    private func generateSkippedParallelTest(group: ParallelTestCaseSkippedCaptureGroup) -> TestCase? {
        TestCase(classname: group.suite, name: group.testCase, time: group.time, skipped: .init(message: nil))
    }

    private func generateSuiteStart(group: TestSuiteStartCaptureGroup) -> String? {
        group.testSuiteName
    }

    package func generateReport() throws -> Data {
        let parser = JunitComponentParser()
        for item in components {
            parser.parse(component: item)
        }
        // Prefix a fake test suite start for the parallel tests.
        parallelComponents.insert(.testSuiteStart("PARALLEL_TESTS"), at: 0)
        for parallelComponent in parallelComponents {
            parser.parse(component: parallelComponent)
        }
        let encoder = XMLEncoder()
        encoder.keyEncodingStrategy = .lowercased
        encoder.outputFormatting = [.prettyPrinted]
        let result = parser.result()
        return try encoder.encode(result)
    }
}

private final class JunitComponentParser {
    private var mainTestSuiteName: String?
    private var testCases: [TestCase] = []

    func parse(component: JunitComponent) {
        switch component {
        case let .testSuiteStart(suiteName):
            guard mainTestSuiteName == nil else {
                break
            }
            mainTestSuiteName = suiteName

        case let .failingTest(testCase),
             let .testCasePassed(testCase),
             let .skippedTest(testCase):
            testCases.append(testCase)
        }
    }

    func result() -> Testsuites {
        var testSuites: [Testsuite] = []
        for testCase in testCases {
            let index: Int
            if let existingTestSuiteIndex = testSuites.firstIndex(where: { $0.name == testCase.classname }) {
                index = existingTestSuiteIndex
            } else {
                let newTestSuite = Testsuite(name: testCase.classname, testcases: [])
                testSuites.append(newTestSuite)
                index = testSuites.count - 1
            }
            var testSuite = testSuites[index]
            testSuite.testcases.append(testCase)
            testSuites[index] = testSuite
        }
        let container = Testsuites(name: mainTestSuiteName, testsuites: testSuites)
        return container
    }
}

private enum JunitComponent {
    case testSuiteStart(String)
    case failingTest(TestCase)
    case testCasePassed(TestCase)
    case skippedTest(TestCase)
}

private struct Testsuites: Encodable, DynamicNodeEncoding {
    var name: String?
    var testsuites: [Testsuite] = []

    enum CodingKeys: String, CodingKey {
        case name
        case tests
        case failures
        case testsuites = "testsuite"
    }

    static func nodeEncoding(for key: any CodingKey) -> XMLEncoder.NodeEncoding {
        let key = CodingKeys(stringValue: key.stringValue)!
        switch key {
        case .name, .tests, .failures:
            return .attribute

        case .testsuites:
            return .element
        }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(testsuites.reduce(into: 0) { $0 += $1.testcases.count }, forKey: .tests)
        try container.encode(testsuites.reduce(into: 0) { $0 += $1.testcases.filter { $0.failure != nil }.count }, forKey: .failures)
        try container.encode(testsuites, forKey: .testsuites)
    }
}

private struct Testsuite: Encodable, DynamicNodeEncoding {
    let name: String
    var testcases: [TestCase]

    enum CodingKeys: String, CodingKey {
        case name
        case tests
        case failures
        case testcases = "testcase"
    }

    static func nodeEncoding(for key: any CodingKey) -> XMLEncoder.NodeEncoding {
        let key = CodingKeys(stringValue: key.stringValue)!
        switch key {
        case .name, .tests, .failures:
            return .attribute

        case .testcases:
            return .element
        }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(testcases.count, forKey: .tests)
        try container.encode(testcases.filter { $0.failure != nil }.count, forKey: .failures)
        try container.encode(testcases, forKey: .testcases)
    }
}

private struct TestCase: Codable, DynamicNodeEncoding {
    let classname: String
    let name: String
    let time: String?
    let failure: Failure?
    let skipped: Skipped?

    init(classname: String, name: String, time: String?, failure: Failure? = nil, skipped: Skipped? = nil) {
        self.classname = classname
        self.name = name
        self.time = time
        self.failure = failure
        self.skipped = skipped
    }

    static func nodeEncoding(for key: any CodingKey) -> XMLEncoder.NodeEncoding {
        let key = CodingKeys(stringValue: key.stringValue)!
        switch key {
        case .classname, .name, .time:
            return .attribute

        case .failure, .skipped:
            return .element
        }
    }
}

private extension TestCase {
    struct Failure: Codable, DynamicNodeEncoding {
        let message: String

        static func nodeEncoding(for key: any CodingKey) -> XMLEncoder.NodeEncoding {
            let key = CodingKeys(stringValue: key.stringValue)!
            switch key {
            case .message:
                return .attribute
            }
        }
    }

    struct Skipped: Codable, DynamicNodeEncoding {
        let message: String?

        static func nodeEncoding(for key: any CodingKey) -> XMLEncoder.NodeEncoding {
            let key = CodingKeys(stringValue: key.stringValue)!
            switch key {
            case .message:
                return .attribute
            }
        }
    }
}

import Foundation

package protocol CaptureGroup {
    static var outputType: OutputType { get }
    static var regex: XCRegex { get }
    init?(groups: [String])
}

package extension CaptureGroup {
    var outputType: OutputType { Self.outputType }
}

protocol ErrorCaptureGroup: CaptureGroup {
    var wholeError: String { get }
}

protocol TargetCaptureGroup: CaptureGroup {
    var target: String { get }
    var project: String { get }
    var configuration: String { get }
}

protocol CompileFileCaptureGroup: CaptureGroup {
    var filename: String { get }
    var target: String { get }
}

protocol CopyCaptureGroup: CaptureGroup {
    var file: String { get }
    var target: String { get }
}

protocol ExecutedCaptureGroup: CaptureGroup {
    var numberOfTests: Int { get }
    var numberOfSkipped: Int { get }
    var numberOfFailures: Int { get }
    var numberOfUnexpectedFailures: Int { get }
    var wallClockTimeInSeconds: Double { get }
}

struct AnalyzeCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    /// Regular expression captured groups:
    /// $1 = file path
    /// $2 = filename
    static let regex = XCRegex(pattern: #"^Analyze(?:Shallow)?\s(.*\/(.*\.(?:m|mm|cc|cpp|c|cxx)))\s.*\((in target: (.*)|in target '(.*)' from project '.*')\)"#)

    let filePath: String
    let filename: String
    let target: String

    init?(groups: [String]) {
        assert(groups.count >= 3)
        guard let filePath = groups[safe: 0], let filename = groups[safe: 1], let target = groups.last else { return nil }
        self.filePath = filePath
        self.filename = filename
        self.target = target
    }
}

struct BuildTargetCaptureGroup: TargetCaptureGroup {
    static let outputType: OutputType = .task

    /// Regular expression captured groups:
    /// $1 = target
    /// $2 = project
    /// $3 = configuration
    static let regex = XCRegex(pattern: #"^=== BUILD TARGET\s(.*)\sOF PROJECT\s(.*)\sWITH.*CONFIGURATION\s(.*)\s==="#)

    let target: String
    let project: String
    let configuration: String

    init?(groups: [String]) {
        assert(groups.count >= 3)
        guard let target = groups[safe: 0], let project = groups[safe: 1], let configuration = groups[safe: 2] else { return nil }
        self.target = target
        self.project = project
        self.configuration = configuration
    }
}

struct AggregateTargetCaptureGroup: TargetCaptureGroup {
    static let outputType: OutputType = .task

    /// Regular expression captured groups:
    /// $1 = target
    /// $2 = project
    /// $3 = configuration
    static let regex = XCRegex(pattern: #"^=== BUILD AGGREGATE TARGET\s(.*)\sOF PROJECT\s(.*)\sWITH.*CONFIGURATION\s(.*)\s==="#)

    let target: String
    let project: String
    let configuration: String

    init?(groups: [String]) {
        assert(groups.count >= 3)
        guard let target = groups[safe: 0], let project = groups[safe: 1], let configuration = groups[safe: 2] else { return nil }
        self.target = target
        self.project = project
        self.configuration = configuration
    }
}

struct AnalyzeTargetCaptureGroup: TargetCaptureGroup {
    static let outputType: OutputType = .task

    /// Regular expression captured groups:
    /// $1 = target
    /// $2 = project
    /// $3 = configuration
    static let regex = XCRegex(pattern: #"^=== ANALYZE TARGET\s(.*)\sOF PROJECT\s(.*)\sWITH.*CONFIGURATION\s(.*)\s==="#)

    let target: String
    let project: String
    let configuration: String

    init?(groups: [String]) {
        assert(groups.count >= 3)
        guard let target = groups[safe: 0], let project = groups[safe: 1], let configuration = groups[safe: 2] else { return nil }
        self.target = target
        self.project = project
        self.configuration = configuration
    }
}

/// Nothing returned here for now
struct CheckDependenciesCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task
    static let regex = XCRegex(pattern: #"^Check dependencies"#)

    private init() { }

    init?(groups: [String]) {
        assert(groups.count >= 0)
        self.init()
    }
}

struct ShellCommandCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    /// Regular expression captured groups:
    /// $1 = command path
    /// $2 = arguments
    static let regex = XCRegex(pattern: #"^\s{4}(cd|setenv|(?:[\w\/:\s\-.]+?\/)?[\w\-]+)\s(.*)$"#)

    let commandPath: String
    let arguments: String

    init?(groups: [String]) {
        assert(groups.count >= 2)
        guard let commandPath = groups[safe: 0], let arguments = groups[safe: 1] else { return nil }
        self.commandPath = commandPath
        self.arguments = arguments
    }
}

// FIXME: Refactor this type.
// Added to temporarily capture unwanted clang output.
// This type's regex conflicts with ShellCommandCaptureGroup and ProcessPchCommandCaptureGroup.
struct NonPCHClangCommandCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    static let regex = XCRegex(pattern: #"^\s{0,4}(.*\/usr\/bin\/clang) (?:(?!(?:pch)).)*$"#)

    let xcodePath: String

    init?(groups: [String]) {
        assert(groups.count == 1)
        guard let xcodePath = groups[safe: 0] else { return nil }
        self.xcodePath = xcodePath
    }
}

struct CleanRemoveCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    /// Nothing returned here for now
    static let regex = XCRegex(pattern: #"^Clean.Remove(.*)"#)

    let directory: String

    init?(groups: [String]) {
        assert(groups.count >= 1)
        guard let directory = groups[safe: 0] else { return nil }
        self.directory = directory.lastPathComponent
    }
}

struct CleanTargetCaptureGroup: TargetCaptureGroup {
    static let outputType: OutputType = .task

    /// Regular expression captured groups:
    /// $1 = target
    /// $2 = project
    /// $3 = configuration
    static let regex = XCRegex(pattern: #"^=== CLEAN TARGET\s(.*)\sOF PROJECT\s(.*)\sWITH CONFIGURATION\s(.*)\s==="#)

    let target: String
    let project: String
    let configuration: String

    init?(groups: [String]) {
        assert(groups.count >= 3)
        guard let target = groups[safe: 0], let project = groups[safe: 1], let configuration = groups[safe: 2] else { return nil }
        self.target = target
        self.project = project
        self.configuration = configuration
    }
}

struct CodesignCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    /// Regular expression captured groups:
    /// $1 = file
    static let regex = XCRegex(pattern: #"^CodeSign\s(((?!.framework/Versions/A)(?:\ |[^ ]))*?)( \(in target '.*' from project '.*' at path '.*'\))?$"#)

    let file: String

    init?(groups: [String]) {
        assert(groups.count >= 1)
        guard let file = groups[safe: 0] else { return nil }
        self.file = file
    }
}

struct CodesignFrameworkCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    /// Regular expression captured groups:
    /// $1 = file
    static let regex = XCRegex(pattern: #"^CodeSign\s((?:\ |[^ ])*.framework)\/Versions/A"#)

    let frameworkPath: String

    init?(groups: [String]) {
        assert(groups.count >= 1)
        guard let frameworkPath = groups[safe: 0] else { return nil }
        self.frameworkPath = frameworkPath
    }
}

struct CompileCaptureGroup: CompileFileCaptureGroup {
    static let outputType: OutputType = .task

    #if os(Linux)
    /// Regular expression captured groups:
    /// $1 = filename (e.g. KWNull.m)
    /// $2 = target
    static let regex = XCRegex(pattern: #"^\[\d+\/\d+\]\sCompiling\s([^ ]+)\s([^ \.]+\.(?:m|mm|c|cc|cpp|cxx|swift))"#)
    #else
    /// Regular expression captured groups:
    /// $1 = file path
    /// $2 = filename (e.g. KWNull.m)
    /// $3 = target
    static let regex = XCRegex(pattern: #"^Compile[\w]+\s.+?\s((?:\.|[^ ])+\/((?:\.|[^ ])+\.(?:m|mm|c|cc|cpp|cxx|swift)))\s.*\((in target: (.*)|in target '(.*)' from project '.*')\)"#)
    #endif

    #if !os(Linux)
    let filePath: String
    #endif
    let filename: String
    let target: String

    init?(groups: [String]) {
        #if os(Linux)
        assert(groups.count >= 2)
        guard let filename = groups[safe: 1], let target = groups.last else { return nil }
        self.filename = filename
        self.target = target
        #else
        assert(groups.count >= 3)
        guard let filePath = groups[safe: 0], let filename = groups[safe: 1], let target = groups.last else { return nil }
        self.filePath = filePath
        self.filename = filename
        self.target = target
        #endif
    }
}

struct SwiftCompileCaptureGroup: CompileFileCaptureGroup {
    static let outputType: OutputType = .task

    /// Regular expression captured groups:
    /// $1 = file path
    /// $2 = target
    /// $3 = project
    static let regex = XCRegex(pattern: #"^SwiftCompile \w+ \w+ ((?:\S|(?<=\\) )+) \(in target '(.*)' from project '(.*)'\)$"#)

    let filePath: String
    let filename: String
    let target: String
    let project: String

    init?(groups: [String]) {
        assert(groups.count == 3)
        guard let filePath = groups[safe: 0], let target = groups[safe: 1], let project = groups[safe: 2] else { return nil }
        self.filePath = filePath
        filename = filePath.lastPathComponent
        self.target = target
        self.project = project
    }
}

struct SwiftCompilingCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    static let regex = XCRegex(pattern: #"^SwiftCompile \w+ \w+ Compiling\\"#)

    init?(groups: [String]) { }
}

struct CompileCommandCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    /// Regular expression captured groups:
    /// $1 = compiler command
    /// $2 = file path
    static let regex = XCRegex(pattern: #"^\s*(.*clang\s.*\s\-c\s(.*\.(?:m|mm|c|cc|cpp|cxx))\s.*\.o)$"#)

    let compilerCommand: String
    let filePath: String

    init?(groups: [String]) {
        assert(groups.count >= 2)
        guard let compilerCommand = groups[safe: 0], let filePath = groups[safe: 1] else { return nil }
        self.compilerCommand = compilerCommand
        self.filePath = filePath
    }
}

struct CompileXCStringsCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    static let regex = XCRegex(pattern: #"^CompileXCStrings (.+) \(in target '(.+)' from project '(.+)'\)$"#)

    let filePath: String
    let filename: String
    let target: String
    let project: String

    init?(groups: [String]) {
        assert(groups.count == 3)
        guard let filePath = groups[safe: 0], let target = groups[safe: 1], let project = groups[safe: 2] else { return nil }
        self.filePath = filePath
        filename = filePath.lastPathComponent
        self.target = target
        self.project = project
    }
}

struct CompileXibCaptureGroup: CompileFileCaptureGroup {
    static let outputType: OutputType = .task

    /// Regular expression captured groups:
    /// $1 = file path
    /// $2 = filename (e.g. MainMenu.xib)
    /// $3 = target
    static let regex = XCRegex(pattern: #"^CompileXIB\s(.*\/(.*\.xib))\s.*\((in target: (.*)|in target '(.*)' from project '.*')\)"#)

    let filePath: String
    let filename: String
    let target: String

    init?(groups: [String]) {
        assert(groups.count >= 3)
        guard let filePath = groups[safe: 0], let filename = groups[safe: 1], let target = groups.last else { return nil }
        self.filePath = filePath
        self.filename = filename
        self.target = target
    }
}

struct CompileStoryboardCaptureGroup: CompileFileCaptureGroup {
    static let outputType: OutputType = .task

    /// Regular expression captured groups:
    /// $1 = file path
    /// $2 = filename (e.g. Main.storyboard)
    /// $3 = target
    static let regex = XCRegex(pattern: #"^CompileStoryboard\s(.*\/([^\/].*\.storyboard))\s.*\((in target: (.*)|in target '(.*)' from project '.*')\)"#)

    let filePath: String
    let filename: String
    let target: String

    init?(groups: [String]) {
        assert(groups.count >= 3)
        guard let filePath = groups[safe: 0], let filename = groups[safe: 1], let target = groups.last else { return nil }
        self.filePath = filePath
        self.filename = filename
        self.target = target
    }
}

struct CopyFilesCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    // ((?:\S|(?<=\\) )+) --> Match any non-whitespace character OR any escaped space (space in filename)
    static let regex = XCRegex(pattern: #"^Copy ((?:\S|(?<=\\) )+) ((?:\S|(?<=\\) )+) \(in target '(.*)' from project '.*'\)$"#)

    let firstFilePath: String
    let firstFilename: String
    let secondFilePath: String
    let secondFilename: String
    let target: String

    init?(groups: [String]) {
        assert(groups.count == 3)
        guard let firstFilePath = groups[safe: 0], let secondFilePath = groups[safe: 1], let target = groups[safe: 2] else { return nil }
        self.firstFilePath = firstFilePath
        firstFilename = firstFilePath.lastPathComponent
        self.secondFilePath = secondFilePath
        secondFilename = secondFilePath.lastPathComponent
        self.target = target
    }
}

struct CopyHeaderCaptureGroup: CopyCaptureGroup {
    static let outputType: OutputType = .task

    /// Regular expression captured groups:
    /// $1 = source file
    /// $2 = target file
    /// $3 = target
    static let regex = XCRegex(pattern: #"^CpHeader\s(.*\.h)\s(.*\.h) \((in target: (.*)|in target '(.*)' from project '.*')\)"#)

    let file: String
    let targetFile: String
    let target: String

    init?(groups: [String]) {
        assert(groups.count >= 3)
        guard let file = groups[safe: 0], let targetFile = groups[safe: 1], let target = groups.last else { return nil }
        self.file = file.lastPathComponent
        self.targetFile = targetFile
        self.target = target
    }
}

struct CopyPlistCaptureGroup: CopyCaptureGroup {
    static let outputType: OutputType = .task

    /// Regular expression captured groups:
    /// $1 = source file
    /// $2 = target file
    static let regex = XCRegex(pattern: #"^CopyPlistFile\s(.*\.plist)\s(.*\.plist) \((in target: (.*)|in target '(.*)' from project '.*')\)"#)

    let file: String
    let target: String

    init?(groups: [String]) {
        assert(groups.count >= 2)
        guard let file = groups[safe: 0], let target = groups.last else { return nil }
        self.file = file.lastPathComponent
        self.target = target
    }
}

struct CopyStringsCaptureGroup: CopyCaptureGroup {
    static let outputType: OutputType = .task

    /// Regular expression captured groups:
    /// $1 = file
    static let regex = XCRegex(pattern: #"^CopyStringsFile\s(.*\.strings)\s(.*\.strings) \((in target: (.*)|in target '(.*)' from project '.*')\)"#)

    let file: String
    let target: String

    init?(groups: [String]) {
        assert(groups.count >= 2)
        guard let file = groups[safe: 0], let target = groups.last else { return nil }
        self.file = file.lastPathComponent
        self.target = target
    }
}

struct CpresourceCaptureGroup: CopyCaptureGroup {
    static let outputType: OutputType = .task

    /// Regular expression captured groups:
    /// $1 = resource
    static let regex = XCRegex(pattern: #"^CpResource\s(.*)\s\/(.*) \((in target: (.*)|in target '(.*)' from project '.*')\)"#)

    let file: String
    let target: String

    init?(groups: [String]) {
        assert(groups.count >= 2)
        guard let file = groups[safe: 0], let target = groups.last else { return nil }
        self.file = file.lastPathComponent
        self.target = target
    }
}

struct CreateUniversalBinaryCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    static let regex = XCRegex(pattern: #"^CreateUniversalBinary (.+) normal (?:.+) \(in target '(.+)' from project '(.+)'\)$"#)

    let filePath: String
    let filename: String
    let target: String
    let project: String

    init?(groups: [String]) {
        assert(groups.count == 3)
        guard let filePath = groups[safe: 0], let target = groups[safe: 1], let project = groups[safe: 2] else { return nil }
        self.filePath = filePath
        filename = filePath.lastPathComponent
        self.target = target
        self.project = project
    }
}

struct DetectedEncodingCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    static let regex = XCRegex(pattern: #"^(\/.+):(\d+):(\d+): note: detected encoding of input file as (.+) \(in target '(.+)' from project '(.+)'\)$"#)

    let filePath: String
    let filename: String
    let lineNumber: Int
    let columnNumber: Int
    let encoding: String
    let target: String
    let project: String

    init?(groups: [String]) {
        assert(groups.count == 6)
        guard let filePath = groups[safe: 0], let _lineNumber = groups[safe: 1], let lineNumber = Int(_lineNumber), let _columnNumber = groups[safe: 2], let columnNumber = Int(_columnNumber), let encoding = groups[safe: 3], let target = groups[safe: 4], let project = groups[safe: 5] else { return nil }
        self.filePath = filePath
        filename = filePath.lastPathComponent
        self.lineNumber = lineNumber
        self.columnNumber = columnNumber
        self.encoding = encoding
        self.target = target
        self.project = project
    }
}

struct ExecutedWithoutSkippedCaptureGroup: ExecutedCaptureGroup {
    static let outputType: OutputType = .result

    /// Regular expression captured groups:
    /// $1 = number of tests
    /// $2 = number of failures
    /// $3 = number of unexpected failures
    /// $4 = wall clock time in seconds (e.g. 0.295)
    static let regex = XCRegex(pattern: #"^\s*(Executed\s(\d+)\stest[s]?,\swith\s(\d+)\sfailure[s]?\s\((\d+)\sunexpected\)\sin\s\d+\.\d{3}\s\((\d+\.\d{3})\)\sseconds.*)$"#)

    let wholeResult: String
    let numberOfTests: Int
    let numberOfSkipped = 0
    let numberOfFailures: Int
    let numberOfUnexpectedFailures: Int
    let wallClockTimeInSeconds: Double

    init?(groups: [String]) {
        assert(groups.count == 5)
        guard let wholeResult = groups[safe: 0], let _numberOfTests = groups[safe: 1], let _numberOfFailures = groups[safe: 2], let _numberOfUnexpectedFailures = groups[safe: 3], let _wallClockTimeInSeconds = groups[safe: 4] else { return nil }
        guard let numberOfTests = Int(_numberOfTests), let numberOfFailures = Int(_numberOfFailures), let numberOfUnexpectedFailures = Int(_numberOfUnexpectedFailures), let wallClockTimeInSeconds = Double(_wallClockTimeInSeconds) else { return nil }
        self.wholeResult = wholeResult
        self.numberOfTests = numberOfTests
        self.numberOfFailures = numberOfFailures
        self.numberOfUnexpectedFailures = numberOfUnexpectedFailures
        self.wallClockTimeInSeconds = wallClockTimeInSeconds
    }
}

struct ExecutedWithSkippedCaptureGroup: ExecutedCaptureGroup {
    static let outputType: OutputType = .result

    /// Regular expression captured groups:
    /// $1 = number of tests
    /// $2 = number of skipped
    /// $3 = number of failures
    /// $4 = number of unexpected failures
    /// $5 = wall clock time in seconds (e.g. 0.295)
    static let regex = XCRegex(pattern: #"^\s*(Executed\s(\d+)\stest[s]?,\swith\s(\d+)\stest[s]?\sskipped\sand\s(\d+)\sfailure[s]?\s\((\d+)\sunexpected\)\sin\s\d+\.\d{3}\s\((\d+\.\d{3})\)\sseconds.*)$"#)

    let wholeResult: String
    let numberOfTests: Int
    let numberOfSkipped: Int
    let numberOfFailures: Int
    let numberOfUnexpectedFailures: Int
    let wallClockTimeInSeconds: Double

    init?(groups: [String]) {
        assert(groups.count == 6)
        guard let wholeResult = groups[safe: 0], let _numberOfTests = groups[safe: 1], let _numberOfSkipped = groups[safe: 2], let _numberOfFailures = groups[safe: 3], let _numberOfUnexpectedFailures = groups[safe: 4], let _wallClockTimeInSeconds = groups[safe: 5] else { return nil }
        guard let numberOfTests = Int(_numberOfTests), let numberOfSkipped = Int(_numberOfSkipped), let numberOfFailures = Int(_numberOfFailures), let numberOfUnexpectedFailures = Int(_numberOfUnexpectedFailures), let wallClockTimeInSeconds = Double(_wallClockTimeInSeconds) else { return nil }
        self.wholeResult = wholeResult
        self.numberOfTests = numberOfTests
        self.numberOfSkipped = numberOfSkipped
        self.numberOfFailures = numberOfFailures
        self.numberOfUnexpectedFailures = numberOfUnexpectedFailures
        self.wallClockTimeInSeconds = wallClockTimeInSeconds
    }
}

struct ExplicitDependencyCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    static let regex = XCRegex(pattern: #"^[ \t]*➜ Explicit dependency on target '([^']+)' in project '([^']+)'$"#)

    let target: String
    let project: String

    init?(groups: [String]) {
        assert(groups.count == 2)
        guard let target = groups[safe: 0], let project = groups[safe: 1] else { return nil }
        self.target = target
        self.project = project
    }
}

struct FailingTestCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .error

    /// Regular expression captured groups:
    /// $1 = file
    /// $2 = test suite
    /// $3 = test case
    /// $4 = reason
    #if os(Linux)
    static let regex = XCRegex(pattern: #"^\s*(.+:\d+):\serror:\s(.*)\.(.*)\s:(?:\s'.*'\s\[failed\],)?\s(.*)"#)
    #else
    static let regex = XCRegex(pattern: #"^\s*(.+:\d+):\serror:\s[\+\-]\[(.*?)\s(.*)\]\s:(?:\s'.*'\s\[FAILED\],)?\s(.*)"#)
    #endif

    let file: String
    let testSuite: String
    let testCase: String
    let reason: String

    init?(groups: [String]) {
        assert(groups.count >= 4)
        guard let file = groups[safe: 0], let testSuite = groups[safe: 1], let testCase = groups[safe: 2], let reason = groups[safe: 3] else { return nil }
        self.file = file
        self.testSuite = testSuite
        self.testCase = testCase
        self.reason = reason
    }
}

struct UIFailingTestCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .error

    /// Regular expression captured groups:
    /// $1 = file
    /// $2 = reason
    static let regex = XCRegex(pattern: #"^\s{4}t = \s+\d+\.\d+s\s+Assertion Failure: (.*:\d+): (.*)$"#)

    let file: String
    let reason: String

    init?(groups: [String]) {
        assert(groups.count >= 2)
        guard let file = groups[safe: 0], let reason = groups[safe: 1] else { return nil }
        self.file = file
        self.reason = reason
    }
}

struct RestartingTestCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .test

    /// Regular expression captured groups:
    /// $1 = whole message
    /// $2 = test suite + test case
    /// $3 = test suite
    /// $4 = test case
    static let regex = XCRegex(pattern: #"^(Restarting after unexpected exit, crash, or test timeout in (-\[(\w+)\s(\w+)\]|(\w+)\.(\w+)\(\));.*)"#)

    let wholeMessage: String
    let testSuiteAndTestCase: String
    let testSuite: String
    let testCase: String

    init?(groups: [String]) {
        assert(groups.count >= 4)
        guard let wholeMessage = groups[safe: 0], let testSuiteAndTestCase = groups[safe: 1], let testSuite = groups[safe: 2], let testCase = groups[safe: 3] else { return nil }
        self.wholeMessage = wholeMessage
        self.testSuiteAndTestCase = testSuiteAndTestCase
        self.testSuite = testSuite
        self.testCase = testCase
    }
}

struct GenerateCoverageDataCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    /// Regular expression captured groups:
    /// $1 = coverage report file path
    static let regex = XCRegex(pattern: #"^generating\s+coverage\s+data\.*"#)

    private init() { }

    init?(groups: [String]) {
        assert(groups.count >= 0)
        self.init()
    }
}

struct GeneratedCoverageReportCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task
    static let regex = XCRegex(pattern: #"^generated\s+coverage\s+report:\s+(.+)"#)

    let coverageReportFilePath: String

    init?(groups: [String]) {
        assert(groups.count >= 1)
        guard let coverageReportFilePath = groups[safe: 0] else { return nil }
        self.coverageReportFilePath = coverageReportFilePath
    }
}

struct GenerateDSYMCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    /// Regular expression captured groups:
    /// $1 = dsym
    /// $2 = target
    static let regex = XCRegex(pattern: #"^GenerateDSYMFile \/.*\/(.*\.dSYM) \/.* \((in target: (.*)|in target '(.*)' from project '.*')\)"#)

    let dsym: String
    let target: String

    init?(groups: [String]) {
        assert(groups.count >= 2)
        guard let dsym = groups[safe: 0], let target = groups.last else { return nil }
        self.dsym = dsym
        self.target = target
    }
}

struct LibtoolCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    /// Regular expression captured groups:
    /// $1 = library
    /// $2 = target
    static let regex = XCRegex(pattern: #"^Libtool.*\/(.*) .* .* \((in target: (.*)|in target '(.*)' from project '.*')\)"#)

    let filename: String
    let target: String

    init?(groups: [String]) {
        assert(groups.count >= 2)
        guard let filename = groups[safe: 0], let target = groups.last else { return nil }
        self.filename = filename
        self.target = target
    }
}

struct LinkingCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    #if os(Linux)
    /// Regular expression captured groups:
    /// $1 = target
    static let regex = XCRegex(pattern: #"^\[\d+\/\d+\]\sLinking\s([^ ]+)"#)
    #else
    /// Regular expression captured groups:
    /// $1 = binary filename
    /// $2 = target
    static let regex = XCRegex(pattern: #"^Ld \/?.*\/(.*?) normal (?:.* )?\((?:in target: (.*)|in target '(.*)' from project '.*')\)"#)
    #endif

    #if !os(Linux)
    let binaryFilename: String
    #endif
    let target: String

    init?(groups: [String]) {
        #if os(Linux)
        assert(groups.count == 1)
        guard let target = groups[safe: 0] else { return nil }
        self.target = target
        #else
        assert(groups.count == 2)
        guard let binaryFileName = groups[safe: 0], let target = groups.last else { return nil }
        binaryFilename = binaryFileName.lastPathComponent
        self.target = target
        #endif
    }
}

struct TestCaseSkippedCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .testCase

    /// Regular expression captured groups:
    /// $1 = suite
    /// $2 = test case
    /// $3 = time
    #if os(Linux)
    static let regex = XCRegex(pattern: #"^\s*Test Case\s'(.*)\.(.*)'\sskipped\s\((\d*\.\d{1,3})\sseconds\)"#)
    #else
    static let regex = XCRegex(pattern: #"^\s*Test Case\s'-\[(.*?)\s(.*)\]'\sskipped\s\((\d*\.\d{3})\sseconds\)."#)
    #endif

    let suite: String
    let testCase: String
    let time: String

    init?(groups: [String]) {
        assert(groups.count >= 3)
        guard let suite = groups[safe: 0], let testCase = groups[safe: 1], let time = groups[safe: 2] else { return nil }
        self.suite = suite
        self.testCase = testCase
        self.time = time
    }
}

struct TestCasePassedCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .testCase

    /// Regular expression captured groups:
    /// $1 = suite
    /// $2 = test case
    /// $3 = time
    #if os(Linux)
    static let regex = XCRegex(pattern: #"^\s*Test Case\s'(.*)\.(.*)'\spassed\s\((\d*\.\d{1,3})\sseconds\)"#)
    #else
    static let regex = XCRegex(pattern: #"^\s*Test Case\s'-\[(.*?)\s(.*)\]'\spassed\s\((\d*\.\d{3})\sseconds\)."#)
    #endif

    let suite: String
    let testCase: String
    let time: String

    init?(groups: [String]) {
        assert(groups.count >= 3)
        guard let suite = groups[safe: 0], let testCase = groups[safe: 1], let time = groups[safe: 2] else { return nil }
        self.suite = suite
        self.testCase = testCase
        self.time = time
    }
}

struct TestCaseStartedCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .testCase

    /// Regular expression captured groups:
    /// $1 = suite
    /// $2 = test case
    #if os(Linux)
    static let regex = XCRegex(pattern: #"^Test Case '(.*)\.(.*)' started at"#)
    #else
    static let regex = XCRegex(pattern: #"^Test Case '-\[(.*?) (.*)\]' started.$"#)
    #endif

    let suite: String
    let testCase: String

    init?(groups: [String]) {
        assert(groups.count >= 2)
        guard let suite = groups[safe: 0], let testCase = groups[safe: 1] else { return nil }
        self.suite = suite
        self.testCase = testCase
    }
}

struct TestCasePendingCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .testCase

    /// Regular expression captured groups:
    /// $1 = suite
    /// $2 = test case
    static let regex = XCRegex(pattern: #"^Test Case\s'-\[(.*?)\s(.*)PENDING\]'\spassed"#)

    let suite: String
    let testCase: String

    init?(groups: [String]) {
        assert(groups.count >= 2)
        guard let suite = groups[safe: 0], let testCase = groups[safe: 1] else { return nil }
        self.suite = suite
        self.testCase = testCase
    }
}

struct TestCaseMeasuredCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .testCase

    /// $1 = suite
    /// $2 = test case
    /// $3 = time
    #if os(Linux)
    static let regex = XCRegex(pattern: #"^[^:]*:[^:]*:\sTest Case\s'(.*?)\.(.*)'\smeasured\s\[([^,]*),\s([^\]]*)\]\saverage:\s(\d*\.\d{3}), relative standard deviation: (\d*\.\d{3})"#)
    #else
    static let regex = XCRegex(pattern: #"^[^:]*:[^:]*:\sTest Case\s'-\[(.*?)\s(.*)\]'\smeasured\s\[([^,]*),\s([^\]]*)\]\saverage:\s(\d*\.\d{3}), relative standard deviation: (\d*\.\d{3})"#)
    #endif

    let suite: String
    let testCase: String
    let name: String
    let unitName: String
    let value: String
    let deviation: String

    init?(groups: [String]) {
        assert(groups.count >= 6)
        guard let suite = groups[safe: 0], let testCase = groups[safe: 1], let name = groups[safe: 2], let unitName = groups[safe: 3], let value = groups[safe: 4], let deviation = groups[safe: 5] else { return nil }
        self.suite = suite
        self.testCase = testCase
        self.name = name
        self.unitName = unitName
        self.value = value
        self.deviation = deviation
    }
}

struct ParallelTestCaseSkippedCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .testCase

    /// Regular expression captured groups:
    /// $1 = suite
    /// $2 = test case
    /// $3 = installed app file and ID (e.g. "MyApp.app (12345)"), process (e.g. "xctest (12345)"), or device (e.g. "iPhone X")
    /// $4 = time
    static let regex = XCRegex(pattern: #"^Test\s+case\s+'(.*)\.(.*)\(\)'\s+skipped\s+on\s+'(.*)'\s+\((\d*\.(.*){3})\s+seconds\)"#)

    let suite: String
    let testCase: String
    let device: String
    let time: String

    init?(groups: [String]) {
        assert(groups.count >= 4)
        guard let suite = groups[safe: 0], let testCase = groups[safe: 1], let device = groups[safe: 2], let time = groups[safe: 3] else { return nil }
        self.suite = suite
        self.testCase = testCase
        self.device = device
        self.time = time
    }
}

struct ParallelTestCasePassedCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .testCase

    /// Regular expression captured groups:
    /// $1 = suite
    /// $2 = test case
    /// $3 = installed app file and ID (e.g. "MyApp.app (12345)"), process (e.g. "xctest (12345)"), or device (e.g. "iPhone X")
    /// $4 = time
    static let regex = XCRegex(pattern: #"^Test\s+case\s+'(.*)[\.\/](.*)\(\)'\s+passed\s+on\s+'(.*)'\s+\((\d*\.(.*){3})\s+seconds\)"#)

    let suite: String
    let testCase: String
    let device: String
    let time: String

    init?(groups: [String]) {
        assert(groups.count >= 4)
        guard let suite = groups[safe: 0], let testCase = groups[safe: 1], let device = groups[safe: 2], let time = groups[safe: 3] else { return nil }
        self.suite = suite
        self.testCase = testCase
        self.device = device
        self.time = time
    }
}

struct ParallelTestCaseAppKitPassedCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .testCase

    /// Regular expression captured groups:
    /// $1 = suite
    /// $2 = test case
    /// $3 = time
    static let regex = XCRegex(pattern: #"^\s*Test case\s'-\[(.*?)\s(.*)\]'\spassed\son\s'.*'\s\((\d*\.\d{3})\sseconds\)"#)

    let suite: String
    let testCase: String
    let time: String

    init?(groups: [String]) {
        assert(groups.count >= 3)
        guard let suite = groups[safe: 0], let testCase = groups[safe: 1], let time = groups[safe: 2] else { return nil }
        self.suite = suite
        self.testCase = testCase
        self.time = time
    }
}

struct ParallelTestCaseFailedCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .error

    /// Regular expression captured groups:
    /// $1 = suite
    /// $2 = test case
    /// $3 = installed app file and ID (e.g. "MyApp.app (12345)"), process (e.g. "xctest (12345)"), or device (e.g. "iPhone X")
    /// $4 = time
    static let regex = XCRegex(pattern: #"^Test\s+case\s+'(.*)[\./](.*)\(\)'\s+failed\s+on\s+'(.*)'\s+\((\d*\.(.*){3})\s+seconds\)"#)

    let suite: String
    let testCase: String
    let device: String
    let time: String

    init?(groups: [String]) {
        assert(groups.count >= 4)
        guard let suite = groups[safe: 0], let testCase = groups[safe: 1], let device = groups[safe: 2], let time = groups[safe: 3] else { return nil }
        self.suite = suite
        self.testCase = testCase
        self.device = device
        self.time = time
    }
}

struct ParallelTestingStartedCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .test

    /// Regular expression captured groups:
    /// $1 = whole message
    /// $2 = device
    static let regex = XCRegex(pattern: #"^(Testing\s+started\s+on\s+'(.*)'.*)$"#)

    let wholeMessage: String
    let device: String

    init?(groups: [String]) {
        assert(groups.count >= 2)
        guard let wholeMessage = groups[safe: 0], let device = groups[safe: 1] else { return nil }
        self.wholeMessage = wholeMessage
        self.device = device
    }
}

struct ParallelTestingPassedCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .test

    /// Regular expression captured groups:
    /// $1 = whole message
    /// $2 = device
    static let regex = XCRegex(pattern: #"^(Testing\s+passed\s+on\s+'(.*)'.*)$"#)

    let wholeMessage: String
    let device: String

    init?(groups: [String]) {
        assert(groups.count >= 2)
        guard let wholeMessage = groups[safe: 0], let device = groups[safe: 1] else { return nil }
        self.wholeMessage = wholeMessage
        self.device = device
    }
}

struct ParallelTestingFailedCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .nonContextualError

    /// Regular expression captured groups:
    /// $1 = whole error
    /// $2 = device
    static let regex = XCRegex(pattern: #"^(Testing\s+failed\s+on\s+'(.*)'.*)$"#)

    let wholeError: String
    let device: String

    init?(groups: [String]) {
        assert(groups.count >= 2)
        guard let wholeError = groups[safe: 0], let device = groups[safe: 1] else { return nil }
        self.wholeError = wholeError
        self.device = device
    }
}

struct ParallelTestSuiteStartedCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .test

    /// Regular expression captured groups:
    /// $1 = suite
    /// $2 = device
    static let regex = XCRegex(pattern: #"^\s*Test\s+Suite\s+'(.*)'\s+started\s+on\s+'(.*)'"#)

    let suite: String
    let device: String

    init?(groups: [String]) {
        assert(groups.count >= 2)
        guard let suite = groups[safe: 0], let device = groups[safe: 1] else { return nil }
        self.suite = suite
        self.device = device
    }
}

struct PhaseSuccessCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .result
    static let regex = XCRegex(pattern: #"^\*\*\s(.*)\sSUCCEEDED\s\*\*"#)

    let phase: String

    init?(groups: [String]) {
        assert(groups.count >= 1)
        guard let phase = groups[safe: 0] else { return nil }
        self.phase = phase
    }
}

struct PhaseScriptExecutionCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    /// Regular expression captured groups:
    /// $1 = phase name
    /// $2 = target
    static let regex = XCRegex(pattern: #"^PhaseScriptExecution\s(.*)\s\/.*\.sh\s\((in target: (.*)|in target '(.*)' from project '.*')\)"#)

    let phaseName: String
    let target: String

    init?(groups: [String]) {
        assert(groups.count >= 2)
        guard let phaseName = groups[safe: 0], let target = groups.last else { return nil }
        self.phaseName = phaseName
        self.target = target
    }
}

struct PrecompileModuleCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    static let regex = XCRegex(pattern: #"^PrecompileModule (.*\.scan)$"#)

    let path: String

    init?(groups: [String]) {
        assert(groups.count == 1)
        guard let path = groups[safe: 0] else { return nil }
        self.path = path
    }
}

struct ProcessPchCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    /// Regular expression captured groups:
    /// $1 = file
    /// $2 = build target
    static let regex = XCRegex(pattern: #"^ProcessPCH(?:\+\+)?\s.*\s\/.*\/(.*) normal .* .* .* \((in target: (.*)|in target '(.*)' from project '.*')\)"#)

    let file: String
    let buildTarget: String

    init?(groups: [String]) {
        assert(groups.count >= 2)
        guard let file = groups[safe: 0], let buildTarget = groups.last else { return nil }
        self.file = file
        self.buildTarget = buildTarget
    }
}

struct ProcessPchCommandCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    /// Regular expression captured groups:
    /// $1 file path
    static let regex = XCRegex(pattern: #"^\s*.*\/usr\/bin\/clang\s.*\s\-c\s(.*?)(?<!\\)\s.*\-o\s.*\.gch"#)

    let filePath: String

    init?(groups: [String]) {
        assert(groups.count >= 1)
        guard let filePath = groups.last else { return nil }
        self.filePath = filePath
    }
}

struct PreprocessCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    /// Regular expression captured groups:
    /// $1 = file path
    /// $2 = file
    /// $3 = target
    /// $4 = project
    static let regex = XCRegex(pattern: #"^Preprocess\s(.*\/(.*\.(?:m|mm|cc|cpp|c|cxx)))\s.*\(in target '(.*)' from project '(.*)'\)"#)

    let filePath: String
    let file: String
    let target: String
    let project: String

    init?(groups: [String]) {
        assert(groups.count >= 4)
        guard let filePath = groups[safe: 0], let file = groups[safe: 1], let target = groups[safe: 2], let project = groups[safe: 3] else { return nil }
        self.filePath = filePath
        self.file = file
        self.target = target
        self.project = project
    }
}

struct PbxcpCaptureGroup: CopyCaptureGroup {
    static let outputType: OutputType = .task

    /// Regular expression captured groups:
    /// $1 = source file
    /// $2 = target file
    /// $3 = build target
    static let regex = XCRegex(pattern: #"^PBXCp\s(.*)\s\/(.*)\s\((in target: (.*)|in target '(.*)' from project '.*')\)"#)

    let file: String
    let targetFile: String
    let target: String

    init?(groups: [String]) {
        assert(groups.count >= 3)
        guard let file = groups[safe: 0], let targetFile = groups[safe: 1], let target = groups.last else { return nil }
        self.file = file.lastPathComponent
        self.targetFile = targetFile
        self.target = target
    }
}

struct ProcessInfoPlistCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    /// Regular expression captured groups:
    /// $1 = file path
    /// $2 = filename
    /// $4 = target
    static let regex = XCRegex(pattern: #"^ProcessInfoPlistFile\s.*\.plist\s(.*\/+(.*\.plist))( \((in target: (.*)|in target '(.*)' from project '.*')\))?"#)

    let filePath: String
    let filename: String
    let target: String? // Xcode 10+

    init?(groups: [String]) {
        assert(groups.count >= 2)
        guard let filePath = groups[safe: 0], let filename = groups[safe: 1] else { return nil }

        // TODO: Test with target included
        if groups.count == 2 {
            // Xcode 9 excludes target output
            self.filePath = filePath
            self.filename = filename
            target = nil
        } else {
            // Xcode 10+ includes target output
            self.filePath = filePath
            self.filename = filename
            target = groups.last
        }
    }
}

struct RegisterExecutionPolicyExceptionCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    static let regex = XCRegex(pattern: #"^RegisterExecutionPolicyException (.+\/(.+\..+)) \(in target '(.+)' from project '(.+)'\)$"#)

    let filePath: String
    let filename: String
    let target: String
    let project: String

    init?(groups: [String]) {
        assert(groups.count == 4)
        guard let filePath = groups[safe: 0], let filename = groups[safe: 1], let target = groups[safe: 2], let project = groups[safe: 3] else { return nil }
        self.filePath = filePath
        self.filename = filename
        self.target = target
        self.project = project
    }
}

struct ScanDependenciesCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    static let regex = XCRegex(pattern: #"ScanDependencies .* normal (arm64|arm64_32|armv7k|i386|x86_64) .* \(in target '(.*)' from project '(.*)'\)$"#)

    let arch: Architecture
    let target: String
    let project: String

    init?(groups: [String]) {
        assert(groups.count == 3)
        guard let _arch = groups[safe: 0], let arch = Architecture(rawValue: _arch), let target = groups[safe: 1], let project = groups[safe: 2] else { return nil }
        self.arch = arch
        self.target = target
        self.project = project
    }
}

struct TestsRunCompletionCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .test

    /// Regular expression captured groups:
    /// $1 = suite
    /// $2 = result
    /// $3 = time
    #if os(Linux)
    static let regex = XCRegex(pattern: #"^\s*(Test Suite '(.*)' (finished|passed|failed) at (.*).*)"#)
    #else
    static let regex = XCRegex(pattern: #"^\s*(Test Suite '(?:.*\/)?(.*[ox]ctest.*)' (finished|passed|failed) at (.*).*)"#)
    #endif

    let wholeResult: String
    let suite: String
    let result: String
    let time: String

    init?(groups: [String]) {
        assert(groups.count >= 4)
        guard let wholeResult = groups[safe: 0], let suite = groups[safe: 1], let result = groups[safe: 2], let time = groups[safe: 3] else { return nil }
        self.wholeResult = wholeResult
        self.suite = suite
        self.result = result
        self.time = time
    }
}

struct TestSuiteStartedCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .test

    /// Regular expression captured groups:
    /// $1 = suite
    /// $2 = time
    #if os(Linux)
    static let regex = XCRegex(pattern: #"^\s*Test Suite '(.*)' started at(.*)"#)
    #else
    static let regex = XCRegex(pattern: #"^\s*Test Suite '(?:.*\/)?(.*[ox]ctest.*)' started at(.*)"#)
    #endif

    let suite: String
    let time: String

    init?(groups: [String]) {
        assert(groups.count >= 2)
        guard let suite = groups[safe: 0], let time = groups[safe: 1] else { return nil }
        self.suite = suite
        self.time = time
    }
}

struct TestSuiteStartCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .test

    /// Regular expression captured groups:
    /// $1 = test suite name
    static let regex = XCRegex(pattern: #"^\s*Test Suite '(.*)' started at"#)

    let testSuiteName: String

    init?(groups: [String]) {
        assert(groups.count >= 1)
        guard let testSuiteName = groups[safe: 0] else { return nil }
        self.testSuiteName = testSuiteName
    }
}

struct TestSuiteAllTestsPassedCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .result
    static let regex = XCRegex(pattern: #"^\s*(Test Suite 'All tests' passed at.*)"#)

    let wholeResult: String

    init?(groups: [String]) {
        assert(groups.count == 1)
        guard let wholeResult = groups[safe: 0] else { return nil }
        self.wholeResult = wholeResult
    }
}

struct TestSuiteAllTestsFailedCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .result
    static let regex = XCRegex(pattern: #"^\s*(Test Suite 'All tests' failed at.*)"#)

    let wholeResult: String

    init?(groups: [String]) {
        assert(groups.count == 1)
        guard let wholeResult = groups[safe: 0] else { return nil }
        self.wholeResult = wholeResult
    }
}

struct TIFFutilCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    /// Regular expression captured groups:
    /// $1 = filename
    static let regex = XCRegex(pattern: #"^TiffUtil\s(.*)"#)

    let filename: String

    init?(groups: [String]) {
        assert(groups.count >= 1)
        guard let filename = groups[safe: 0] else { return nil }
        self.filename = filename
    }
}

struct TouchCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    /// Regular expression captured groups:
    /// $1 = filename
    /// $3 = target
    static let regex = XCRegex(pattern: #"^Touch\s(.*\/(.+))( \((in target: (.*)|in target '(.*)' from project '.*')\))"#)

    let filename: String
    let target: String

    init?(groups: [String]) {
        assert(groups.count >= 3)
        guard let filename = groups[safe: 1], let target = groups.last else { return nil }
        self.filename = filename
        self.target = target
    }
}

struct WriteFileCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    /// Regular expression captured groups:
    /// $1 = file path
    static let regex = XCRegex(pattern: #"^write-file\s(.*)"#)

    let filePath: String

    init?(groups: [String]) {
        assert(groups.count >= 1)
        guard let filePath = groups[safe: 0] else { return nil }
        self.filePath = filePath
    }
}

struct WriteAuxiliaryFileCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    static let regex = XCRegex(pattern: #"^WriteAuxiliaryFile (.*\/(.*\..*)) \(in target '(.*)' from project '.*'\)$"#)

    let filePath: String
    let filename: String
    let target: String

    init?(groups: [String]) {
        assert(groups.count >= 3)
        guard let filePath = groups[safe: 0], let filename = groups[safe: 1], let target = groups[safe: 2] else { return nil }
        self.filePath = filePath
        self.filename = filename
        self.target = target
    }
}

struct CompileWarningCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .warning

    /// Regular expression captured groups:
    /// $1 = file path
    /// $2 = filename
    /// $3 = reason
    static let regex = XCRegex(pattern: #"^(([^:]*):*\d*:*\d*):\swarning:\s(.*)$"#)

    let filePath: String
    let filename: String
    let reason: String

    init?(groups: [String]) {
        assert(groups.count >= 3)
        guard let filePath = groups[safe: 0], let filename = groups[safe: 1], let reason = groups[safe: 2] else { return nil }
        self.filePath = filePath
        self.filename = filename
        self.reason = reason
    }
}

struct LDWarningCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .warning

    /// Regular expression captured groups:
    /// $1 = ld prefix
    /// $2 = warning message
    static let regex = XCRegex(pattern: #"^(ld: )warning: (.*)"#)

    let ldPrefix: String
    let warningMessage: String

    init?(groups: [String]) {
        assert(groups.count >= 2)
        guard let ldPrefix = groups[safe: 0], let warningMessage = groups[safe: 1] else { return nil }
        self.ldPrefix = ldPrefix
        self.warningMessage = warningMessage
    }
}

struct GenericWarningCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .warning

    /// Regular expression captured groups:
    /// $1 = whole warning
    static let regex = XCRegex(pattern: #"^warning:\s(.*)$"#)

    let wholeWarning: String

    init?(groups: [String]) {
        assert(groups.count >= 1)
        guard let wholeWarning = groups[safe: 0] else { return nil }
        self.wholeWarning = wholeWarning
    }
}

struct WillNotBeCodeSignedCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .warning

    /// Regular expression captured groups:
    /// $1 = whole warning
    static let regex = XCRegex(pattern: #"^(.* will not be code signed because .*)$"#)

    let wholeWarning: String

    init?(groups: [String]) {
        assert(groups.count >= 1)
        guard let wholeWarning = groups[safe: 0] else { return nil }
        self.wholeWarning = wholeWarning
    }
}

struct DuplicateLocalizedStringKeyCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .warning

    /// Regular expresion captured groups:
    /// $1 = warning message.
    static let regex = XCRegex(pattern: #"^[\d\s-:]+ --- WARNING: (Key ".*" used with multiple values. Value ".*" kept. Value ".*" ignored.)$"#)

    let warningMessage: String

    init?(groups: [String]) {
        assert(groups.count >= 1)
        guard let wholeMessage = groups[safe: 0] else { return nil }
        warningMessage = wholeMessage
    }
}

struct ClangErrorCaptureGroup: ErrorCaptureGroup {
    static let outputType: OutputType = .error

    /// Regular expression captured groups:
    /// $1 = whole error
    static let regex = XCRegex(pattern: #"^(clang: error:.*)$"#)

    let wholeError: String

    init?(groups: [String]) {
        assert(groups.count >= 1)
        guard let wholeError = groups[safe: 0] else { return nil }
        self.wholeError = wholeError
    }
}

struct CheckDependenciesErrorsCaptureGroup: ErrorCaptureGroup {
    static let outputType: OutputType = .error

    /// Regular expression captured groups:
    /// $1 = whole error
    static let regex = XCRegex(pattern: #"^(Code\s?Sign error:.*|Code signing is required for product type .* in SDK .*|No profile matching .* found:.*|Provisioning profile .* doesn't .*|Swift is unavailable on .*|.?Use Legacy Swift Language Version.*)$"#)

    let wholeError: String

    init?(groups: [String]) {
        assert(groups.count >= 1)
        guard let wholeError = groups.first else { return nil }
        self.wholeError = wholeError
    }
}

struct ProvisioningProfileRequiredCaptureGroup: ErrorCaptureGroup {
    static let outputType: OutputType = .error

    /// Regular expression captured groups:
    /// $1 = whole error
    static let regex = XCRegex(pattern: #"^(.*requires a provisioning profile.*)$"#)

    let wholeError: String

    init?(groups: [String]) {
        assert(groups.count >= 1)
        guard let wholeError = groups[safe: 0] else { return nil }
        self.wholeError = wholeError
    }
}

struct NoCertificateCaptureGroup: ErrorCaptureGroup {
    static let outputType: OutputType = .warning

    /// Regular expression captured groups:
    /// $1 = whole error
    static let regex = XCRegex(pattern: #"^(No certificate matching.*)$"#)

    let wholeError: String

    init?(groups: [String]) {
        assert(groups.count >= 1)
        guard let wholeError = groups[safe: 0] else { return nil }
        self.wholeError = wholeError
    }
}

struct CompileErrorCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .error

    /// Regular expression captured groups:
    /// $1 = file path
    /// $2 = is fatal error
    /// $3 = reason
    static let regex = XCRegex(pattern: #"^(([^:]*):*\d*:*\d*):\s(?:fatal\s)?error:\s(.*)$"#)

    let filePath: String
    let isFatalError: String
    let reason: String

    init?(groups: [String]) {
        assert(groups.count >= 3)
        guard let filePath = groups[safe: 0], let isFatalError = groups[safe: 1], let reason = groups[safe: 2] else { return nil }
        self.filePath = filePath
        self.isFatalError = isFatalError
        self.reason = reason
    }
}

struct CursorCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .warning

    /// Regular expression captured groups:
    /// $1 = cursor (with whitespaces and tildes)
    static let regex = XCRegex(pattern: #"^([\s~]*\^[\s~]*)$"#)

    let cursor: String

    init?(groups: [String]) {
        assert(groups.count >= 1)
        guard let cursor = groups[safe: 0] else { return nil }
        self.cursor = cursor
    }
}

struct FatalErrorCaptureGroup: ErrorCaptureGroup {
    static let outputType: OutputType = .error

    /// Regular expression captured groups:
    /// $1 = whole error.
    /// it varies a lot, not sure if it makes sense to catch everything separately
    static let regex = XCRegex(pattern: #"^(fatal error:.*)$"#)

    let wholeError: String

    init?(groups: [String]) {
        assert(groups.count >= 1)
        guard let wholeError = groups[safe: 0] else { return nil }
        self.wholeError = wholeError
    }
}

struct FileMissingErrorCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .error

    /// Regular expression captured groups:
    /// $1 = whole error.
    /// $2 = file path
    static let regex = XCRegex(pattern: #"^<unknown>:0:\s(error:\s.*)\s'(\/.+\/.*\..*)'$"#)

    let reason: String
    let filePath: String

    init?(groups: [String]) {
        assert(groups.count >= 2)
        guard let reason = groups[safe: 0], let filePath = groups[safe: 1] else { return nil }
        self.reason = reason
        self.filePath = filePath
    }
}

struct LDErrorCaptureGroup: ErrorCaptureGroup {
    static let outputType: OutputType = .error

    /// Regular expression captured groups:
    /// $1 = whole error
    static let regex = XCRegex(pattern: #"^(ld:.*)"#)

    let wholeError: String

    init?(groups: [String]) {
        assert(groups.count >= 1)
        guard let wholeError = groups[safe: 0] else { return nil }
        self.wholeError = wholeError
    }
}

struct LinkerDuplicateSymbolsLocationCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .error

    /// Regular expression captured groups:
    /// $1 = file path
    static let regex = XCRegex(pattern: #"^\s+(\/.*\.o[\)]?)$"#)

    let wholeError: String

    init?(groups: [String]) {
        assert(groups.count >= 1)
        guard let wholeError = groups[safe: 0] else { return nil }
        self.wholeError = wholeError
    }
}

struct LinkerDuplicateSymbolsCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .error

    /// Regular expression captured groups:
    /// $1 = reason
    static let regex = XCRegex(pattern: #"^(duplicate symbol .*):$"#)

    let reason: String

    init?(groups: [String]) {
        assert(groups.count >= 1)
        guard let reason = groups[safe: 0] else { return nil }
        self.reason = reason
    }
}

struct LinkerUndefinedSymbolLocationCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .error

    /// Regular expression captured groups:
    /// $1 = symbol location
    static let regex = XCRegex(pattern: #"^(.* in .*\.o)$"#)

    let symbolLocation: String

    init?(groups: [String]) {
        assert(groups.count >= 1)
        guard let symbolLocation = groups[safe: 0] else { return nil }
        self.symbolLocation = symbolLocation
    }
}

struct LinkerUndefinedSymbolsCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .error

    /// Regular expression captured groups:
    /// $1 = reason
    static let regex = XCRegex(pattern: #"^(Undefined symbols for architecture .*):$"#)

    let reason: String

    init?(groups: [String]) {
        assert(groups.count >= 1)
        guard let reason = groups[safe: 0] else { return nil }
        self.reason = reason
    }
}

struct PodsErrorCaptureGroup: ErrorCaptureGroup {
    static let outputType: OutputType = .error

    /// Regular expression captured groups:
    /// $1 = reason
    static let regex = XCRegex(pattern: #"^(error:\s.*)"#)

    let wholeError: String

    init?(groups: [String]) {
        assert(groups.count >= 1)
        guard let wholeError = groups[safe: 0] else { return nil }
        self.wholeError = wholeError
    }
}

struct SymbolReferencedFromCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .error

    /// Regular expression captured groups:
    /// $1 = wholeError
    /// $2 = reference
    static let regex = XCRegex(pattern: #"(\s+\"(.*)\", referenced from:)$"#)

    let wholeError: String
    let reference: String

    init?(groups: [String]) {
        assert(groups.count >= 2)
        guard let wholeError = groups[safe: 0], let reference = groups[safe: 1] else { return nil }
        self.wholeError = wholeError
        self.reference = reference
    }
}

struct ModuleIncludesErrorCaptureGroup: ErrorCaptureGroup {
    static let outputType: OutputType = .error

    /// Regular expression captured groups:
    /// $1 = error reason
    static let regex = XCRegex(pattern: #"^\<module-includes\>:.*?:.*?:\s(?:fatal\s)?(error:\s.*)$/"#)

    let wholeError: String

    init?(groups: [String]) {
        assert(groups.count >= 1)
        guard let wholeError = groups[safe: 0] else { return nil }
        self.wholeError = wholeError
    }
}

struct UndefinedSymbolLocationCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .warning
    /// Regular expression captured groups:
    /// $1 = whole warning
    /// $2 = target
    /// $3 = filename
    static let regex = XCRegex(pattern: #"(.+ in (.+)\((.+)\.o\))$"#)

    let wholeWarning: String
    let target: String
    let filename: String

    init?(groups: [String]) {
        assert(groups.count >= 3)
        guard let wholeWarning = groups[safe: 0], let target = groups[safe: 1], let filename = groups[safe: 2] else { return nil }
        self.wholeWarning = wholeWarning
        self.target = target
        self.filename = filename
    }
}

struct PackageFetchingCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task
    static let regex = XCRegex(pattern: #"^Fetching from (.*?)$"#)

    let source: String

    init?(groups: [String]) {
        assert(groups.count >= 1)
        guard let source = groups[safe: 0] else { return nil }
        self.source = source
    }
}

struct PackageUpdatingCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task
    static let regex = XCRegex(pattern: #"^Updating from (.*?)$"#)

    let source: String

    init?(groups: [String]) {
        assert(groups.count >= 1)
        guard let source = groups[safe: 0] else { return nil }
        self.source = source
    }
}

struct PackageCheckingOutCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task
    static let regex = XCRegex(pattern: #"^Checking out (.*?) of package (.*?)$"#)

    let version: String
    let package: String

    init?(groups: [String]) {
        assert(groups.count >= 2)
        guard let version = groups[safe: 0], let package = groups[safe: 1] else { return nil }
        self.version = version
        self.package = package
    }
}

struct PackageGraphResolvingStartCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task
    static let regex = XCRegex(pattern: #"^\s*Resolve Package Graph\s*$"#)

    private init() { }

    init?(groups: [String]) {
        assert(groups.count >= 0)
        self.init()
    }
}

struct PackageGraphResolvingEndedCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task
    static let regex = XCRegex(pattern: #"^Resolved source packages:$"#)

    private init() { }

    init?(groups: [String]) {
        assert(groups.count >= 0)
        self.init()
    }
}

struct PackageGraphResolvedItemCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    /// Regular expression captures groups:
    /// $1 = package name
    /// $2 = package url
    /// $3 = package version
    static let regex = XCRegex(pattern: #"^\s*([^\s:]+):\s([^ ]+)\s@\s(\d+\.\d+\.\d+)"#)

    let packageName: String
    let packageURL: String
    let packageVersion: String

    init?(groups: [String]) {
        assert(groups.count >= 3)
        guard let packageName = groups[safe: 0], let packageURL = groups[safe: 1], let packageVersion = groups[safe: 2] else { return nil }
        self.packageName = packageName
        self.packageURL = packageURL
        self.packageVersion = packageVersion
    }
}

struct XcodebuildErrorCaptureGroup: ErrorCaptureGroup {
    static let outputType: OutputType = .error

    /// Regular expression captured groups:
    /// $1 = whole error
    static let regex = XCRegex(pattern: #"^(xcodebuild: error:.*)$"#)

    let wholeError: String

    init?(groups: [String]) {
        assert(groups.count >= 1)
        guard let wholeError = groups[safe: 0] else { return nil }
        self.wholeError = wholeError
    }
}

struct CompilationResultCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    static let regex = XCRegex(pattern: #"^\/\* com.apple.actool.compilation-results \*\/$"#)

    init?(groups: [String]) { }
}

struct SwiftDriverJobDiscoveryEmittingModuleCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    static let regex = XCRegex(pattern: #"SwiftDriverJobDiscovery \w+ \w+ Emitting module for .* \(in target '.*' from project '.*'\)"#)

    init?(groups: [String]) { }
}

/// This output is printed when running
/// `xcodebuild test -scheme xcbeautify-Package -destination 'platform=macOS,arch=arm64'`.
struct TestingStartedCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .test

    /// Regular expression captured groups:
    /// $1 = whole message
    static let regex = XCRegex(pattern: "^(Testing started.*)$")

    let wholeMessage: String

    init?(groups: [String]) {
        assert(groups.count >= 1)
        guard let wholeMessage = groups[safe: 0] else { return nil }
        self.wholeMessage = wholeMessage
    }
}

struct SigningCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    static let regex = XCRegex(pattern: #"^Signing (.+) \(in target '(.+)' from project '(.+)'\)$"#)

    let file: String
    let target: String
    let project: String

    init?(groups: [String]) {
        assert(groups.count == 3)
        guard let file = groups[safe: 0], let target = groups[safe: 1], let project = groups[safe: 2] else { return nil }
        self.file = file
        self.target = target
        self.project = project
    }
}

struct SwiftDriverJobDiscoveryCompilingCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    // Examples:
    //  - SwiftDriverJobDiscovery normal arm64 Compiling BackyardBirdsPassOfferCard.swift (in target 'BackyardBirdsUI' from project 'BackyardBirdsUI')
    //  - SwiftDriverJobDiscovery normal arm64 Compiling BackyardSkyView.swift, BackyardSupplyGauge.swift (in target 'BackyardBirdsUI' from project 'BackyardBirdsUI')
    //  - SwiftDriverJobDiscovery normal x86_64 Compiling resource_bundle_accessor.swift, Account+DataGeneration.swift, Backyard.swift (in target 'SomeTarget' from project 'SomeProject')
    //
    // Regular expression captured groups:
    // $1 = state
    // $2 = architecture
    // $3 = filenames
    // $4 = target
    // $5 = project
    static let regex = XCRegex(pattern: #"^SwiftDriverJobDiscovery (\S+) (arm64|arm64_32|armv7k|i386|x86_64) Compiling ((?:\S|(?>, )|(?<=\\) )+) \(in target '(.*)' from project '(.*)'\)"#)

    let state: String // Currently, the only expected/known value is `normal`
    let architecture: Architecture
    let filenames: [String]
    let target: String
    let project: String

    init?(groups: [String]) {
        assert(groups.count == 5)
        guard let state = groups[safe: 0], let _architecture = groups[safe: 1], let architecture = Architecture(rawValue: _architecture), let filenamesGroup = groups[safe: 2], let target = groups[safe: 3], let project = groups[safe: 4] else { return nil }
        self.state = state
        self.architecture = architecture
        filenames = filenamesGroup.components(separatedBy: ", ")
        self.target = target
        self.project = project
    }
}

struct SwiftMergeGeneratedHeadersCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    static let regex = XCRegex(pattern: #"^SwiftMergeGeneratedHeaders (.+) \(in target '(.+)' from project '(.+)'\)$"#)

    // TODO: Split this into String array after requiring macOS 13+
    // Requires: https://github.com/cpisciotta/xcbeautify/issues/358
    let headerFilePaths: String
    let target: String
    let project: String

    init?(groups: [String]) {
        assert(groups.count == 3)
        guard let headerFilePaths = groups[safe: 0], let target = groups[safe: 1], let project = groups[safe: 2] else { return nil }
        // TODO: Split headerFilePaths by non-escaped whitespace
        // Requires: https://github.com/cpisciotta/xcbeautify/issues/358
        // assert(headerFilePaths.allSatisfy { $0.hasSuffix(".h") })
        self.headerFilePaths = headerFilePaths
        self.target = target
        self.project = project
    }
}

struct SwiftTestingRunStartedCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .result

    /// Regular expression to capture the start of a test run.
    /// $1 = message
    static let regex = XCRegex(pattern: #"^.\s+(Test run started\.)$"#)

    let message: String

    init?(groups: [String]) {
        assert(groups.count >= 1)
        guard let message = groups[safe: 0] else { return nil }
        self.message = message
    }
}

struct SwiftTestingRunCompletionCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .result

    /// Regular expression to capture the number of tests and total time.
    /// $1 = number of tests
    /// $2 = total time in seconds
    static let regex = XCRegex(pattern: #"^.\s+Test run with (\d+) test(?:s)? passed after ([\d.]+) seconds\.$"#)

    let numberOfTests: Int
    let totalTime: String

    init?(groups: [String]) {
        assert(groups.count >= 2)
        guard let numberOfTests = groups[safe: 0].flatMap(Int.init),
              let totalTime = groups[safe: 1] else { return nil }
        self.numberOfTests = numberOfTests
        self.totalTime = totalTime
    }
}

struct SwiftTestingRunFailedCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .result

    /// Regular expression to capture the number of tests, total time, and the number of issues.
    /// $1 = number of tests
    /// $2 = total time in seconds
    /// $3 = number of issues
    static let regex = XCRegex(pattern: #"^.\s+Test run with (\d+) test(?:s)? failed after ([\d.]+) seconds with (\d+) issue[s]?\.$"#)

    let numberOfTests: Int
    let totalTime: String
    let numberOfIssues: Int

    init?(groups: [String]) {
        assert(groups.count >= 3)
        guard let numberOfTests = groups[safe: 0].flatMap(Int.init),
              let totalTime = groups[safe: 1],
              let numberOfIssues = groups[safe: 2].flatMap(Int.init) else { return nil }
        self.numberOfTests = numberOfTests
        self.totalTime = totalTime
        self.numberOfIssues = numberOfIssues
    }
}

struct SwiftTestingSuiteStartedCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .test

    /// Regular expression to capture the start of a test suite.
    /// $1 = suite name
    static let regex = XCRegex(pattern: #"^.\s+Suite (.*) started\.$"#)

    let suiteName: String

    init?(groups: [String]) {
        assert(groups.count >= 1)
        guard let suiteName = groups[safe: 0] else { return nil }
        self.suiteName = suiteName
    }
}

struct SwiftTestingTestStartedCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .testCase

    /// Regular expression to capture the start of a test case.
    /// $1 = test name
    static let regex = XCRegex(pattern: #"^.\s+Test\s+(.*) started\.$"#)

    let testName: String
    let wholeMessage: String

    init?(groups: [String]) {
        assert(groups.count >= 1)
        guard let testName = groups[safe: 0] else { return nil }
        self.testName = testName
        wholeMessage = "Test \(testName) started."
    }
}

struct SwiftTestingSuitePassedCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .warning

    /// Regular expression to capture the successful completion of a test suite.
    /// $1 = suite name
    /// $2 = total time taken in seconds
    static let regex = XCRegex(pattern: #"^.\s+Suite (.*) passed after ([\d.]+) seconds\.$"#)

    let suiteName: String
    let timeTaken: String

    init?(groups: [String]) {
        assert(groups.count >= 2)
        guard let suiteName = groups[safe: 0],
              let timeTaken = groups[safe: 1] else { return nil }
        self.suiteName = suiteName
        self.timeTaken = timeTaken
    }
}

struct SwiftTestingSuiteFailedCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .result

    /// Regular expression to capture the failure of a test suite.
    /// $1 = suite name
    /// $2 = total time taken in seconds
    /// $3 = number of issues
    static let regex = XCRegex(pattern: #"^.\s+Suite (.*) failed after ([\d.]+) seconds with (\d+) issue[s]?\.$"#)

    let suiteName: String
    let timeTaken: String
    let numberOfIssues: Int

    init?(groups: [String]) {
        assert(groups.count >= 3)
        guard let suiteName = groups[safe: 0],
              let timeTaken = groups[safe: 1],
              let numberOfIssues = groups[safe: 2].flatMap(Int.init) else { return nil }
        self.suiteName = suiteName
        self.timeTaken = timeTaken
        self.numberOfIssues = numberOfIssues
    }
}

struct SwiftTestingTestFailedCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .testCase

    /// Regular expression to capture the failure of a test case.
    /// $1 = test name
    /// $2 = time taken in seconds
    /// $3 = number of issues
    static let regex = XCRegex(pattern: #"^.\s+Test (?!run\s)(.*) failed after ([\d.]+) seconds with (\d+) issue[s]?\.$"#)

    let testName: String
    let timeTaken: String
    let numberOfIssues: Int

    init?(groups: [String]) {
        assert(groups.count >= 3)
        guard let testName = groups[safe: 0],
              let timeTaken = groups[safe: 1],
              let numberOfIssues = groups[safe: 2].flatMap(Int.init) else { return nil }
        self.testName = testName
        self.timeTaken = timeTaken
        self.numberOfIssues = numberOfIssues
    }
}

struct SwiftTestingTestPassedCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .testCase

    /// Regular expression to capture the successful completion of a test case.
    /// $1 = test name
    /// $2 = time taken in seconds
    static let regex = XCRegex(pattern: #"^.*Test (?!run\s)(.*) passed after ([\d.]+) seconds\.$"#)

    let testName: String
    let timeTaken: String

    init?(groups: [String]) {
        assert(groups.count >= 2)
        guard let testName = groups[safe: 0],
              let timeTaken = groups[safe: 1] else { return nil }
        self.testName = testName
        self.timeTaken = timeTaken
    }
}

struct SwiftTestingTestSkippedCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .testCase

    /// Regular expression to capture a skipped test case.
    /// $1 = test name
    static let regex = XCRegex(pattern: #"^.\s+Test (.*) skipped\.$"#)

    let testName: String

    init?(groups: [String]) {
        assert(groups.count >= 1)
        guard let testName = groups[safe: 0] else { return nil }
        self.testName = testName
    }
}

struct SwiftTestingTestSkippedReasonCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .testCase

    /// Regular expression to capture a skipped test case with a reason.
    /// $1 = test name
    /// $2 = optional reason
    static let regex = XCRegex(pattern: #"^.\s+Test (.*) skipped(?:\s*:\s*"(.*)")?$"#)

    let testName: String
    let reason: String?

    init?(groups: [String]) {
        assert(groups.count >= 1)
        guard let testName = groups[safe: 0] else { return nil }
        self.testName = testName
        reason = groups[safe: 1]
    }
}

struct SwiftTestingIssueCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .testCase

    /// Regular expression to capture the symbol, test description, and issue details.
    /// $1 = test description
    /// $2 = issue details
    static let regex = XCRegex(pattern: #"^.\s+Test (.*?) recorded an issue(?: at (.*))?$"#)

    let testDescription: String
    let issueDetails: String?

    init?(groups: [String]) {
        assert(groups.count >= 1)
        guard let testDescription = groups[safe: 0] else { return nil }

        self.testDescription = testDescription
        issueDetails = groups[safe: 1]
    }
}

struct SwiftTestingIssueArgumentCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .testCase

    /// Regular expression to capture the symbol, test description, and optional number of arguments.
    /// $1 = test description
    /// $2 = number of arguments (optional)
    static let regex = XCRegex(pattern: #"^.\s+Test (.*?) recorded an issue(?: with (\d+) arguments?)?"#)

    let testDescription: String
    let numberOfArguments: Int?

    init?(groups: [String]) {
        assert(groups.count >= 1)
        guard let testDescription = groups[safe: 0] else { return nil }

        self.testDescription = testDescription
        numberOfArguments = groups[safe: 1].flatMap(Int.init)
    }
}

struct SwiftTestingPassingArgumentCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .testCase

    /// Regular expression to capture the symbol and number of arguments.
    /// $1 = number of arguments
    static let regex = XCRegex(pattern: #"^.\s+Passing (\d+) argument[s]?.*$"#)

    let numberOfArguments: Int

    init?(groups: [String]) {
        assert(groups.count >= 1)
        guard let numberOfArguments = groups[safe: 0].flatMap(Int.init) else { return nil }

        self.numberOfArguments = numberOfArguments
    }
}

struct SwiftDriverTargetCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    static let regex = XCRegex(pattern: #"^SwiftDriver (.*) normal (?:arm64|arm64_32|armv7k|i386|x86_64) com\.apple\.xcode\.tools\.swift\.compiler"#)

    let target: String

    init?(groups: [String]) {
        assert(groups.count == 1)
        guard let target = groups[safe: 0] else { return nil }
        self.target = target
    }
}

struct SwiftDriverCompilationTarget: CaptureGroup {
    static let outputType: OutputType = .task

    static let regex = XCRegex(pattern: #"^SwiftDriver\\ Compilation (.*) normal (?:arm64|arm64_32|armv7k|i386|x86_64) com\.apple\.xcode\.tools\.swift\.compiler"#)

    let target: String

    init?(groups: [String]) {
        assert(groups.count == 1)
        guard let target = groups[safe: 0] else { return nil }
        self.target = target
    }
}

struct SwiftDriverCompilationRequirementsCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    static let regex = XCRegex(pattern: #"^SwiftDriver\\ Compilation\\ Requirements (.*) normal (?:arm64|arm64_32|armv7k|i386|x86_64) com\.apple\.xcode\.tools\.swift\.compiler"#)

    let target: String

    init?(groups: [String]) {
        assert(groups.count == 1)
        guard let target = groups[safe: 0] else { return nil }
        self.target = target
    }
}

struct MkDirCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    static let regex = XCRegex(pattern: "^MkDir.*")

    init?(groups: [String]) { }
}

struct SwiftEmitModuleCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    static let regex = XCRegex(pattern: #"^SwiftEmitModule normal (arm64|arm64_32|armv7k|i386|x86_64) Emitting\\ module\\ for\\ (.+) \(in target '(.+)' from project '(.+)'\)$"#)

    let arch: Architecture
    let module: String
    let target: String
    let project: String

    init?(groups: [String]) {
        assert(groups.count == 4)
        guard let _arch = groups[safe: 0], let arch = Architecture(rawValue: _arch), let module = groups[safe: 1], let target = groups[safe: 2], let project = groups[safe: 3] else { return nil }
        self.arch = arch
        self.module = module
        self.target = target
        self.project = project
    }
}

struct EmitSwiftModuleCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    static let regex = XCRegex(pattern: #"^EmitSwiftModule normal (arm64|arm64_32|armv7k|i386|x86_64) \(in target '(.+)' from project '(.+)'\)$"#)

    let arch: Architecture
    let target: String
    let project: String

    init?(groups: [String]) {
        assert(groups.count == 3)
        guard let _arch = groups[safe: 0], let arch = Architecture(rawValue: _arch), let target = groups[safe: 1], let project = groups[safe: 2] else { return nil }
        self.arch = arch
        self.target = target
        self.project = project
    }
}

/// This output is printed when running
/// `xcodebuild test -scheme xcbeautify-Package -destination 'platform=macOS,arch=arm64'`.
struct NoteCaptureGroup: CaptureGroup {
    static let outputType: OutputType = .task

    /// Regular expression captured groups:
    /// $1 = note
    static let regex = XCRegex(pattern: "^note: (.*)$")

    let note: String

    init?(groups: [String]) {
        assert(groups.count == 1)
        guard let note = groups[safe: 0] else { return nil }
        self.note = note
    }
}

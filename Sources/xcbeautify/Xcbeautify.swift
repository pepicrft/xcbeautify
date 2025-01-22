import ArgumentParser
import Foundation
import XcbeautifyLib

@main
struct Xcbeautify: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A tool to format `swift` and `xcodebuild` command output.",
        discussion: "EXAMPLE: xcodebuild test ... | xcbeautify",
        version: version
    )

    enum Report: String, ExpressibleByArgument {
        case junit
    }

    @Flag(name: [.short, .long], help: "Only print tasks that have warnings or errors.")
    var quiet = false

    @Flag(name: [.long, .customLong("qq", withSingleDash: true)], help: "Only print tasks that have errors.")
    var quieter = false

    @Flag(name: [.long], help: "Preserves unbeautified output lines.")
    var preserveUnbeautified = false

    @Flag(name: .long, help: "Print test result too under quiet/quieter flag.")
    var isCI = false

    @Flag(name: .long, help: "Disable the colored output")
    var disableColoredOutput = (ProcessInfo.processInfo.environment["NO_COLOR"] != nil)

    @Flag(name: .long, help: "Suppress the xcbeautify information table when xcbeautify starts. It includes the active xcbeautify version.")
    var disableLogging = false

    // swiftformat:disable redundantReturn

    @Option(help: "Specify a renderer to format raw xcodebuild output ( options: terminal | github-actions | teamcity | azure-devops-pipelines).")
    var renderer: Renderer = {
        if ProcessInfo.processInfo.environment["GITHUB_ACTIONS"] == "true" {
            return .gitHubActions
        } else if ProcessInfo.processInfo.environment["TEAMCITY_VERSION"] != nil {
            return .teamcity
        } else if ProcessInfo.processInfo.environment["AZURE_DEVOPS_PIPELINES"] != nil {
            return .azureDevOpsPipelines
        } else {
            return .terminal
        }
    }()

    // swiftformat:enable redundantReturn

    @Option(help: "Generate the specified reports")
    var report: [Report] = []

    @Option(help: "The path to use when generating reports")
    var reportPath = "build/reports"

    @Option(help: "The name of JUnit report file name")
    var junitReportFilename = "junit.xml"

    @Option
    var minimumVersion: SemanticVersion = SemanticVersion(argument: version)!

    func validate() throws {
        guard let currentVersion = SemanticVersion(argument: version) else {
            throw ValidationError("Failed to fetch current version.")
        }

        guard currentVersion >= minimumVersion else {
            throw ValidationError("Current version is \(currentVersion), but requires \(minimumVersion).")
        }
    }

    func run() throws {
        #if DEBUG && os(macOS)
        let start = CFAbsoluteTimeGetCurrent()

        defer {
            let diff = CFAbsoluteTimeGetCurrent() - start
            print("Took \(diff) seconds")
        }
        #endif

        if !disableLogging {
            print(
                """

                ----- xcbeautify -----
                Version: \(version)
                ----------------------

                """
            )
        }

        let output = OutputHandler(quiet: quiet, quieter: quieter, isCI: isCI) { print($0) }
        let junitReporter = JunitReporter()

        func readLine() -> String? {
            let line = Swift.readLine()
            if let line {
                if report.contains(.junit) {
                    junitReporter.add(line: line)
                }
            }
            return line
        }

        let parser = Parser()

        let formatter = XcbeautifyLib.Formatter(
            colored: !disableColoredOutput,
            renderer: renderer,
            additionalLines: { readLine() }
        )

        while let line = readLine() {
            // Continue if a line is empty or only contains whitespace.
            // Create a separate variable, since passing a line with trimmed whitespace changes our ability to parse non-empty lines.
            let _line = line.trimmingCharacters(in: .whitespaces)
            guard !_line.isEmpty else { continue }

            guard let captureGroup = parser.parse(line: line) else {
                if preserveUnbeautified {
                    output.write(.undefined, line)
                }

                continue
            }
            guard let formatted = formatter.format(captureGroup: captureGroup) else { continue }
            output.write(captureGroup.outputType, formatted)
        }

        if !report.isEmpty {
            let outputPath = URL(
                fileURLWithPath: reportPath,
                relativeTo: URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            )

            try FileManager.default.createDirectory(at: outputPath, withIntermediateDirectories: true)

            for reportType in Set(report) {
                switch reportType {
                case .junit:
                    let junitOutputPath = outputPath.appendingPathComponent(junitReportFilename)
                    let report = try junitReporter.generateReport()
                    try report.write(to: junitOutputPath)
                }
            }
        }
    }
}

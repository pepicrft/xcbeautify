import Foundation

/// A renderer is responsible for formatting raw xcodebuild output.
/// `OutputRendering` defines many default implementations for output that is similarly formatted across renderers.
protocol OutputRendering {
    /// Indicates if the renderer should color its formatted output.
    var colored: Bool { get }

    /// A closure that provides the subsequent console output when needed (i.e. multi-line output).
    var additionalLines: () -> String? { get }

    func formatAnalyze(group: AnalyzeCaptureGroup) -> String
    func formatCheckDependencies() -> String
    func formatCleanRemove(group: CleanRemoveCaptureGroup) -> String
    func formatCodeSign(group: CodesignCaptureGroup) -> String
    func formatCodeSignFramework(group: CodesignFrameworkCaptureGroup) -> String
    func formatCompilationResult(group: CompilationResultCaptureGroup) -> String?
    func formatCompile(group: any CompileFileCaptureGroup) -> String
    func formatCreateUniversalBinary(group: CreateUniversalBinaryCaptureGroup) -> String
    func formatSwiftCompiling(group: SwiftCompilingCaptureGroup) -> String?
    func formatCompileCommand(group: CompileCommandCaptureGroup) -> String?
    func formatCompileError(group: CompileErrorCaptureGroup) -> String
    func formatCompileXCStrings(group: CompileXCStringsCaptureGroup) -> String
    func formatCompileWarning(group: CompileWarningCaptureGroup) -> String
    func formatCopy(group: any CopyCaptureGroup) -> String
    func formatCopyFiles(group: CopyFilesCaptureGroup) -> String
    func formatCoverageReport(group: GeneratedCoverageReportCaptureGroup) -> String
    func formatCursor(group: CursorCaptureGroup) -> String?
    func formatDetectedEncoding(group: DetectedEncodingCaptureGroup) -> String?
    func formatDuplicateLocalizedStringKey(group: DuplicateLocalizedStringKeyCaptureGroup) -> String
    func formatEmitSwiftModule(group: EmitSwiftModuleCaptureGroup) -> String?
    func formatError(group: any ErrorCaptureGroup) -> String
    func formatExecutedWithoutSkipped(group: ExecutedWithoutSkippedCaptureGroup) -> String
    func formatExecutedWithSkipped(group: ExecutedWithSkippedCaptureGroup) -> String
    func formatExplicitDependencyCaptureGroup(group: ExplicitDependencyCaptureGroup) -> String?
    func formatFailingTest(group: FailingTestCaptureGroup) -> String
    func formatFileMissingError(group: FileMissingErrorCaptureGroup) -> String
    func formatGenerateCoverageData(group: GenerateCoverageDataCaptureGroup) -> String
    func formatGenerateDsym(group: GenerateDSYMCaptureGroup) -> String
    func formatLdWarning(group: LDWarningCaptureGroup) -> String
    func formatLibtool(group: LibtoolCaptureGroup) -> String
    func formatLinkerDuplicateSymbolsError(group: LinkerDuplicateSymbolsCaptureGroup) -> String
    func formatLinkerDuplicateSymbolsLocation(group: LinkerDuplicateSymbolsLocationCaptureGroup) -> String?
    func formatLinkerUndefinedSymbolLocation(group: LinkerUndefinedSymbolLocationCaptureGroup) -> String?
    func formatLinkerUndefinedSymbolsError(group: LinkerUndefinedSymbolsCaptureGroup) -> String
    func formatLinking(group: LinkingCaptureGroup) -> String
    func formatNonPCHClangCommand(group: NonPCHClangCommandCaptureGroup) -> String?
    func formatPackageCheckingOut(group: PackageCheckingOutCaptureGroup) -> String
    func formatPackageEnd() -> String
    func formatPackageFetching(group: PackageFetchingCaptureGroup) -> String
    func formatPackageItem(group: PackageGraphResolvedItemCaptureGroup) -> String
    func formatPackageStart() -> String
    func formatPackageUpdating(group: PackageUpdatingCaptureGroup) -> String
    func formatParallelTestCaseAppKitPassed(group: ParallelTestCaseAppKitPassedCaptureGroup) -> String
    func formatParallelTestCaseFailed(group: ParallelTestCaseFailedCaptureGroup) -> String
    func formatParallelTestCasePassed(group: ParallelTestCasePassedCaptureGroup) -> String
    func formatParallelTestCaseSkipped(group: ParallelTestCaseSkippedCaptureGroup) -> String
    func formatParallelTestingFailed(group: ParallelTestingFailedCaptureGroup) -> String
    func formatParallelTestingPassed(group: ParallelTestingPassedCaptureGroup) -> String
    func formatParallelTestingStarted(group: ParallelTestingStartedCaptureGroup) -> String
    func formatParallelTestSuiteStarted(group: ParallelTestSuiteStartedCaptureGroup) -> String
    func formatPhaseScriptExecution(group: PhaseScriptExecutionCaptureGroup) -> String
    func formatPhaseSuccess(group: PhaseSuccessCaptureGroup) -> String
    func formatPrecompileModule(group: PrecompileModuleCaptureGroup) -> String?
    func formatPreprocess(group: PreprocessCaptureGroup) -> String
    func formatProcessInfoPlist(group: ProcessInfoPlistCaptureGroup) -> String
    func formatProcessPch(group: ProcessPchCaptureGroup) -> String
    func formatProcessPchCommand(group: ProcessPchCommandCaptureGroup) -> String
    func formatRegisterExecutionPolicyException(group: RegisterExecutionPolicyExceptionCaptureGroup) -> String
    func formatRestartingTest(group: RestartingTestCaptureGroup) -> String
    func formatScanDependencies(group: ScanDependenciesCaptureGroup) -> String?
    func formatShellCommand(group: ShellCommandCaptureGroup) -> String?
    func formatSigning(group: SigningCaptureGroup) -> String
    func formatSymbolReferencedFrom(group: SymbolReferencedFromCaptureGroup) -> String
    func formatTargetCommand(command: String, group: any TargetCaptureGroup) -> String
    func formatTestCaseMeasured(group: TestCaseMeasuredCaptureGroup) -> String
    func formatTestCasePassed(group: TestCasePassedCaptureGroup) -> String
    func formatTestCaseSkipped(group: TestCaseSkippedCaptureGroup) -> String
    func formatTestCasePending(group: TestCasePendingCaptureGroup) -> String
    func formatTestCasesStarted(group: TestCaseStartedCaptureGroup) -> String?
    func formatTestsRunCompletion(group: TestsRunCompletionCaptureGroup) -> String
    func formatTestSuiteAllTestsFailed(group: TestSuiteAllTestsFailedCaptureGroup) -> String
    func formatTestSuiteAllTestsPassed(group: TestSuiteAllTestsPassedCaptureGroup) -> String
    func formatTestSuiteStart(group: TestSuiteStartCaptureGroup) -> String
    func formatTestSuiteStarted(group: TestSuiteStartedCaptureGroup) -> String
    func formatTIFFUtil(group: TIFFutilCaptureGroup) -> String?
    func formatTouch(group: TouchCaptureGroup) -> String
    func formatUIFailingTest(group: UIFailingTestCaptureGroup) -> String
    func formatUndefinedSymbolLocation(group: UndefinedSymbolLocationCaptureGroup) -> String
    func formatWarning(group: GenericWarningCaptureGroup) -> String
    func formatWillNotBeCodesignWarning(group: WillNotBeCodeSignedCaptureGroup) -> String
    func formatWriteAuxiliaryFile(group: WriteAuxiliaryFileCaptureGroup) -> String?
    func formatWriteFile(group: WriteFileCaptureGroup) -> String?
    func formatSwiftDriverJobDiscoveryEmittingModule(group: SwiftDriverJobDiscoveryEmittingModuleCaptureGroup) -> String?
    func formatTestingStarted(group: TestingStartedCaptureGroup) -> String
    func formatSwiftDriverJobDiscoveryCompiling(group: SwiftDriverJobDiscoveryCompilingCaptureGroup) -> String?
    func formatSwiftEmitModule(group: SwiftEmitModuleCaptureGroup) -> String?
    func formatSwiftMergeGeneratedHeaders(group: SwiftMergeGeneratedHeadersCaptureGroup) -> String?
    func formatSwiftTestingRunStarted(group: SwiftTestingRunStartedCaptureGroup) -> String
    func formatSwiftTestingRunCompletion(group: SwiftTestingRunCompletionCaptureGroup) -> String
    func formatSwiftTestingRunFailed(group: SwiftTestingRunFailedCaptureGroup) -> String
    func formatSwiftTestingSuiteStarted(group: SwiftTestingSuiteStartedCaptureGroup) -> String
    func formatSwiftTestingTestStarted(group: SwiftTestingTestStartedCaptureGroup) -> String?
    func formatSwiftTestingSuitePassed(group: SwiftTestingSuitePassedCaptureGroup) -> String
    func formatSwiftTestingSuiteFailed(group: SwiftTestingSuiteFailedCaptureGroup) -> String
    func formatSwiftTestingTestFailed(group: SwiftTestingTestFailedCaptureGroup) -> String
    func formatSwiftTestingTestPassed(group: SwiftTestingTestPassedCaptureGroup) -> String
    func formatSwiftTestingTestSkipped(group: SwiftTestingTestSkippedCaptureGroup) -> String
    func formatSwiftTestingTestSkippedReason(group: SwiftTestingTestSkippedReasonCaptureGroup) -> String
    func formatSwiftTestingIssue(group: SwiftTestingIssueCaptureGroup) -> String
    func formatSwiftTestingIssueArguments(group: SwiftTestingIssueArgumentCaptureGroup) -> String
    func formatSwiftTestingPassingArgument(group: SwiftTestingPassingArgumentCaptureGroup) -> String?
    func formatSwiftDriverCompilationTarget(group: SwiftDriverCompilationTarget) -> String?
    func formatMkDirCaptureGroup(group: MkDirCaptureGroup) -> String?
    func formatNote(group: NoteCaptureGroup) -> String
}

extension OutputRendering {
    func formatAnalyze(group: AnalyzeCaptureGroup) -> String {
        let filename = group.filename
        let target = group.target
        return colored ? "[\(target.f.Cyan)] \("Analyzing".s.Bold) \(filename)" : "[\(target)] Analyzing \(filename)"
    }

    func formatCheckDependencies() -> String {
        colored ? "Check Dependencies".style.Bold : "Check Dependencies"
    }

    func formatCleanRemove(group: CleanRemoveCaptureGroup) -> String {
        let directory = group.directory
        return colored ? "\("Cleaning".s.Bold) \(directory)" : "Cleaning \(directory)"
    }

    func formatCodeSign(group: CodesignCaptureGroup) -> String {
        let command = "Signing"
        let sourceFile = group.file
        return colored ? command.s.Bold + " " + sourceFile.lastPathComponent : command + " " + sourceFile.lastPathComponent
    }

    func formatCodeSignFramework(group: CodesignFrameworkCaptureGroup) -> String {
        let frameworkPath = group.frameworkPath
        return colored ? "\("Signing".s.Bold) \(frameworkPath)" : "Signing \(frameworkPath)"
    }

    func formatCompile(group: any CompileFileCaptureGroup) -> String {
        let filename = group.filename
        let target = group.target
        return colored ? "[\(target.f.Cyan)] \("Compiling".s.Bold) \(filename)" : "[\(target)] Compiling \(filename)"
    }

    func formatCompileCommand(group: CompileCommandCaptureGroup) -> String? {
        nil
    }

    func formatCompileXCStrings(group: CompileXCStringsCaptureGroup) -> String {
        let filename = group.filename
        let target = group.target
        return colored ? "[\(target.f.Cyan)] \("Compile XCStrings".s.Bold) \(filename)" : "[\(target)] Compile XCStrings \(filename)"
    }

    func formatCompilationResult(group: CompilationResultCaptureGroup) -> String? {
        nil
    }

    func formatSwiftCompiling(group: SwiftCompilingCaptureGroup) -> String? {
        nil
    }

    func formatCopy(group: any CopyCaptureGroup) -> String {
        let filename = group.file
        let target = group.target
        return colored ? "[\(target.f.Cyan)] \("Copying".s.Bold) \(filename)" : "[\(target)] Copying \(filename)"
    }

    func formatCopyFiles(group: CopyFilesCaptureGroup) -> String {
        let target = group.target
        let firstFilename = group.firstFilename
        let secondFilename = group.secondFilename
        return colored ? "[\(target.f.Cyan)] \("Copy".s.Bold) \(firstFilename) -> \(secondFilename)" : "[\(target)] Copy \(firstFilename) -> \(secondFilename)"
    }

    func formatCreateUniversalBinary(group: CreateUniversalBinaryCaptureGroup) -> String {
        let target = group.target
        let filename = group.filename
        return colored ? "[\(target.f.Cyan)] \("Create Universal Binary".s.Bold) \(filename)" : "[\(target)] Create Universal Binary \(filename)"
    }

    func formatCursor(group: CursorCaptureGroup) -> String? {
        nil
    }

    func formatEmitSwiftModule(group: EmitSwiftModuleCaptureGroup) -> String? {
        nil
    }

    func formatExecutedWithoutSkipped(group: ExecutedWithoutSkippedCaptureGroup) -> String {
        group.wholeResult
    }

    func formatExecutedWithSkipped(group: ExecutedWithSkippedCaptureGroup) -> String {
        group.wholeResult
    }

    func formatExplicitDependencyCaptureGroup(group: ExplicitDependencyCaptureGroup) -> String? {
        nil
    }

    func formatGenerateCoverageData(group: GenerateCoverageDataCaptureGroup) -> String {
        colored ? "\("Generating".s.Bold) code coverage data..." : "Generating code coverage data..."
    }

    func formatCoverageReport(group: GeneratedCoverageReportCaptureGroup) -> String {
        let filePath = group.coverageReportFilePath
        return colored ? "\("Generated".s.Bold) code coverage report: \(filePath.s.Italic)" : "Generated code coverage report: \(filePath)"
    }

    func formatDetectedEncoding(group: DetectedEncodingCaptureGroup) -> String? {
        nil
    }

    func formatGenerateDsym(group: GenerateDSYMCaptureGroup) -> String {
        let dsym = group.dsym
        let target = group.target
        return colored ? "[\(target.f.Cyan)] \("Generating".s.Bold) \(dsym)" : "[\(target)] Generating \(dsym)"
    }

    func formatLibtool(group: LibtoolCaptureGroup) -> String {
        let filename = group.filename
        let target = group.target
        return colored ? "[\(target.f.Cyan)] \("Building library".s.Bold) \(filename)" : "[\(target)] Building library \(filename)"
    }

    func formatLinkerDuplicateSymbolsLocation(group: LinkerDuplicateSymbolsLocationCaptureGroup) -> String? {
        nil
    }

    func formatLinkerUndefinedSymbolLocation(group: LinkerUndefinedSymbolLocationCaptureGroup) -> String? {
        nil
    }

    func formatLinking(group: LinkingCaptureGroup) -> String {
        let target = group.target
        #if os(Linux)
        return colored ? "[\(target.f.Cyan)] \("Linking".s.Bold)" : "[\(target)] Linking"
        #else
        let filename = group.binaryFilename
        return colored ? "[\(target.f.Cyan)] \("Linking".s.Bold) \(filename)" : "[\(target)] Linking \(filename)"
        #endif
    }

    func formatNonPCHClangCommand(group: NonPCHClangCommandCaptureGroup) -> String? {
        nil
    }

    func formatPackageCheckingOut(group: PackageCheckingOutCaptureGroup) -> String {
        let version = group.version
        let package = group.package
        return colored ? "Checking out " + package.s.Bold + " @ " + version.f.Green : "Checking out \(package) @ \(version)"
    }

    func formatPackageEnd() -> String {
        colored ? "Resolved source packages".s.Bold.f.Green : "Resolved source packages"
    }

    func formatPackageFetching(group: PackageFetchingCaptureGroup) -> String {
        let source = group.source
        return "Fetching " + source
    }

    func formatPackageItem(group: PackageGraphResolvedItemCaptureGroup) -> String {
        let name = group.packageName
        let url = group.packageURL
        let version = group.packageVersion
        return colored ? name.s.Bold.f.Cyan + " - " + url.s.Bold + " @ " + version.f.Green : "\(name) - \(url) @ \(version)"
    }

    func formatPackageStart() -> String {
        colored ? "Resolving Package Graph".s.Bold.f.Cyan : "Resolving Package Graph"
    }

    func formatPackageUpdating(group: PackageUpdatingCaptureGroup) -> String {
        let source = group.source
        return "Updating " + source
    }

    func formatParallelTestingPassed(group: ParallelTestingPassedCaptureGroup) -> String {
        colored ? group.wholeMessage.s.Bold.f.Green : group.wholeMessage
    }

    func formatParallelTestSuiteStarted(group: ParallelTestSuiteStartedCaptureGroup) -> String {
        let testSuite = group.suite
        let deviceDescription = " on '\(group.device)'"
        let heading = "Test Suite \(testSuite) started\(deviceDescription)"
        return colored ? heading.s.Bold.f.Cyan : heading
    }

    func formatParallelTestingStarted(group: ParallelTestingStartedCaptureGroup) -> String {
        colored ? group.wholeMessage.s.Bold.f.Cyan : group.wholeMessage
    }

    func formatPhaseScriptExecution(group: PhaseScriptExecutionCaptureGroup) -> String {
        let phaseName = group.phaseName
        let target = group.target
        // Strip backslashed added by xcodebuild before spaces in the build phase name
        let strippedPhaseName = phaseName.replacingOccurrences(of: "\\ ", with: " ")
        return colored ? "[\(target.f.Cyan)] \("Running script".s.Bold) \(strippedPhaseName)" : "[\(target)] Running script \(strippedPhaseName)"
    }

    func formatPhaseSuccess(group: PhaseSuccessCaptureGroup) -> String {
        let phase = group.phase.capitalized
        return colored ? "\(phase) Succeeded".s.Bold.f.Green : "\(phase) Succeeded"
    }

    func formatPrecompileModule(group: PrecompileModuleCaptureGroup) -> String? {
        nil
    }

    func formatPreprocess(group: PreprocessCaptureGroup) -> String {
        let target = group.target
        let file = group.file
        return colored ? "[\(target.f.Cyan)] \("Preprocess".s.Bold) \(file)" : "[\(target)] Preprocess \(file)"
    }

    func formatProcessInfoPlist(group: ProcessInfoPlistCaptureGroup) -> String {
        let plist = group.filename

        if let target = group.target {
            // Xcode 10+ output
            return colored ? "[\(target.f.Cyan)] \("Processing".s.Bold) \(plist)" : "[\(target)] \("Processing") \(plist)"
        } else {
            // Xcode 9 output
            return colored ? "Processing".s.Bold + " " + plist : "Processing" + " " + plist
        }
    }

    func formatProcessPch(group: ProcessPchCaptureGroup) -> String {
        let filename = group.file
        let target = group.buildTarget
        return colored ? "[\(target.f.Cyan)] \("Processing".s.Bold) \(filename)" : "[\(target)] Processing \(filename)"
    }

    func formatProcessPchCommand(group: ProcessPchCommandCaptureGroup) -> String {
        let filePath = group.filePath
        return colored ? "\("Preprocessing".s.Bold) \(filePath)" : "Preprocessing \(filePath)"
    }

    func formatRegisterExecutionPolicyException(group: RegisterExecutionPolicyExceptionCaptureGroup) -> String {
        let target = group.target
        let filename = group.filename
        return colored ? "[\(target.f.Cyan)] \("RegisterExecutionPolicyException".s.Bold) \(filename)" : "[\(target)] RegisterExecutionPolicyException \(filename)"
    }

    func formatScanDependencies(group: ScanDependenciesCaptureGroup) -> String? {
        nil
    }

    func formatShellCommand(group: ShellCommandCaptureGroup) -> String? {
        nil
    }

    func formatSigning(group: SigningCaptureGroup) -> String {
        let target = group.target
        let file = group.file
        return colored ? "[\(target.f.Cyan)] \("Signing".s.Bold) \(file)" : "[\(target)] Signing \(file)"
    }

    func formatTargetCommand(command: String, group: any TargetCaptureGroup) -> String {
        let target = group.target
        let project = group.project
        let configuration = group.configuration
        return colored ? "\(command) target \(target) of project \(project) with configuration \(configuration)".s.Bold.f.Cyan : "\(command) target \(target) of project \(project) with configuration \(configuration)"
    }

    func formatTestCasePending(group: TestCasePendingCaptureGroup) -> String {
        let testCase = group.testCase
        return colored ? Format.indent + TestStatus.pending.foreground.Yellow + " " + testCase + " [PENDING]" : Format.indent + TestStatus.pending + " " + testCase + " [PENDING]"
    }

    func formatTestCasesStarted(group: TestCaseStartedCaptureGroup) -> String? {
        nil
    }

    func formatTestsRunCompletion(group: TestsRunCompletionCaptureGroup) -> String {
        group.wholeResult
    }

    func formatTestSuiteAllTestsFailed(group: TestSuiteAllTestsFailedCaptureGroup) -> String {
        group.wholeResult
    }

    func formatTestSuiteAllTestsPassed(group: TestSuiteAllTestsPassedCaptureGroup) -> String {
        group.wholeResult
    }

    func formatTestSuiteStart(group: TestSuiteStartCaptureGroup) -> String {
        let testSuite = group.testSuiteName
        return colored ? testSuite.s.Bold : testSuite
    }

    func formatTestSuiteStarted(group: TestSuiteStartedCaptureGroup) -> String {
        let testSuite = group.suite
        let heading = "Test Suite \(testSuite) started"
        return colored ? heading.s.Bold.f.Cyan : heading
    }

    func formatTIFFUtil(group: TIFFutilCaptureGroup) -> String? {
        nil
    }

    func formatTouch(group: TouchCaptureGroup) -> String {
        let filename = group.filename
        let target = group.target
        return colored ? "[\(target.f.Cyan)] \("Touching".s.Bold) \(filename)" : "[\(target)] Touching \(filename)"
    }

    func formatWriteAuxiliaryFile(group: WriteAuxiliaryFileCaptureGroup) -> String? {
        let filename = group.filename
        let target = group.target
        return colored ? "[\(target.f.Cyan)] \("Write Auxiliary File".s.Bold) \(filename)" : "[\(target)] Write Auxiliary File \(filename)"
    }

    func formatWriteFile(group: WriteFileCaptureGroup) -> String? {
        nil
    }

    func formatSwiftDriverJobDiscoveryEmittingModule(group: SwiftDriverJobDiscoveryEmittingModuleCaptureGroup) -> String? {
        nil
    }

    func formatSwiftDriverJobDiscoveryCompiling(group: SwiftDriverJobDiscoveryCompilingCaptureGroup) -> String? {
        nil
    }

    func formatFailingTest(group: FailingTestCaptureGroup) -> String {
        let testCase = group.testCase
        let failingReason = group.reason
        return colored ? Format.indent + TestStatus.fail.foreground.Red + " " + testCase + ", " + failingReason : Format.indent + TestStatus.fail + " " + testCase + ", " + failingReason
    }

    func formatUIFailingTest(group: UIFailingTestCaptureGroup) -> String {
        let file = group.file
        let failingReason = group.reason
        return colored ? Format.indent + TestStatus.fail.foreground.Red + " " + file + ", " + failingReason : Format.indent + TestStatus.fail + " " + file + ", " + failingReason
    }

    func formatRestartingTest(group: RestartingTestCaptureGroup) -> String {
        colored ? Format.indent + TestStatus.fail.foreground.Red + " " + group.wholeMessage : Format.indent + TestStatus.fail + " " + group.wholeMessage
    }

    func formatTestCaseMeasured(group: TestCaseMeasuredCaptureGroup) -> String {
        let testCase = group.testCase
        let name = group.name
        let unitName = group.unitName
        let value = group.value

        let deviation = colored ? group.deviation.coloredDeviation() : group.deviation
        let formattedValue = colored && unitName == "seconds" ? value.coloredTime() : value

        return Format.indent + (colored ? TestStatus.measure.foreground.Yellow : TestStatus.measure) + " " + testCase + " measured (\(formattedValue) \(unitName) ±\(deviation)% -- \(name))"
    }

    func formatTestCasePassed(group: TestCasePassedCaptureGroup) -> String {
        let testCase = group.testCase
        let time = group.time
        return colored ? Format.indent + TestStatus.pass.foreground.Green + " " + testCase + " (\(time.coloredTime()) seconds)" : Format.indent + TestStatus.pass + " " + testCase + " (\(time) seconds)"
    }

    func formatTestCaseSkipped(group: TestCaseSkippedCaptureGroup) -> String {
        let testCase = group.testCase
        let time = group.time
        return colored ? Format.indent + TestStatus.skipped.foreground.Yellow + " " + testCase + " (\(time.coloredTime()) seconds)" : Format.indent + TestStatus.skipped + " " + testCase + " (\(time) seconds)"
    }

    func formatParallelTestCasePassed(group: ParallelTestCasePassedCaptureGroup) -> String {
        let suite = group.suite
        let testCase = group.testCase
        let device = group.device
        let time = group.time

        return formatParallelTestCase(result: TestStatus.pass, suite: suite, testCase: testCase, device: device, time: time)
    }

    func formatParallelTestCaseSkipped(group: ParallelTestCaseSkippedCaptureGroup) -> String {
        let suite = group.suite
        let testCase = group.testCase
        let device = group.device
        let time = group.time

        return formatParallelTestCase(result: TestStatus.skipped, suite: suite, testCase: testCase, device: device, time: time)
    }

    func formatParallelTestCaseAppKitPassed(group: ParallelTestCaseAppKitPassedCaptureGroup) -> String {
        let suite = group.suite
        let testCase = group.testCase
        let time = group.time

        return formatParallelTestCase(result: TestStatus.pass, suite: suite, testCase: testCase, device: nil, time: time)
    }

    func formatParallelTestCaseFailed(group: ParallelTestCaseFailedCaptureGroup) -> String {
        let suite = group.suite
        let testCase = group.testCase
        let device = group.device
        let time = group.time

        return formatParallelTestCase(result: TestStatus.fail, suite: suite, testCase: testCase, device: device, time: time)
    }

    private func formatParallelTestCase(
        result: String,
        suite: String,
        testCase: String,
        device: String?,
        time: String
    ) -> String {
        let deviceString = device.map { " on '\($0)'" } ?? ""

        let styledResult: String
        switch result {
        case TestStatus.pass:
            styledResult = result.f.Green
        case TestStatus.fail:
            styledResult = result.f.Red
        case TestStatus.skipped:
            styledResult = result.f.Yellow
        default:
            assertionFailure("Unexpected result: \(result)")
            styledResult = result
        }

        return colored
            ? Format.indent + styledResult + " [" + suite.f.Cyan + "] " + testCase + deviceString + " (\(time.coloredTime()) seconds)"
            : Format.indent + result + " [" + suite + "] " + testCase + deviceString + " (\(time) seconds)"
    }

    func formatError(group: any ErrorCaptureGroup) -> String {
        let errorMessage = group.wholeError
        return colored ? Symbol.error + " " + errorMessage.f.Red : Symbol.asciiError + " " + errorMessage
    }

    func formatSymbolReferencedFrom(group: SymbolReferencedFromCaptureGroup) -> String {
        colored ? Symbol.error + " " + group.wholeError.f.Red : Symbol.asciiError + " " + group.wholeError
    }

    func formatCompileError(group: CompileErrorCaptureGroup) -> String {
        let filePath = group.filePath
        let reason = group.reason

        // Read 2 additional lines to get the error line and cursor position
        let line: String = additionalLines() ?? ""
        let cursor: String = additionalLines() ?? ""
        return colored ?
            """
            \(Symbol.error) \(filePath): \(reason.f.Red)
            \(line)
            \(cursor.f.Cyan)
            """
            :
            """
            \(Symbol.asciiError) \(filePath): \(reason)
            \(line)
            \(cursor)
            """
    }

    func formatFileMissingError(group: FileMissingErrorCaptureGroup) -> String {
        let reason = group.reason
        let filePath = group.filePath
        return colored ? "\(Symbol.error) \(filePath): \(reason.f.Red)" : "\(Symbol.asciiError) \(filePath): \(reason)"
    }

    func formatWarning(group: GenericWarningCaptureGroup) -> String {
        let warningMessage = group.wholeWarning
        return colored ? Symbol.warning + " " + warningMessage.f.Yellow : Symbol.asciiWarning + " " + warningMessage
    }

    func formatUndefinedSymbolLocation(group: UndefinedSymbolLocationCaptureGroup) -> String {
        colored ? Symbol.warning + " " + group.wholeWarning.f.Yellow : Symbol.asciiWarning + " " + group.wholeWarning
    }

    func formatCompileWarning(group: CompileWarningCaptureGroup) -> String {
        let filePath = group.filePath
        let reason = group.reason

        // Read 2 additional lines to get the warning line and cursor position
        let line: String = additionalLines() ?? ""
        let cursor: String = additionalLines() ?? ""
        return colored ?
            """
            \(Symbol.warning)  \(filePath): \(reason.f.Yellow)
            \(line)
            \(cursor.f.Green)
            """
            :
            """
            \(Symbol.asciiWarning)  \(filePath): \(reason)
            \(line)
            \(cursor)
            """
    }

    func formatLdWarning(group: LDWarningCaptureGroup) -> String {
        let prefix = group.ldPrefix
        let message = group.warningMessage
        return colored ? "\(Symbol.warning) \(prefix.f.Yellow)\(message.f.Yellow)" : "\(Symbol.asciiWarning) \(prefix)\(message)"
    }

    func formatLinkerUndefinedSymbolsError(group: LinkerUndefinedSymbolsCaptureGroup) -> String {
        let reason = group.reason
        return colored ? "\(Symbol.error) \(reason.f.Red)" : "\(Symbol.asciiError) \(reason)"
    }

    // TODO: Print file path
    func formatLinkerDuplicateSymbolsError(group: LinkerDuplicateSymbolsCaptureGroup) -> String {
        let reason = group.reason
        return colored ? "\(Symbol.error) \(reason.f.Red)" : "\(Symbol.asciiError) \(reason)"
    }

    func formatWillNotBeCodesignWarning(group: WillNotBeCodeSignedCaptureGroup) -> String {
        let warningMessage = group.wholeWarning
        return colored ? Symbol.warning + " " + warningMessage.f.Yellow : Symbol.asciiWarning + " " + warningMessage
    }

    func formatSummary(line: String) -> String {
        colored ? line.f.Green.s.Bold : line
    }

    func formatDuplicateLocalizedStringKey(group: DuplicateLocalizedStringKeyCaptureGroup) -> String {
        let message = group.warningMessage
        return colored ? Symbol.warning + " " + message.f.Yellow : Symbol.asciiWarning + " " + message
    }

    func formatParallelTestingFailed(group: ParallelTestingFailedCaptureGroup) -> String {
        colored ? group.wholeError.s.Bold.f.Red : group.wholeError
    }

    func formatTestingStarted(group: TestingStartedCaptureGroup) -> String {
        colored ? group.wholeMessage.s.Bold.f.Cyan : group.wholeMessage
    }

    func formatSwiftEmitModule(group: SwiftEmitModuleCaptureGroup) -> String? {
        nil
    }

    func formatSwiftMergeGeneratedHeaders(group: SwiftMergeGeneratedHeadersCaptureGroup) -> String? {
        nil
    }

    func formatSwiftTestingRunStarted(group: SwiftTestingRunStartedCaptureGroup) -> String {
        colored ? group.message.s.Bold : group.message
    }

    func formatSwiftTestingRunCompletion(group: SwiftTestingRunCompletionCaptureGroup) -> String {
        "Test run with \(group.numberOfTests) tests passed after \(group.totalTime) seconds"
    }

    func formatSwiftTestingRunFailed(group: SwiftTestingRunFailedCaptureGroup) -> String {
        "Test run with \(group.numberOfTests) tests failed after \(group.totalTime) seconds with \(group.numberOfIssues) issue(s)"
    }

    func formatSwiftTestingSuiteStarted(group: SwiftTestingSuiteStartedCaptureGroup) -> String {
        "Suite \(group.suiteName) started"
    }

    func formatSwiftTestingTestStarted(group: SwiftTestingTestStartedCaptureGroup) -> String? {
        nil
    }

    func formatSwiftTestingSuitePassed(group: SwiftTestingSuitePassedCaptureGroup) -> String {
        "Suite \(group.suiteName) passed after \(group.timeTaken) seconds"
    }

    func formatSwiftTestingSuiteFailed(group: SwiftTestingSuiteFailedCaptureGroup) -> String {
        "Suite \(group.suiteName) failed after \(group.timeTaken) seconds with \(group.numberOfIssues) issue(s)"
    }

    func formatSwiftTestingTestFailed(group: SwiftTestingTestFailedCaptureGroup) -> String {
        let message = "\(group.testName) (\(group.timeTaken) seconds) \(group.numberOfIssues) issue(s)"
        let wholeMessage = colored ? TestStatus.fail.foreground.Red + " " + message.f.Red : TestStatus.fail + " " + message
        return Format.indent + wholeMessage
    }

    func formatSwiftTestingTestPassed(group: SwiftTestingTestPassedCaptureGroup) -> String {
        let testName = group.testName
        let timeTaken = group.timeTaken
        return colored ? Format.indent + TestStatus.pass.foreground.Green + " " + testName + " (\(timeTaken.coloredTime()) seconds)" : Format.indent + TestStatus.pass + " " + testName + " (\(timeTaken) seconds)"
    }

    func formatSwiftTestingTestSkipped(group: SwiftTestingTestSkippedCaptureGroup) -> String {
        let testName = group.testName + " skipped"
        return colored ? Format.indent + TestStatus.skipped.foreground.Yellow + " " + testName : Format.indent + TestStatus.skipped + " " + testName
    }

    func formatSwiftTestingTestSkippedReason(group: SwiftTestingTestSkippedReasonCaptureGroup) -> String {
        let testName = group.testName + " skipped"
        let reason = group.reason.map { " (\(String($0)))" } ?? ""
        return colored ? Format.indent + TestStatus.skipped.foreground.Yellow + " " + testName + reason : Format.indent + TestStatus.skipped + " " + testName + reason
    }

    func formatSwiftTestingIssue(group: SwiftTestingIssueCaptureGroup) -> String {
        let issueDetails = group.issueDetails.map { " at \($0)" } ?? ""
        let message = " Test \(group.testDescription) recorded an issue\(issueDetails)"
        return colored ? Format.indent + Symbol.warning.f.Yellow + " " + message : Format.indent + Symbol.asciiWarning + " " + message
    }

    func formatSwiftTestingIssueArguments(group: SwiftTestingIssueArgumentCaptureGroup) -> String {
        let argumentsInfo = group.numberOfArguments.map { " with \($0) argument(s)" } ?? ""
        let message = " Test \(group.testDescription) recorded an issue\(argumentsInfo)"
        return colored ? Format.indent + Symbol.warning.f.Yellow + " " + message : Format.indent + Symbol.asciiWarning + " " + message
    }

    func formatSwiftTestingPassingArgument(group: SwiftTestingPassingArgumentCaptureGroup) -> String? {
        nil
    }

    func formatSwiftDriverTarget(group: SwiftDriverTargetCaptureGroup) -> String? {
        nil
    }

    func formatSwiftDriverCompilationTarget(group: SwiftDriverCompilationTarget) -> String? {
        nil
    }

    func formatSwiftDriverCompilationRequirements(group: SwiftDriverCompilationRequirementsCaptureGroup) -> String? {
        nil
    }

    func formatMkDirCaptureGroup(group: MkDirCaptureGroup) -> String? {
        nil
    }

    func formatNote(group: NoteCaptureGroup) -> String {
        colored ? "note: ".s.Bold.f.Cyan + group.note : "note: " + group.note
    }
}

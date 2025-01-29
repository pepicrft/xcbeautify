import Foundation

/// Formats `CaptureGroup` instances appropriate for the specified `renderer` context.
package struct Formatter {
    private let colored: Bool
    private let renderer: any OutputRendering

    package init(
        colored: Bool,
        renderer: Renderer,
        additionalLines: @escaping () -> (String?)
    ) {
        self.colored = colored

        switch renderer {
        case .terminal:
            self.renderer = TerminalRenderer(colored: colored, additionalLines: additionalLines)
        case .gitHubActions:
            self.renderer = GitHubActionsRenderer(colored: colored, additionalLines: additionalLines)
        case .teamcity:
            self.renderer = TeamCityRenderer(colored: colored, additionalLines: additionalLines)
        case .azureDevOpsPipelines:
            self.renderer = AzureDevOpsPipelinesRenderer(colored: colored, additionalLines: additionalLines)
        }
    }

    package func format(captureGroup: any CaptureGroup) -> String? {
        switch captureGroup {
        case let group as AggregateTargetCaptureGroup:
            return renderer.formatTargetCommand(command: "Aggregate", group: group)
        case let group as AnalyzeCaptureGroup:
            return renderer.formatAnalyze(group: group)
        case let group as AnalyzeTargetCaptureGroup:
            return renderer.formatTargetCommand(command: "Analyze", group: group)
        case let group as BuildTargetCaptureGroup:
            return renderer.formatTargetCommand(command: "Build", group: group)
        case is CheckDependenciesCaptureGroup:
            return renderer.formatCheckDependencies()
        case let group as CheckDependenciesErrorsCaptureGroup:
            return renderer.formatError(group: group)
        case let group as NonPCHClangCommandCaptureGroup:
            return renderer.formatNonPCHClangCommand(group: group)
        case let group as ClangErrorCaptureGroup:
            return renderer.formatError(group: group)
        case let group as CleanRemoveCaptureGroup:
            return renderer.formatCleanRemove(group: group)
        case let group as CleanTargetCaptureGroup:
            return renderer.formatTargetCommand(command: "Clean", group: group)
        case let group as CodesignCaptureGroup:
            return renderer.formatCodeSign(group: group)
        case let group as CodesignFrameworkCaptureGroup:
            return renderer.formatCodeSignFramework(group: group)
        case let group as CompilationResultCaptureGroup:
            return renderer.formatCompilationResult(group: group)
        case let group as CompileCaptureGroup:
            return renderer.formatCompile(group: group)
        case let group as SwiftCompileCaptureGroup:
            return renderer.formatCompile(group: group)
        case let group as SwiftCompilingCaptureGroup:
            return renderer.formatSwiftCompiling(group: group)
        case let group as CompileCommandCaptureGroup:
            return renderer.formatCompileCommand(group: group)
        case let group as CompileErrorCaptureGroup:
            return renderer.formatCompileError(group: group)
        case let group as CompileStoryboardCaptureGroup:
            return renderer.formatCompile(group: group)
        case let group as CompileWarningCaptureGroup:
            return renderer.formatCompileWarning(group: group)
        case let group as CompileXCStringsCaptureGroup:
            return renderer.formatCompileXCStrings(group: group)
        case let group as CompileXibCaptureGroup:
            return renderer.formatCompile(group: group)
        case let group as CopyFilesCaptureGroup:
            return renderer.formatCopyFiles(group: group)
        case let group as CopyHeaderCaptureGroup:
            return renderer.formatCopy(group: group)
        case let group as CopyPlistCaptureGroup:
            return renderer.formatCopy(group: group)
        case let group as CopyStringsCaptureGroup:
            return renderer.formatCopy(group: group)
        case let group as CpresourceCaptureGroup:
            return renderer.formatCopy(group: group)
        case let group as CreateUniversalBinaryCaptureGroup:
            return renderer.formatCreateUniversalBinary(group: group)
        case let group as CursorCaptureGroup:
            return renderer.formatCursor(group: group)
        case let group as DetectedEncodingCaptureGroup:
            return renderer.formatDetectedEncoding(group: group)
        case let group as DuplicateLocalizedStringKeyCaptureGroup:
            return renderer.formatDuplicateLocalizedStringKey(group: group)
        case let group as EmitSwiftModuleCaptureGroup:
            return renderer.formatEmitSwiftModule(group: group)
        case let group as ExecutedWithoutSkippedCaptureGroup:
            return renderer.formatExecutedWithoutSkipped(group: group)
        case let group as ExecutedWithSkippedCaptureGroup:
            return renderer.formatExecutedWithSkipped(group: group)
        case let group as ExplicitDependencyCaptureGroup:
            return renderer.formatExplicitDependencyCaptureGroup(group: group)
        case let group as FailingTestCaptureGroup:
            return renderer.formatFailingTest(group: group)
        case let group as FatalErrorCaptureGroup:
            return renderer.formatError(group: group)
        case let group as FileMissingErrorCaptureGroup:
            return renderer.formatFileMissingError(group: group)
        case let group as GenerateCoverageDataCaptureGroup:
            return renderer.formatGenerateCoverageData(group: group)
        case let group as GeneratedCoverageReportCaptureGroup:
            return renderer.formatCoverageReport(group: group)
        case let group as GenerateDSYMCaptureGroup:
            return renderer.formatGenerateDsym(group: group)
        case let group as GenericWarningCaptureGroup:
            return renderer.formatWarning(group: group)
        case let group as LDErrorCaptureGroup:
            return renderer.formatError(group: group)
        case let group as LDWarningCaptureGroup:
            return renderer.formatLdWarning(group: group)
        case let group as LibtoolCaptureGroup:
            return renderer.formatLibtool(group: group)
        case let group as LinkerDuplicateSymbolsCaptureGroup:
            return renderer.formatLinkerDuplicateSymbolsError(group: group)
        case let group as LinkerDuplicateSymbolsLocationCaptureGroup:
            return renderer.formatLinkerDuplicateSymbolsLocation(group: group)
        case let group as LinkerUndefinedSymbolLocationCaptureGroup:
            return renderer.formatLinkerUndefinedSymbolLocation(group: group)
        case let group as LinkerUndefinedSymbolsCaptureGroup:
            return renderer.formatLinkerUndefinedSymbolsError(group: group)
        case let group as LinkingCaptureGroup:
            return renderer.formatLinking(group: group)
        case let group as ModuleIncludesErrorCaptureGroup:
            return renderer.formatError(group: group)
        case let group as NoCertificateCaptureGroup:
            return renderer.formatError(group: group)
        case let group as PackageCheckingOutCaptureGroup:
            return renderer.formatPackageCheckingOut(group: group)
        case let group as PackageFetchingCaptureGroup:
            return renderer.formatPackageFetching(group: group)
        case let group as PackageGraphResolvedItemCaptureGroup:
            return renderer.formatPackageItem(group: group)
        case is PackageGraphResolvingEndedCaptureGroup:
            return renderer.formatPackageEnd()
        case is PackageGraphResolvingStartCaptureGroup:
            return renderer.formatPackageStart()
        case let group as PackageUpdatingCaptureGroup:
            return renderer.formatPackageUpdating(group: group)
        case let group as ParallelTestCaseAppKitPassedCaptureGroup:
            return renderer.formatParallelTestCaseAppKitPassed(group: group)
        case let group as ParallelTestCaseFailedCaptureGroup:
            return renderer.formatParallelTestCaseFailed(group: group)
        case let group as ParallelTestCasePassedCaptureGroup:
            return renderer.formatParallelTestCasePassed(group: group)
        case let group as ParallelTestCaseSkippedCaptureGroup:
            return renderer.formatParallelTestCaseSkipped(group: group)
        case let group as ParallelTestingFailedCaptureGroup:
            return renderer.formatParallelTestingFailed(group: group)
        case let group as ParallelTestingPassedCaptureGroup:
            return renderer.formatParallelTestingPassed(group: group)
        case let group as ParallelTestingStartedCaptureGroup:
            return renderer.formatParallelTestingStarted(group: group)
        case let group as ParallelTestSuiteStartedCaptureGroup:
            return renderer.formatParallelTestSuiteStarted(group: group)
        case let group as PbxcpCaptureGroup:
            return renderer.formatCopy(group: group)
        case let group as PhaseScriptExecutionCaptureGroup:
            return renderer.formatPhaseScriptExecution(group: group)
        case let group as PhaseSuccessCaptureGroup:
            return renderer.formatPhaseSuccess(group: group)
        case let group as PodsErrorCaptureGroup:
            return renderer.formatError(group: group)
        case let group as PrecompileModuleCaptureGroup:
            return renderer.formatPrecompileModule(group: group)
        case let group as PreprocessCaptureGroup:
            return renderer.formatPreprocess(group: group)
        case let group as ProcessInfoPlistCaptureGroup:
            return renderer.formatProcessInfoPlist(group: group)
        case let group as ProcessPchCaptureGroup:
            return renderer.formatProcessPch(group: group)
        case let group as ProcessPchCommandCaptureGroup:
            return renderer.formatProcessPchCommand(group: group)
        case let group as ProvisioningProfileRequiredCaptureGroup:
            return renderer.formatError(group: group)
        case let group as RegisterExecutionPolicyExceptionCaptureGroup:
            return renderer.formatRegisterExecutionPolicyException(group: group)
        case let group as RestartingTestCaptureGroup:
            return renderer.formatRestartingTest(group: group)
        case let group as ScanDependenciesCaptureGroup:
            return renderer.formatScanDependencies(group: group)
        case let group as ShellCommandCaptureGroup:
            return renderer.formatShellCommand(group: group)
        case let group as SigningCaptureGroup:
            return renderer.formatSigning(group: group)
        case let group as SymbolReferencedFromCaptureGroup:
            return renderer.formatSymbolReferencedFrom(group: group)
        case let group as TestCaseMeasuredCaptureGroup:
            return renderer.formatTestCaseMeasured(group: group)
        case let group as TestCasePassedCaptureGroup:
            return renderer.formatTestCasePassed(group: group)
        case let group as TestCaseSkippedCaptureGroup:
            return renderer.formatTestCaseSkipped(group: group)
        case let group as TestCasePendingCaptureGroup:
            return renderer.formatTestCasePending(group: group)
        case let group as TestCaseStartedCaptureGroup:
            return renderer.formatTestCasesStarted(group: group)
        case let group as TestsRunCompletionCaptureGroup:
            return renderer.formatTestsRunCompletion(group: group)
        case let group as TestSuiteAllTestsFailedCaptureGroup:
            return renderer.formatTestSuiteAllTestsFailed(group: group)
        case let group as TestSuiteAllTestsPassedCaptureGroup:
            return renderer.formatTestSuiteAllTestsPassed(group: group)
        case let group as TestSuiteStartCaptureGroup:
            return renderer.formatTestSuiteStart(group: group)
        case let group as TestSuiteStartedCaptureGroup:
            return renderer.formatTestSuiteStarted(group: group)
        case let group as TIFFutilCaptureGroup:
            return renderer.formatTIFFUtil(group: group)
        case let group as TouchCaptureGroup:
            return renderer.formatTouch(group: group)
        case let group as UIFailingTestCaptureGroup:
            return renderer.formatUIFailingTest(group: group)
        case let group as UndefinedSymbolLocationCaptureGroup:
            return renderer.formatUndefinedSymbolLocation(group: group)
        case let group as WillNotBeCodeSignedCaptureGroup:
            return renderer.formatWillNotBeCodesignWarning(group: group)
        case let group as WriteAuxiliaryFileCaptureGroup:
            return renderer.formatWriteAuxiliaryFile(group: group)
        case let group as WriteFileCaptureGroup:
            return renderer.formatWriteFile(group: group)
        case let group as XcodebuildErrorCaptureGroup:
            return renderer.formatError(group: group)
        case let group as SwiftDriverJobDiscoveryEmittingModuleCaptureGroup:
            return renderer.formatSwiftDriverJobDiscoveryEmittingModule(group: group)
        case let group as SwiftDriverJobDiscoveryCompilingCaptureGroup:
            return renderer.formatSwiftDriverJobDiscoveryCompiling(group: group)
        case let group as SwiftEmitModuleCaptureGroup:
            return renderer.formatSwiftEmitModule(group: group)
        case let group as SwiftMergeGeneratedHeadersCaptureGroup:
            return renderer.formatSwiftMergeGeneratedHeaders(group: group)
        case let group as TestingStartedCaptureGroup:
            return renderer.formatTestingStarted(group: group)
        case let group as SwiftTestingRunStartedCaptureGroup:
            return renderer.formatSwiftTestingRunStarted(group: group)
        case let group as SwiftTestingRunCompletionCaptureGroup:
            return renderer.formatSwiftTestingRunCompletion(group: group)
        case let group as SwiftTestingRunFailedCaptureGroup:
            return renderer.formatSwiftTestingRunFailed(group: group)
        case let group as SwiftTestingSuiteStartedCaptureGroup:
            return renderer.formatSwiftTestingSuiteStarted(group: group)
        case let group as SwiftTestingSuitePassedCaptureGroup:
            return renderer.formatSwiftTestingSuitePassed(group: group)
        case let group as SwiftTestingSuiteFailedCaptureGroup:
            return renderer.formatSwiftTestingSuiteFailed(group: group)
        case let group as SwiftTestingTestStartedCaptureGroup:
            return renderer.formatSwiftTestingTestStarted(group: group)
        case let group as SwiftTestingTestPassedCaptureGroup:
            return renderer.formatSwiftTestingTestPassed(group: group)
        case let group as SwiftTestingTestFailedCaptureGroup:
            return renderer.formatSwiftTestingTestFailed(group: group)
        case let group as SwiftTestingTestSkippedCaptureGroup:
            return renderer.formatSwiftTestingTestSkipped(group: group)
        case let group as SwiftTestingTestSkippedReasonCaptureGroup:
            return renderer.formatSwiftTestingTestSkippedReason(group: group)
        case let group as SwiftTestingIssueCaptureGroup:
            return renderer.formatSwiftTestingIssue(group: group)
        case let group as SwiftTestingIssueArgumentCaptureGroup:
            return renderer.formatSwiftTestingIssueArguments(group: group)
        case let group as SwiftTestingPassingArgumentCaptureGroup:
            return renderer.formatSwiftTestingPassingArgument(group: group)
        case let group as SwiftDriverTargetCaptureGroup:
            return renderer.formatSwiftDriverTarget(group: group)
        case let group as SwiftDriverCompilationTarget:
            return renderer.formatSwiftDriverCompilationTarget(group: group)
        case let group as SwiftDriverCompilationRequirementsCaptureGroup:
            return renderer.formatSwiftDriverCompilationRequirements(group: group)
        case let group as MkDirCaptureGroup:
            return renderer.formatMkDirCaptureGroup(group: group)
        case let group as NoteCaptureGroup:
            return renderer.formatNote(group: group)
        default:
            assertionFailure()
            return nil
        }
    }
}

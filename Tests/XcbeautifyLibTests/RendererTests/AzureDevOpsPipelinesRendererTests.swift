import XCTest
@testable import XcbeautifyLib

final class AzureDevOpsPipelinesRendererTests: XCTestCase {
    private var parser: Parser!
    private var formatter: XcbeautifyLib.Formatter!

    override func setUpWithError() throws {
        try super.setUpWithError()

        parser = Parser()
        formatter = Formatter(colored: false, renderer: .azureDevOpsPipelines, additionalLines: { nil })
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        parser = nil
        formatter = nil
    }

    private func logFormatted(_ string: String) -> String? {
        guard let captureGroup = parser.parse(line: string) else { return nil }
        return formatter.format(captureGroup: captureGroup)
    }

    func testAggregateTarget() {
        let formatted = logFormatted("=== BUILD AGGREGATE TARGET Be Aggro OF PROJECT AggregateExample WITH CONFIGURATION Debug ===")
        XCTAssertEqual(formatted, "Aggregate target Be Aggro of project AggregateExample with configuration Debug")
    }

    func testAnalyze() {
        let formatted = logFormatted("AnalyzeShallow /Users/admin/CocoaLumberjack/Classes/DDTTYLogger.m normal x86_64 (in target: CocoaLumberjack-Static)")
        XCTAssertEqual(formatted, "[CocoaLumberjack-Static] Analyzing DDTTYLogger.m")
    }

    func testAnalyzeTarget() {
        let formatted = logFormatted("=== ANALYZE TARGET The Spacer OF PROJECT Pods WITH THE DEFAULT CONFIGURATION Debug ===")
        XCTAssertEqual(formatted, "Analyze target The Spacer of project Pods with configuration Debug")
    }

    func testBuildTarget() {
        let formatted = logFormatted("=== BUILD TARGET The Spacer OF PROJECT Pods WITH THE DEFAULT CONFIGURATION Debug ===")
        XCTAssertEqual(formatted, "Build target The Spacer of project Pods with configuration Debug")
    }

    func testCheckDependenciesErrors() { }

    func testCheckDependencies() {
        let command = "Check Dependencies"
        let formatted = logFormatted(command)
        XCTAssertEqual(formatted, command)
    }

    func testClangError() {
        let formatted = logFormatted("clang: error: linker command failed with exit code 1 (use -v to see invocation)")
        XCTAssertEqual(formatted, "##vso[task.logissue type=error]clang: error: linker command failed with exit code 1 (use -v to see invocation)")
    }

    func testCleanRemove() {
        let formatted = logFormatted("Clean.Remove clean /Users/admin/Library/Developer/Xcode/DerivedData/MyLibrary-abcd/Build/Intermediates/MyLibrary.build/Debug-iphonesimulator/MyLibraryTests.build")
        XCTAssertEqual(formatted, "Cleaning MyLibraryTests.build")
    }

    func testCleanTarget() {
        let formatted = logFormatted("=== ANALYZE TARGET The Spacer OF PROJECT Pods WITH THE DEFAULT CONFIGURATION Debug ===")
        XCTAssertEqual(formatted, "Analyze target The Spacer of project Pods with configuration Debug")
    }

    func testCodesignFramework() {
        let formatted = logFormatted("CodeSign build/Release/MyFramework.framework/Versions/A")
        XCTAssertEqual(formatted, "Signing build/Release/MyFramework.framework")
    }

    func testCodesign() {
        let formatted = logFormatted("CodeSign build/Release/MyApp.app")
        XCTAssertEqual(formatted, "Signing MyApp.app")
    }

    func testCreateUniversalBinary() {
        let formatted = logFormatted(#"CreateUniversalBinary /Backyard-Birds/Build/Products/Debug/BackyardBirdsData.o normal arm64\ x86_64 (in target 'BackyardBirdsDataTarget' from project 'BackyardBirdsDataProject')"#)
        XCTAssertEqual(formatted, "[BackyardBirdsDataTarget] Create Universal Binary BackyardBirdsData.o")
    }

    func testMultipleCodesigns() {
        let formattedApp = logFormatted("CodeSign build/Release/MyApp.app")
        let formattedFramework = logFormatted("CodeSign build/Release/MyFramework.framework/Versions/A (in target 'X' from project 'Y')")
        XCTAssertEqual(formattedApp, "Signing MyApp.app")
        XCTAssertEqual(formattedFramework, "Signing build/Release/MyFramework.framework")
    }

    func testCompileCommand() { }

    func testCompileError() {
        let inputError = "/path/file.swift:64:69: error: cannot find 'input' in scope"
        let outputError = "##vso[task.logissue type=error;sourcepath=/path/file.swift;linenumber=64;columnnumber=69]cannot find 'input' in scope\n\n"
        XCTAssertEqual(logFormatted(inputError), outputError)

        let inputFatal = "/path/file.swift:64:69: fatal error: cannot find 'input' in scope"
        let outputFatal = "##vso[task.logissue type=error;sourcepath=/path/file.swift;linenumber=64;columnnumber=69]cannot find 'input' in scope\n\n"
        XCTAssertEqual(logFormatted(inputFatal), outputFatal)
    }

    func testCompile() {
        #if os(macOS)
        // Xcode 10 and before
        let input1 = "CompileSwift normal x86_64 /Users/admin/dev/Swifttrain/xcbeautify/Sources/xcbeautify/setup.swift (in target: xcbeautify)"
        // Xcode 11+'s output
        let input2 = "CompileSwift normal x86_64 /Users/admin/dev/Swifttrain/xcbeautify/Sources/xcbeautify/setup.swift (in target 'xcbeautify' from project 'xcbeautify')"
        let output = "[xcbeautify] Compiling setup.swift"
        XCTAssertEqual(logFormatted(input1), output)
        XCTAssertEqual(logFormatted(input2), output)
        #endif
    }

    func testSwiftCompile_arm64() {
        let input = "SwiftCompile normal arm64 /path/to/File.swift (in target 'Target' from project 'Project')"
        let output = "[Target] Compiling File.swift"
        XCTAssertEqual(logFormatted(input), output)
    }

    func testSwiftCompile_x86_64() {
        let input = "SwiftCompile normal x86_64 /Backyard-Birds/Build/Intermediates.noindex/BackyardBirdsData.build/Debug/BackyardBirdsData.build/DerivedSources/resource_bundle_accessor.swift (in target 'BackyardBirdsData' from project 'BackyardBirdsData')"
        let output = "[BackyardBirdsData] Compiling resource_bundle_accessor.swift"
        XCTAssertEqual(logFormatted(input), output)
    }

    func testSwiftCompiling() {
        let input = #"SwiftCompile normal x86_64 Compiling\ BackyardBirdsDataContainer.swift,\ ColorData.swift,\ DataGeneration.swift,\ DataGenerationOptions.swift /Backyard-Birds/BackyardBirdsData/General/BackyardBirdsDataContainer.swift /Backyard-Birds/BackyardBirdsData/General/ColorData.swift /Backyard-Birds/BackyardBirdsData/General/DataGeneration.swift /Backyard-Birds/BackyardBirdsData/General/DataGenerationOptions.swift (in target 'BackyardBirdsData' from project 'BackyardBirdsData')"#
        XCTAssertNil(logFormatted(input))
    }

    func testCompileStoryboard() {
        let formatted = logFormatted("CompileStoryboard /Users/admin/MyApp/MyApp/Main.storyboard (in target: MyApp)")
        XCTAssertEqual(formatted, "[MyApp] Compiling Main.storyboard")
    }

    func testCompileWarning() {
        let input = "/path/file.swift:64:69: warning: 'flatMap' is deprecated: Please use compactMap(_:) for the case where closure returns an optional value"
        let output = "##vso[task.logissue type=warning;sourcepath=/path/file.swift;linenumber=64;columnnumber=69]'flatMap' is deprecated: Please use compactMap(_:) for the case where closure returns an optional value\n\n"
        XCTAssertEqual(logFormatted(input), output)
    }

    func testCompileXCStrings() {
        let formatted = logFormatted(#"CompileXCStrings /Backyard-Birds/Build/Intermediates.noindex/BackyardBirdsData.build/Debug/BackyardBirdsData_BackyardBirdsData.build/ /Backyard-Birds/BackyardBirdsData/Backyards/Backyards.xcstrings (in target 'BackyardBirdsData_BackyardBirdsData' from project 'BackyardBirdsData')"#)
        XCTAssertEqual(formatted, "[BackyardBirdsData_BackyardBirdsData] Compile XCStrings Backyards.xcstrings")
    }

    func testCompileXib() {
        let input = "CompileXIB /path/file.xib (in target 'MyApp' from project 'MyProject')"
        let output = "[MyApp] Compiling file.xib"
        XCTAssertEqual(logFormatted(input), output)
    }

    func testCopyHeader() {
        let input = "CpHeader /path/to/destination/file.h /path/file.h (in target 'MyApp' from project 'MyProject')"
        let output = "[MyApp] Copying file.h"
        XCTAssertEqual(logFormatted(input), output)
    }

    func testCopyPlist() {
        let input = "CopyPlistFile /path/to/destination/file.plist /path/file.plist (in target 'MyApp' from project 'MyProject')"
        let output = "[MyApp] Copying file.plist"
        XCTAssertEqual(logFormatted(input), output)
    }

    func testCopyStrings() {
        let input = "CopyStringsFile /path/to/destination/file.strings /path/file.strings (in target 'MyApp' from project 'MyProject')"
        let output = "[MyApp] Copying file.strings"
        XCTAssertEqual(logFormatted(input), output)
    }

    func testCPResource() {
        let input = "CpResource /path/to/destination/file.ttf /path/file.ttf (in target 'MyApp' from project 'MyProject')"
        let output = "[MyApp] Copying file.ttf"
        XCTAssertEqual(logFormatted(input), output)
    }

    func testCopyMatchingSourceAndDestinationFiles() {
        let input = "Copy /path/to/some/file.swift /path/to/some/other/file.swift (in target 'Target' from project 'Project')"
        let output = "[Target] Copy file.swift -> file.swift"
        XCTAssertEqual(logFormatted(input), output)
    }

    func testCopyDifferentSourceAndDestinationFiles() {
        let input = #"Copy /Backyard-Birds/Build/Products/Debug/Backyard_Birds.swiftmodule/x86_64-apple-macos.abi.json /Backyard-Birds/Build/Intermediates.noindex/Backyard\ Birds.build/Debug/Backyard\ Birds.build/Objects-normal/x86_64/Backyard_Birds.abi.json (in target 'Backyard Birds' from project 'Backyard Birds')"#
        let output = "[Backyard Birds] Copy x86_64-apple-macos.abi.json -> Backyard_Birds.abi.json"
        XCTAssertEqual(logFormatted(input), output)
    }

    func testCursor() { }

    func testDetectedEncoding() {
        let input = #"/Backyard-Birds/Build/Intermediates.noindex/Backyard Birds.build/Debug/Widgets.build/ar.lproj/Localizable.strings:1:1: note: detected encoding of input file as Unicode (UTF-8) (in target 'Widgets' from project 'Backyard Birds')"#
        let formatted = logFormatted(input)
        XCTAssertNil(formatted)
    }

    func testExecuted() throws {
        let input1 = "Test Suite 'All tests' failed at 2022-01-15 21:31:49.073."
        let formatted1 = logFormatted(input1)
        XCTAssertEqual(input1, formatted1)

        let input2 = "Executed 3 tests, with 2 failures (1 unexpected) in 0.112 (0.112) seconds"
        let formatted2 = logFormatted(input2)
        XCTAssertEqual(input2, formatted2)

        let input3 = "Test Suite 'All tests' passed at 2022-01-15 21:33:49.073."
        let formatted3 = logFormatted(input3)
        XCTAssertEqual(input3, formatted3)

        let input4 = "Executed 1 test, with 1 failure (1 unexpected) in 0.200 (0.200) seconds"
        let formatted4 = logFormatted(input4)
        XCTAssertEqual(input4, formatted4)
    }

    #if os(macOS)
    func testExecutedWithSkipped() {
        let input1 = "Test Suite 'All tests' failed at 2022-01-15 21:31:49.073."
        let formatted1 = logFormatted(input1)
        XCTAssertEqual(input1, formatted1)

        let input2 = "Executed 56 tests, with 3 test skipped and 2 failures (1 unexpected) in 1.029 (1.029) seconds"
        let formatted2 = logFormatted(input2)
        XCTAssertEqual(input2, formatted2)

        let input3 = "Test Suite 'All tests' passed at 2022-01-15 21:33:49.073."
        let formatted3 = logFormatted(input3)
        XCTAssertEqual(input3, formatted3)

        let input4 = "Executed 1 test, with 1 test skipped and 1 failure (1 unexpected) in 3.000 (3.000) seconds"
        let formatted4 = logFormatted(input4)
        XCTAssertEqual(input4, formatted4)
    }
    #endif

    func testFailingTest() {
        #if os(Linux)
        let input = "/path/to/Tests.swift:123: error: Suite.testCase : XCTAssertEqual failed: (\"1\") is not equal to (\"2\") -"
        let output = "##vso[task.logissue type=error;sourcepath=/path/to/Tests.swift;linenumber=123]    testCase, XCTAssertEqual failed: (\"1\") is not equal to (\"2\") -"
        #else
        let input = "/path/to/Tests.swift:123: error: -[Tests.Suite testCase] : XCTAssertEqual failed: (\"1\") is not equal to (\"2\")"
        let output = "##vso[task.logissue type=error;sourcepath=/path/to/Tests.swift;linenumber=123]    testCase, XCTAssertEqual failed: (\"1\") is not equal to (\"2\")"
        #endif

        XCTAssertEqual(logFormatted(input), output)
    }

    func testFatalError() {
        let input = "fatal error: malformed or corrupted AST file: 'could not find file '/path/file.h' referenced by AST file' note: after modifying system headers, please delete the module cache at '/path/DerivedData/ModuleCache/M5WJ0FYE7N06'"
        let output = "##vso[task.logissue type=error]fatal error: malformed or corrupted AST file: 'could not find file '/path/file.h' referenced by AST file' note: after modifying system headers, please delete the module cache at '/path/DerivedData/ModuleCache/M5WJ0FYE7N06'"
        XCTAssertEqual(logFormatted(input), output)
    }

    func testFileMissingError() {
        let input = "<unknown>:0: error: no such file or directory: '/path/file.swift'"
        let output = "##vso[task.logissue type=error;sourcepath=/path/file.swift]error: no such file or directory:"
        XCTAssertEqual(logFormatted(input), output)
    }

    func testGenerateCoverageData() {
        let formatted = logFormatted("Generating coverage data...")
        XCTAssertEqual(formatted, "Generating code coverage data...")
    }

    func testGeneratedCoverageReport() {
        let formatted = logFormatted("Generated coverage report: /path/to/code coverage.xccovreport")
        XCTAssertEqual(formatted, "Generated code coverage report: /path/to/code coverage.xccovreport")
    }

    func testGenerateDsym() {
        let input = "GenerateDSYMFile /path/file.dSYM /path/to/file (in target 'MyApp' from project 'MyProject')"
        let output = "[MyApp] Generating file.dSYM"
        XCTAssertEqual(logFormatted(input), output)
    }

    func testGenericWarning() {
        let input = "warning: some warning here 123"
        let output = "##vso[task.logissue type=warning]some warning here 123"
        XCTAssertEqual(logFormatted(input), output)
    }

    func testLDError() {
        let inputLdLibraryError = "ld: library not found for -lPods-Yammer"
        XCTAssertEqual(logFormatted(inputLdLibraryError), "##vso[task.logissue type=error]ld: library not found for -lPods-Yammer")

        let inputLdSymbolsError = "ld: symbol(s) not found for architecture x86_64"
        XCTAssertEqual(logFormatted(inputLdSymbolsError), "##vso[task.logissue type=error]ld: symbol(s) not found for architecture x86_64")
    }

    func testLDWarning() {
        let input = "ld: warning: embedded dylibs/frameworks only run on iOS 8 or later"
        let output = "##vso[task.logissue type=warning]ld: embedded dylibs/frameworks only run on iOS 8 or later"
        XCTAssertEqual(logFormatted(input), output)
    }

    func testLibtool() { }

    func testLinkerDuplicateSymbolsLocation() { }

    func testLinkerDuplicateSymbols() { }

    func testLinkerUndefinedSymbolLocation() { }

    func testLinkerUndefinedSymbols() { }

    func testLinking() {
        #if os(macOS)
        let formatted = logFormatted("Ld /Users/admin/Library/Developer/Xcode/DerivedData/xcbeautify-abcd/Build/Products/Debug/xcbeautify normal x86_64 (in target: xcbeautify)")
        XCTAssertEqual(formatted, "[xcbeautify] Linking xcbeautify")

        let formatted2 = logFormatted("Ld /Users/admin/Library/Developer/Xcode/DerivedData/MyApp-abcd/Build/Intermediates.noindex/ArchiveIntermediates/MyApp/IntermediateBuildFilesPath/MyApp.build/Release-iphoneos/MyApp.build/Objects-normal/armv7/My\\ App normal armv7 (in target: MyApp)")
        XCTAssertEqual(formatted2, "[MyApp] Linking My\\ App")

        let formatted3 = logFormatted("Ld /Backyard-Birds/Build/Intermediates.noindex/BackyardBirdsData.build/Debug/BackyardBirdsData.build/Objects-normal/x86_64/Binary/BackyardBirdsData.o normal (in target 'BackyardBirdsData' from project 'BackyardBirdsData')")
        XCTAssertEqual(formatted3, "[BackyardBirdsData] Linking BackyardBirdsData.o")
        #endif
    }

    func testModuleIncludesError() { }

    func testNoCertificate() { }

    func testParallelTestCaseFailed() {
        let formatted = logFormatted("Test case 'XcbeautifyLibTests.testBuildTarget()' failed on 'xctest (49438)' (0.131 seconds)")
        XCTAssertEqual(formatted, "##vso[task.logissue type=error]    testBuildTarget on 'xctest (49438)' (0.131 seconds)")
    }

    func testParallelTestCasePassed() {
        let formatted = logFormatted("Test case 'XcbeautifyLibTests.testBuildTarget()' passed on 'xctest (49438)' (0.131 seconds)")
        XCTAssertEqual(formatted, "    ✔ [XcbeautifyLibTests] testBuildTarget on 'xctest (49438)' (0.131 seconds)")
    }

    func testParallelTestCaseSkipped() {
        let formatted = logFormatted("Test case 'XcbeautifyLibTests.testBuildTarget()' skipped on 'xctest (49438)' (0.131 seconds)")
        XCTAssertEqual(formatted, "    ⊘ [XcbeautifyLibTests] testBuildTarget on 'xctest (49438)' (0.131 seconds)")
    }

    func testConcurrentDestinationTestSuiteStarted() {
        let formatted = logFormatted("Test suite 'XcbeautifyLibTests (iOS).xctest' started on 'iPhone X'")
        XCTAssertEqual(formatted, "Test Suite XcbeautifyLibTests (iOS).xctest started on 'iPhone X'")
    }

    func testConcurrentDestinationTestCaseFailed() {
        let formatted = logFormatted("Test case 'XcbeautifyLibTests.testBuildTarget()' failed on 'iPhone X' (77.158 seconds)")
        XCTAssertEqual(formatted, "##vso[task.logissue type=error]    testBuildTarget on 'iPhone X' (77.158 seconds)")
    }

    func testConcurrentDestinationTestCasePassed() {
        let formatted = logFormatted("Test case 'XcbeautifyLibTests.testBuildTarget()' passed on 'iPhone X' (77.158 seconds)")
        XCTAssertEqual(formatted, "    ✔ [XcbeautifyLibTests] testBuildTarget on 'iPhone X' (77.158 seconds)")
    }

    func testParallelTestCaseAppKitPassed() {
        let formatted = logFormatted("Test case '-[XcbeautifyLibTests.XcbeautifyLibTests testBuildTarget]' passed on 'xctest (49438)' (0.131 seconds).")
        XCTAssertEqual(formatted, "    ✔ [XcbeautifyLibTests.XcbeautifyLibTests] testBuildTarget (0.131 seconds)")
    }

    func testParallelTestingStarted() {
        let formatted = logFormatted("Testing started on 'iPhone X'")
        XCTAssertEqual(formatted, "Testing started on 'iPhone X'")
    }

    func testParallelTestingPassed() {
        let formatted = logFormatted("Testing passed on 'iPhone X'")
        XCTAssertEqual(formatted, "Testing passed on 'iPhone X'")
    }

    func testParallelTestingFailed() {
        let formatted = logFormatted("Testing failed on 'iPhone X'")
        XCTAssertEqual(formatted, "##vso[task.logissue type=error]Testing failed on 'iPhone X'")
    }

    func testPBXCp() {
        let formatted = logFormatted("PBXCp /Users/admin/CocoaLumberjack/Classes/Extensions/DDDispatchQueueLogFormatter.h /Users/admin/Library/Developer/Xcode/DerivedData/Lumberjack-abcd/Build/Products/Release/include/CocoaLumberjack/DDDispatchQueueLogFormatter.h (in target: CocoaLumberjack-Static)")
        XCTAssertEqual(formatted, "[CocoaLumberjack-Static] Copying DDDispatchQueueLogFormatter.h")
    }

    func testPhaseScriptExecution() {
        let input1 = "PhaseScriptExecution [CP]\\ Check\\ Pods\\ Manifest.lock /Users/admin/Library/Developer/Xcode/DerivedData/App-abcd/Build/Intermediates.noindex/ArchiveIntermediates/App/IntermediateBuildFilesPath/App.build/Release-iphoneos/App.build/Script-53BECF2B2F2E203E928C31AE.sh (in target: App)"
        let input2 = "PhaseScriptExecution [CP]\\ Check\\ Pods\\ Manifest.lock /Users/admin/Library/Developer/Xcode/DerivedData/App-abcd/Build/Intermediates.noindex/ArchiveIntermediates/App/IntermediateBuildFilesPath/App.build/Release-iphoneos/App.build/Script-53BECF2B2F2E203E928C31AE.sh (in target 'App' from project 'App')"
        XCTAssertEqual(logFormatted(input1), "[App] Running script [CP] Check Pods Manifest.lock")
        XCTAssertEqual(logFormatted(input2), "[App] Running script [CP] Check Pods Manifest.lock")
    }

    func testPhaseSuccess() {
        let formatted = logFormatted("** CLEAN SUCCEEDED ** [0.085 sec]")
        XCTAssertEqual(formatted, "Clean Succeeded")
    }

    func testPodsError() {
        let input = "error: The sandbox is not in sync with the Podfile.lock. Run 'pod install' or update your CocoaPods installation."
        let output = "##vso[task.logissue type=error]error: The sandbox is not in sync with the Podfile.lock. Run 'pod install' or update your CocoaPods installation."
        XCTAssertEqual(logFormatted(input), output)
    }

    func testPrecompileModule() {
        let input = "PrecompileModule /Users/Some/Random-Path/_To/A/Build/Intermediates.noindex/ExplicitPrecompileModules/file-ABC123.scan"
        XCTAssertNil(logFormatted(input))
    }

    func testPreprocess() {
        let input = "Preprocess /Example/Example/Something.m normal arm64 (in target 'SomeTarget' from project 'SomeProject')"
        let output = "[SomeTarget] Preprocess Something.m"
        XCTAssertEqual(logFormatted(input), output)
    }

    func testProcessInfoPlist() {
        let formatted = logFormatted("ProcessInfoPlistFile /Users/admin/Library/Developer/Xcode/DerivedData/xcbeautify-abcd/Build/Products/Debug/Guaka.framework/Versions/A/Resources/Info.plist /Users/admin/xcbeautify/xcbeautify.xcodeproj/Guaka_Info.plist")
        XCTAssertEqual(formatted, "Processing Guaka_Info.plist")
    }

    func testProcessPchCommand() {
        let formatted = logFormatted("/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang -x c++-header -target x86_64-apple-macos10.13 -c /path/to/my.pch -o /path/to/output/AcVDiff_Prefix.pch.gch")
        XCTAssertEqual(formatted, "Preprocessing /path/to/my.pch")
    }

    func testProcessPchCommandArbitraryExtension() {
        let formatted = logFormatted(#"/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang -x c++-header -target x86_64-apple-macos12.3 -c /path/with\ space/cmake_pch.hxx -o /path/with\ space/build/SharedPrecompiledHeaders/SharedPrecompiledHeaders/2304651503107189736/cmake_pch.hxx.gch --serialize-diagnostics /path/with\ space/build/SharedPrecompiledHeaders/SharedPrecompiledHeaders/2304651503107189736/cmake_pch.hxx.dia"#)
        XCTAssertEqual(formatted, #"Preprocessing /path/with\ space/cmake_pch.hxx"#)
    }

    func testProcessPch() {
        let formatted = logFormatted("ProcessPCH /Users/admin/Library/Developer/Xcode/DerivedData/Lumberjack-abcd/Build/Intermediates.noindex/PrecompiledHeaders/SharedPrecompiledHeaders/5872309797734264511/CocoaLumberjack-Prefix.pch.gch /Users/admin/CocoaLumberjack/Framework/Lumberjack/CocoaLumberjack-Prefix.pch normal x86_64 objective-c com.apple.compilers.llvm.clang.1_0.analyzer (in target: CocoaLumberjack)")
        XCTAssertEqual(formatted, "[CocoaLumberjack] Processing CocoaLumberjack-Prefix.pch")
    }

    func testProcessPchArbitraryExtension() {
        let formatted = logFormatted(#"ProcessPCH++ /Users/admin/src/Test\ Folder/_builds/SharedPrecompiledHeaders/SharedPrecompiledHeaders/2304651503107189736/cmake_pch.hxx.gch /Users/admin/src/Test\ Folder/_builds/CMakeFiles/foo.dir/Debug/cmake_pch.hxx normal x86_64 c++ com.apple.compilers.llvm.clang.1_0.compiler (in target 'foo' from project 'foo')"#)
        XCTAssertEqual(formatted, "[foo] Processing cmake_pch.hxx")
    }

    func testProcessPchPlusPlus() {
        let formatted = logFormatted("ProcessPCH++ /Users/admin/Library/Developer/Xcode/DerivedData/Lumberjack-abcd/Build/Intermediates.noindex/PrecompiledHeaders/SharedPrecompiledHeaders/5872309797734264511/CocoaLumberjack-Prefix.pch.gch /Users/admin/CocoaLumberjack/Framework/Lumberjack/CocoaLumberjack-Prefix.pch normal x86_64 objective-c com.apple.compilers.llvm.clang.1_0.analyzer (in target: CocoaLumberjack)")
        XCTAssertEqual(formatted, "[CocoaLumberjack] Processing CocoaLumberjack-Prefix.pch")
    }

    func testProvisioningProfileRequired() {
        let input = #"MyProject requires a provisioning profile. Select a provisioning profile for the "Debug" build configuration in the project editor."#
        let output = #"##vso[task.logissue type=error]MyProject requires a provisioning profile. Select a provisioning profile for the "Debug" build configuration in the project editor."#
        XCTAssertEqual(logFormatted(input), output)
    }

    func testRestartingTests() {
        let formatted = logFormatted("Restarting after unexpected exit, crash, or test timeout in HomePresenterTest.testIsCellPresented(); summary will include totals from previous launches.")
        XCTAssertEqual(formatted, "##vso[task.logissue type=error]    Restarting after unexpected exit, crash, or test timeout in HomePresenterTest.testIsCellPresented(); summary will include totals from previous launches.")
    }

    func testScanDependencies() {
        let formatted = logFormatted(#"ScanDependencies /Users/Some/Random-Path/_To/A/Build/Intermediates.noindex/Some/Other.build/x86_64/file-ABC123.o /Users/Some/Other-Random-Path/_To/A/Build/Intermediates.noindex/Some/Other.build/x86_64/file-DEF456.m normal x86_64 objective-c com.apple.compilers.llvm.clang.1_0.compiler (in target 'SomeTarget' from project 'SomeProject')"#)
        XCTAssertNil(formatted)
    }

    func testShellCommand() {
        let formatted = logFormatted("    cd /foo/bar/baz")
        XCTAssertNil(formatted)
    }

    func testSymbolReferencedFrom() {
        let formatted = logFormatted("  \"NetworkBusiness.ImageDownloadManager.saveImage(image: __C.UIImage, needWatermark: Swift.Bool, params: [Swift.String : Any], downloadHandler: (Swift.Bool) -> ()?) -> ()\", referenced from:")
        XCTAssertEqual(formatted, "##vso[task.logissue type=error]  \"NetworkBusiness.ImageDownloadManager.saveImage(image: __C.UIImage, needWatermark: Swift.Bool, params: [Swift.String : Any], downloadHandler: (Swift.Bool) -> ()?) -> ()\", referenced from:")
    }

    func testUndefinedSymbolLocation() {
        let formatted = logFormatted("      MediaBrowser.ChatGalleryViewController.downloadImage() -> () in MediaBrowser(ChatGalleryViewController.o)")
        XCTAssertEqual(formatted, "##vso[task.logissue type=warning]      MediaBrowser.ChatGalleryViewController.downloadImage() -> () in MediaBrowser(ChatGalleryViewController.o)")
    }

    func testTestCaseMeasured() {
        #if os(macOS)
        let formatted = logFormatted(#"/Users/cyberbeni/Desktop/framework/TypedNotificationCenter/<compiler-generated>:54: Test Case '-[TypedNotificationCenterPerformanceTests.BridgedNotificationTests test_subscribing_2senders_notificationName]' measured [High Water Mark For Heap Allocations, KB] average: 5407.634, relative standard deviation: 45.772%, values: [9341.718750, 3779.468750, 3779.468750, 9630.344727, 3779.468750, 3779.468750, 3895.093750, 3779.468750, 8532.372070, 3779.468750], performanceMetricID:com.apple.XCTPerformanceMetric_HighWaterMarkForHeapAllocations, baselineName: "", baselineAverage: , polarity: prefers smaller, maxPercentRegression: 10.000%, maxPercentRelativeStandardDeviation: 10.000%, maxRegression: 1.000, maxStandardDeviation: 1.000"#)
        XCTAssertEqual(formatted, #"    ◷ test_subscribing_2senders_notificationName measured (5407.634 KB ±45.772% -- High Water Mark For Heap Allocations)"#)
        #endif
    }

    func testTestCasePassed() {
        #if os(macOS)
        let formatted = logFormatted("Test Case '-[XcbeautifyLibTests.XcbeautifyLibTests testBuildTarget]' passed (0.131 seconds).")
        XCTAssertEqual(formatted, "    ✔ testBuildTarget (0.131 seconds)")
        #endif
    }

    func testTestCaseSkipped() {
        #if os(macOS)
        let formatted = logFormatted("Test Case '-[SomeTests testName]' skipped (0.004 seconds).")
        XCTAssertEqual(formatted, "    ⊘ testName (0.004 seconds)")
        #endif
    }

    func testTestCasePending() { }

    func testTestCaseStarted() { }

    func testTestSuiteStart() { }

    func testTestSuiteStarted() { }

    #if os(macOS)
    func testTestSuiteAllTestsPassed() {
        let input = "Test Suite 'All tests' passed at 2022-01-15 21:31:49.073."
        let formatted = logFormatted(input)
        XCTAssertEqual(input, formatted)
    }
    #endif

    #if os(macOS)
    func testTestSuiteAllTestsFailed() {
        let input = "Test Suite 'All tests' failed at 2022-01-15 21:31:49.073."
        let formatted = logFormatted(input)
        XCTAssertEqual(input, formatted)
    }
    #endif

    func testTestsRunCompletion() { }

    func testTiffutil() {
        let input = "TiffUtil file.tiff"
        XCTAssertEqual(logFormatted(input), nil)
    }

    func testTouch() {
        let formatted = logFormatted("Touch /Users/admin/Library/Developer/Xcode/DerivedData/xcbeautify-dgnqmpfertotpceazwfhtfwtuuwt/Build/Products/Debug/XcbeautifyLib.framework (in target: XcbeautifyLib)")
        XCTAssertEqual(formatted, "[XcbeautifyLib] Touching XcbeautifyLib.framework")
    }

    func testUIFailingTest() {
        let formatted = logFormatted("    t =    10.13s Assertion Failure: <unknown>:0: App crashed in <external symbol>")
        XCTAssertEqual(formatted, "##vso[task.logissue type=error;sourcepath=<unknown>;linenumber=0]    App crashed in <external symbol>")
    }

    func testWillNotBeCodeSigned() {
        let input = "FrameworkName will not be code signed because its settings don't specify a development team."
        let output = "##vso[task.logissue type=warning]FrameworkName will not be code signed because its settings don't specify a development team."
        XCTAssertEqual(logFormatted(input), output)
    }

    func testWriteAuxiliaryFileGeneric() {
        let input = #"WriteAuxiliaryFile /path/to/some/auxiliary/file.extension (in target 'Target' from project 'Project')"#
        let output = "[Target] Write Auxiliary File file.extension"
        XCTAssertEqual(logFormatted(input), output)
    }

    func testWriteAuxiliaryFileBackyardBirds() {
        let input = #"WriteAuxiliaryFile /Backyard-Birds/Build/Intermediates.noindex/LayeredArtworkLibrary.build/Debug/LayeredArtworkLibrary_LayeredArtworkLibrary.build/empty-LayeredArtworkLibrary_LayeredArtworkLibrary.plist (in target 'LayeredArtworkLibrary_LayeredArtworkLibrary' from project 'LayeredArtworkLibrary')"#
        let output = "[LayeredArtworkLibrary_LayeredArtworkLibrary] Write Auxiliary File empty-LayeredArtworkLibrary_LayeredArtworkLibrary.plist"
        XCTAssertEqual(logFormatted(input), output)
    }

    func testWriteFile() {
        let input = "write-file /path/file.SwiftFileList"
        XCTAssertNil(logFormatted(input))
    }

    func testPackageFetching() {
        let input1 = "Fetching from https://github.com/cpisciotta/xcbeautify"
        let output1 = "Fetching https://github.com/cpisciotta/xcbeautify"
        let formatted1 = logFormatted(input1)
        XCTAssertEqual(formatted1, output1)

        let input2 = "Fetching from https://github.com/cpisciotta/xcbeautify (cached)"
        let output2 = "Fetching https://github.com/cpisciotta/xcbeautify (cached)"
        let formatted2 = logFormatted(input2)
        XCTAssertEqual(formatted2, output2)

        let input3 = "Fetching from https://github.com/cpisciotta/xcbeautify.git"
        let output3 = "Fetching https://github.com/cpisciotta/xcbeautify.git"
        let formatted3 = logFormatted(input3)
        XCTAssertEqual(formatted3, output3)
    }

    func testPackageUpdating() {
        let input1 = "Updating from https://github.com/cpisciotta/xcbeautify"
        let output1 = "Updating https://github.com/cpisciotta/xcbeautify"
        let formatted1 = logFormatted(input1)
        XCTAssertEqual(formatted1, output1)

        let input2 = "Updating from https://github.com/cpisciotta/xcbeautify (cached)"
        let output2 = "Updating https://github.com/cpisciotta/xcbeautify (cached)"
        let formatted2 = logFormatted(input2)
        XCTAssertEqual(formatted2, output2)

        let input3 = "Updating from https://github.com/cpisciotta/xcbeautify.git"
        let output3 = "Updating https://github.com/cpisciotta/xcbeautify.git"
        let formatted3 = logFormatted(input3)
        XCTAssertEqual(formatted3, output3)
    }

    func testPackageCheckingOut() {
        let input1 = "Cloning local copy of package 'xcbeautify'"
        let formatted1 = logFormatted(input1)
        XCTAssertNil(formatted1)

        let input2 = "Checking out x.y.z of package 'xcbeautify'"
        let output2 = "Checking out 'xcbeautify' @ x.y.z"
        let formatted2 = logFormatted(input2)
        XCTAssertEqual(formatted2, output2)
    }

    func testPackageGraphResolved() {
        // Start
        let start = logFormatted("Resolve Package Graph")
        XCTAssertEqual(start, "Resolving Package Graph")

        // Ended
        let ended = logFormatted("Resolved source packages:")
        XCTAssertEqual(ended, "Resolved source packages")

        // Package
        let package = logFormatted("  StrasbourgParkAPI: https://github.com/yageek/StrasbourgParkAPI.git @ 3.0.2")
        XCTAssertEqual(package, "StrasbourgParkAPI - https://github.com/yageek/StrasbourgParkAPI.git @ 3.0.2")
    }

    func testXcodebuildError() {
        let formatted = logFormatted("xcodebuild: error: Existing file at -resultBundlePath \"/output/file.xcresult\"")
        XCTAssertEqual(formatted, "##vso[task.logissue type=error]xcodebuild: error: Existing file at -resultBundlePath \"/output/file.xcresult\"")
    }

    func testXcodeprojError() {
        // Given
        let errorText = #"/path/to/project.xcodeproj: error: No signing certificate "iOS Distribution" found: No "iOS Distribution" signing certificate matching team ID "xxxxx" with a private key was found. (in target 'target' from project 'project')"#
        let expectedFormatted = "##vso[task.logissue type=error;sourcepath=/path/to/project.xcodeproj]No signing certificate \"iOS Distribution\" found: No \"iOS Distribution\" signing certificate matching team ID \"xxxxx\" with a private key was found. (in target 'target' from project 'project')\n\n"

        // When
        let actualFormatted = logFormatted(errorText)

        // Then
        XCTAssertEqual(actualFormatted, expectedFormatted)
    }

    func testXcodeprojWarning() {
        // Given
        let errorText = "/Users/xxxxx/Example/Pods/Pods.xcodeproj: warning: The iOS deployment target 'IPHONEOS_DEPLOYMENT_TARGET' is set to 9.0, but the range of supported deployment target versions is 11.0 to 16.0.99. (in target 'XXPay' from project 'Pods')"
        let expectedFormatted = "##vso[task.logissue type=warning;sourcepath=/Users/xxxxx/Example/Pods/Pods.xcodeproj]The iOS deployment target 'IPHONEOS_DEPLOYMENT_TARGET' is set to 9.0, but the range of supported deployment target versions is 11.0 to 16.0.99. (in target 'XXPay' from project 'Pods')\n\n"

        // When
        let actualFormatted = logFormatted(errorText)

        // Then
        XCTAssertEqual(actualFormatted, expectedFormatted)
    }

    func testDuplicateLocalizedStringKey() {
        let formatted = logFormatted(#"2022-12-07 16:26:40 --- WARNING: Key "duplicate" used with multiple values. Value "First" kept. Value "Second" ignored."#)
        XCTAssertEqual(formatted, #"##vso[task.logissue type=warning]Key "duplicate" used with multiple values. Value "First" kept. Value "Second" ignored."#)
    }

    func testRegisterExecutionPolicyException() {
        let formatted = logFormatted(#"RegisterExecutionPolicyException /path/to/output.o (in target 'Target' from project 'Project')"#)
        XCTAssertEqual(formatted, "[Target] RegisterExecutionPolicyException output.o")
    }

    func testTestingStarted() {
        let formatted = logFormatted(#"Testing started"#)
        XCTAssertEqual(formatted, #"Testing started"#)
    }

    func testSigningBundle() {
        let formatted = logFormatted(#"Signing Some_Bundle.bundle (in target 'Target' from project 'Project')"#)
        XCTAssertEqual(formatted, #"[Target] Signing Some_Bundle.bundle"#)
    }

    func testSigningObjectFile() {
        let formatted = logFormatted(#"Signing Some+File.o (in target 'Target' from project 'Project')"#)
        XCTAssertEqual(formatted, #"[Target] Signing Some+File.o"#)
    }

    func testSwiftMergeGeneratedHeaders() {
        let formatted = logFormatted(#"SwiftMergeGeneratedHeaders /Backyard-Birds/Build/Intermediates.noindex/Backyard\ Birds.build/Debug/Backyard\ Birds.build/DerivedSources/Backyard_Birds-Swift.h /Backyard-Birds/Build/Intermediates.noindex/Backyard\ Birds.build/Debug/Backyard\ Birds.build/Objects-normal/arm64/Backyard_Birds-Swift.h /Backyard-Birds/Build/Intermediates.noindex/Backyard\ Birds.build/Debug/Backyard\ Birds.build/Objects-normal/x86_64/Backyard_Birds-Swift.h (in target 'Backyard Birds' from project 'Backyard Birds')"#)
        XCTAssertNil(formatted)
    }

    func testSwiftTestingRunCompletion() {
        let input = #"􁁛 Test run with 5 tests passed after 12.345 seconds."#
        let formatted = logFormatted(input)
        let expectedOutput = "Test run with 5 tests passed after 12.345 seconds"
        XCTAssertEqual(formatted, expectedOutput)
    }

    func testSwiftTestingRunFailed() {
        let input = #"􀢄 Test run with 10 tests failed after 15.678 seconds with 3 issues."#
        let formatted = logFormatted(input)
        let expectedOutput = "##vso[task.logissue type=error]Test run with 10 tests failed after 15.678 seconds with 3 issue(s)"
        XCTAssertEqual(formatted, expectedOutput)
    }

    func testSwiftTestingSuiteFailed() {
        let input = #"􀢄 Suite "MyTestSuite" failed after 8.456 seconds with 2 issues."#
        let formatted = logFormatted(input)
        let expectedOutput = "##vso[task.logissue type=error]Suite \"MyTestSuite\" failed after 8.456 seconds with 2 issue(s)"
        XCTAssertEqual(formatted, expectedOutput)
    }

    func testSwiftTestingTestFailed() {
        let input = #"􀢄 Test "myTest" failed after 1.234 seconds with 1 issue."#
        let formatted = logFormatted(input)
        let expectedOutput = "##vso[task.logissue type=error]\"myTest\" (1.234 seconds) 1 issue(s)"
        XCTAssertEqual(formatted, expectedOutput)
    }

    func testSwiftTestingTestSkipped() {
        let input = #"􀙟 Test myTest() skipped."#
        let formatted = logFormatted(input)
        let expectedOutput = "    ⊘ myTest() skipped"
        XCTAssertEqual(formatted, expectedOutput)
    }

    func testSwiftTestingTestSkippedReason() {
        let input = #"􀙟 Test myTest() skipped: "Reason for skipping""#
        let formatted = logFormatted(input)
        let expectedOutput = "    ⊘ myTest() skipped (Reason for skipping)"
        XCTAssertEqual(formatted, expectedOutput)
    }

    func testSwiftTestingIssue() {
        let input = #"􀢄  Test "myTest" recorded an issue at PlanTests.swift:43:5: Expectation failed"#
        let formatted = logFormatted(input)
        let expectedOutput = "##vso[task.logissue type=error]Recorded an issue (PlanTests.swift:43:5: Expectation failed)"
        XCTAssertEqual(formatted, expectedOutput)
    }

    func testSwiftTestingIssueArguments() {
        let input = #"􀢄 Test "myTest" recorded an issue with 2 arguments."#
        let formatted = logFormatted(input)
        let expectedOutput = "##vso[task.logissue type=error]Recorded an issue (2) argument(s)"
        XCTAssertEqual(formatted, expectedOutput)
    }

    func testSwiftTestingIssueDetails() {
        let input = #"􀢄  Test "myTest" recorded an issue at PlanTests.swift:43:5: Expectation failed"#
        let formatted = logFormatted(input)
        let expectedOutput = "##vso[task.logissue type=error]Recorded an issue (PlanTests.swift:43:5: Expectation failed)"
        XCTAssertEqual(formatted, expectedOutput)
    }

    func testIndentedClangCommand() {
        let input = #"    /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang -Xlinker -reproducible -target arm64-apple-macos14.0 -dynamiclib -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX14.2.sdk -O0 -L/Backyard-Birds/Build/Intermediates.noindex/EagerLinkingTBDs/Debug -L/Backyard-Birds/Build/Products/Debug -L/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/usr/lib -F/Backyard-Birds/Build/Intermediates.noindex/EagerLinkingTBDs/Debug -F/Backyard-Birds/Build/Products/Debug/PackageFrameworks -F/Backyard-Birds/Build/Products/Debug -F/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/Library/Frameworks -iframework /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/Library/Frameworks -filelist /Backyard-Birds/Build/Intermediates.noindex/BackyardBirdsData.build/Debug/BackyardBirdsData\ product.build/Objects-normal/arm64/BackyardBirdsData.LinkFileList -install_name @rpath/BackyardBirdsData.framework/Versions/A/BackyardBirdsData -Xlinker -rpath -Xlinker /Backyard-Birds/Build/Products/Debug/PackageFrameworks -Xlinker -object_path_lto -Xlinker /Backyard-Birds/Build/Intermediates.noindex/BackyardBirdsData.build/Debug/BackyardBirdsData\ product.build/Objects-normal/arm64/BackyardBirdsData_lto.o -Xlinker -export_dynamic -Xlinker -no_deduplicate -fobjc-link-runtime -L/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx -L/usr/lib/swift -Wl,-no_warn_duplicate_libraries -Xlinker -dependency_info -Xlinker /Backyard-Birds/Build/Intermediates.noindex/BackyardBirdsData.build/Debug/BackyardBirdsData\ product.build/Objects-normal/arm64/BackyardBirdsData_dependency_info.dat -o /Backyard-Birds/Build/Intermediates.noindex/BackyardBirdsData.build/Debug/BackyardBirdsData\ product.build/Objects-normal/arm64/Binary/BackyardBirdsData -Xlinker -add_ast_path -Xlinker /Backyard-Birds/Build/Intermediates.noindex/BackyardBirdsData.build/Debug/BackyardBirdsData.build/Objects-normal/arm64/BackyardBirdsData.swiftmodule"#
        XCTAssertNil(logFormatted(input))
    }

    func testNonIndentedClangCommand() {
        let input = #"/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang -Xlinker -reproducible -target arm64-apple-macos14.0 -dynamiclib -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX14.2.sdk -O0 -L/Backyard-Birds/Build/Intermediates.noindex/EagerLinkingTBDs/Debug -L/Backyard-Birds/Build/Products/Debug -L/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/usr/lib -F/Backyard-Birds/Build/Intermediates.noindex/EagerLinkingTBDs/Debug -F/Backyard-Birds/Build/Products/Debug/PackageFrameworks -F/Backyard-Birds/Build/Products/Debug -F/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/Library/Frameworks -iframework /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/Library/Frameworks -filelist /Backyard-Birds/Build/Intermediates.noindex/BackyardBirdsData.build/Debug/BackyardBirdsData\ product.build/Objects-normal/arm64/BackyardBirdsData.LinkFileList -install_name @rpath/BackyardBirdsData.framework/Versions/A/BackyardBirdsData -Xlinker -rpath -Xlinker /Backyard-Birds/Build/Products/Debug/PackageFrameworks -Xlinker -object_path_lto -Xlinker /Backyard-Birds/Build/Intermediates.noindex/BackyardBirdsData.build/Debug/BackyardBirdsData\ product.build/Objects-normal/arm64/BackyardBirdsData_lto.o -Xlinker -export_dynamic -Xlinker -no_deduplicate -fobjc-link-runtime -L/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx -L/usr/lib/swift -Wl,-no_warn_duplicate_libraries -Xlinker -dependency_info -Xlinker /Backyard-Birds/Build/Intermediates.noindex/BackyardBirdsData.build/Debug/BackyardBirdsData\ product.build/Objects-normal/arm64/BackyardBirdsData_dependency_info.dat -o /Backyard-Birds/Build/Intermediates.noindex/BackyardBirdsData.build/Debug/BackyardBirdsData\ product.build/Objects-normal/arm64/Binary/BackyardBirdsData -Xlinker -add_ast_path -Xlinker /Backyard-Birds/Build/Intermediates.noindex/BackyardBirdsData.build/Debug/BackyardBirdsData.build/Objects-normal/arm64/BackyardBirdsData.swiftmodule"#
        XCTAssertNil(logFormatted(input))
    }

    func testSwiftEmitModule() {
        let input = #"SwiftEmitModule normal i386 Emitting\ module\ for\ CasePaths (in target 'CasePaths' from project 'swift-case-paths')"#
        XCTAssertNil(logFormatted(input))
    }

    func testEmitSwiftModule() {
        let input = "EmitSwiftModule normal arm64 (in target 'Target' from project 'Project')"
        XCTAssertNil(logFormatted(input))
    }

    func testNote() {
        let formatted = logFormatted("note: Building targets in dependency order")
        XCTAssertEqual(formatted, "note: Building targets in dependency order")
    }
}

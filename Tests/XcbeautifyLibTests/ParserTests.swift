//
//  ParserTests.swift
//
//
//  Created by Charles Pisciotta on 8/6/24.
//

import XCTest
@testable import XcbeautifyLib

final class ParserTests: XCTestCase {
    private var parser: Parser!

    override func setUpWithError() throws {
        try super.setUpWithError()
        parser = Parser()
    }

    override func tearDownWithError() throws {
        parser = nil
        try super.tearDownWithError()
    }

    func testMatchCompileXCStrings() throws {
        let input = #"CompileXCStrings /Backyard-Birds/Build/Intermediates.noindex/BackyardBirdsData.build/Debug/BackyardBirdsData_BackyardBirdsData.build/ /Backyard-Birds/BackyardBirdsData/Backyards/Backyards.xcstrings (in target 'BackyardBirdsData_BackyardBirdsData' from project 'BackyardBirdsData')"#
        let captureGroup = try XCTUnwrap(parser.parse(line: input) as? CompileXCStringsCaptureGroup)
        XCTAssertEqual(captureGroup.filePath, "/Backyard-Birds/Build/Intermediates.noindex/BackyardBirdsData.build/Debug/BackyardBirdsData_BackyardBirdsData.build/ /Backyard-Birds/BackyardBirdsData/Backyards/Backyards.xcstrings")
        XCTAssertEqual(captureGroup.filename, "Backyards.xcstrings")
        XCTAssertEqual(captureGroup.target, "BackyardBirdsData_BackyardBirdsData")
        XCTAssertEqual(captureGroup.project, "BackyardBirdsData")
    }

    func testMatchCopyFilesMatchingSourceAndDestinationFilenames() throws {
        let input = #"Copy /path/to/some/file.swift /path/to/some/other/file.swift (in target 'Target' from project 'Project')"#
        let captureGroup = try XCTUnwrap(parser.parse(line: input) as? CopyFilesCaptureGroup)
        XCTAssertEqual(captureGroup.firstFilePath, "/path/to/some/file.swift")
        XCTAssertEqual(captureGroup.firstFilename, "file.swift")
        XCTAssertEqual(captureGroup.secondFilePath, "/path/to/some/other/file.swift")
        XCTAssertEqual(captureGroup.secondFilename, "file.swift")
        XCTAssertEqual(captureGroup.target, "Target")
    }

    func testMatchCopyFilesDifferentSourceAndDestinationFilenames() throws {
        let input = #"Copy /Backyard-Birds/Build/Products/Debug/Backyard_Birds.swiftmodule/x86_64-apple-macos.abi.json /Backyard-Birds/Build/Intermediates.noindex/Backyard\ Birds.build/Debug/Backyard\ Birds.build/Objects-normal/x86_64/Backyard_Birds.abi.json (in target 'Backyard Birds' from project 'Backyard Birds')"#
        let captureGroup = try XCTUnwrap(parser.parse(line: input) as? CopyFilesCaptureGroup)
        XCTAssertEqual(captureGroup.firstFilePath, "/Backyard-Birds/Build/Products/Debug/Backyard_Birds.swiftmodule/x86_64-apple-macos.abi.json")
        XCTAssertEqual(captureGroup.firstFilename, "x86_64-apple-macos.abi.json")
        XCTAssertEqual(captureGroup.secondFilePath, #"/Backyard-Birds/Build/Intermediates.noindex/Backyard\ Birds.build/Debug/Backyard\ Birds.build/Objects-normal/x86_64/Backyard_Birds.abi.json"#)
        XCTAssertEqual(captureGroup.secondFilename, "Backyard_Birds.abi.json")
        XCTAssertEqual(captureGroup.target, "Backyard Birds")
    }

    func testMatchCreateUniversalBinary() throws {
        let input = #"CreateUniversalBinary /Backyard-Birds/Build/Products/Debug/BackyardBirdsData.o normal arm64\ x86_64 (in target 'BackyardBirdsDataTarget' from project 'BackyardBirdsDataProject')"#
        let captureGroup = try XCTUnwrap(parser.parse(line: input) as? CreateUniversalBinaryCaptureGroup)
        XCTAssertEqual(captureGroup.filePath, "/Backyard-Birds/Build/Products/Debug/BackyardBirdsData.o")
        XCTAssertEqual(captureGroup.filename, "BackyardBirdsData.o")
        XCTAssertEqual(captureGroup.target, "BackyardBirdsDataTarget")
        XCTAssertEqual(captureGroup.project, "BackyardBirdsDataProject")
    }

    func testMatchDetectedEncoding() throws {
        let input = #"/Backyard-Birds/Build/Intermediates.noindex/BackyardBirdsUI.build/Debug/BackyardBirdsUI_BackyardBirdsUI.build/ru.lproj/Localizable.strings:35:45: note: detected encoding of input file as Unicode (UTF-8) (in target 'BackyardBirdsUI_BackyardBirdsUI' from project 'BackyardBirdsUI')"#
        let captureGroup = try XCTUnwrap(parser.parse(line: input) as? DetectedEncodingCaptureGroup)
        XCTAssertEqual(captureGroup.filePath, "/Backyard-Birds/Build/Intermediates.noindex/BackyardBirdsUI.build/Debug/BackyardBirdsUI_BackyardBirdsUI.build/ru.lproj/Localizable.strings")
        XCTAssertEqual(captureGroup.filename, "Localizable.strings")
        XCTAssertEqual(captureGroup.lineNumber, 35)
        XCTAssertEqual(captureGroup.columnNumber, 45)
        XCTAssertEqual(captureGroup.encoding, "Unicode (UTF-8)")
        XCTAssertEqual(captureGroup.target, "BackyardBirdsUI_BackyardBirdsUI")
        XCTAssertEqual(captureGroup.project, "BackyardBirdsUI")
    }

    #if os(macOS)
    func testMatchLdCommandObjectWithoutArch() throws {
        let input = #"Ld /Backyard-Birds/Build/Intermediates.noindex/BackyardBirdsData.build/Debug/BackyardBirdsData.build/Objects-normal/x86_64/Binary/BackyardBirdsData.o normal (in target 'BackyardBirdsDataTarget' from project 'BackyardBirdsDataProject')"#
        let captureGroup = try XCTUnwrap(parser.parse(line: input) as? LinkingCaptureGroup)
        XCTAssertEqual(captureGroup.binaryFilename, "BackyardBirdsData.o")
        XCTAssertEqual(captureGroup.target, "BackyardBirdsDataTarget")
    }
    #endif

    func testMatchUnindentedNonPCHClangCommand() throws {
        let input = #"/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang -Xlinker -reproducible -target arm64-apple-macos14.0 -dynamiclib -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX14.2.sdk -O0 -L/Backyard-Birds/Build/Intermediates.noindex/EagerLinkingTBDs/Debug -L/Backyard-Birds/Build/Products/Debug -L/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/usr/lib -F/Backyard-Birds/Build/Intermediates.noindex/EagerLinkingTBDs/Debug -F/Backyard-Birds/Build/Products/Debug/PackageFrameworks -F/Backyard-Birds/Build/Products/Debug -F/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/Library/Frameworks -iframework /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/Library/Frameworks -filelist /Backyard-Birds/Build/Intermediates.noindex/BackyardBirdsData.build/Debug/BackyardBirdsData\ product.build/Objects-normal/arm64/BackyardBirdsData.LinkFileList -install_name @rpath/BackyardBirdsData.framework/Versions/A/BackyardBirdsData -Xlinker -rpath -Xlinker /Backyard-Birds/Build/Products/Debug/PackageFrameworks -Xlinker -object_path_lto -Xlinker /Backyard-Birds/Build/Intermediates.noindex/BackyardBirdsData.build/Debug/BackyardBirdsData\ product.build/Objects-normal/arm64/BackyardBirdsData_lto.o -Xlinker -export_dynamic -Xlinker -no_deduplicate -fobjc-link-runtime -L/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx -L/usr/lib/swift -Wl,-no_warn_duplicate_libraries -Xlinker -dependency_info -Xlinker /Backyard-Birds/Build/Intermediates.noindex/BackyardBirdsData.build/Debug/BackyardBirdsData\ product.build/Objects-normal/arm64/BackyardBirdsData_dependency_info.dat -o /Backyard-Birds/Build/Intermediates.noindex/BackyardBirdsData.build/Debug/BackyardBirdsData\ product.build/Objects-normal/arm64/Binary/BackyardBirdsData -Xlinker -add_ast_path -Xlinker /Backyard-Birds/Build/Intermediates.noindex/BackyardBirdsData.build/Debug/BackyardBirdsData.build/Objects-normal/arm64/BackyardBirdsData.swiftmodule"#
        let captureGroup = try XCTUnwrap(parser.parse(line: input) as? NonPCHClangCommandCaptureGroup)
        XCTAssertEqual(captureGroup.xcodePath, "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang")
    }

    func testMatchIndentedNonPCHClangCommand() throws {
        let input = #"/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang -Xlinker -reproducible -target arm64-apple-macos14.0 -dynamiclib -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX14.2.sdk -O0 -L/Backyard-Birds/Build/Intermediates.noindex/EagerLinkingTBDs/Debug -L/Backyard-Birds/Build/Products/Debug -L/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/usr/lib -F/Backyard-Birds/Build/Intermediates.noindex/EagerLinkingTBDs/Debug -F/Backyard-Birds/Build/Products/Debug/PackageFrameworks -F/Backyard-Birds/Build/Products/Debug -F/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/Library/Frameworks -iframework /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/Library/Frameworks -filelist /Backyard-Birds/Build/Intermediates.noindex/BackyardBirdsData.build/Debug/BackyardBirdsData\ product.build/Objects-normal/arm64/BackyardBirdsData.LinkFileList -install_name @rpath/BackyardBirdsData.framework/Versions/A/BackyardBirdsData -Xlinker -rpath -Xlinker /Backyard-Birds/Build/Products/Debug/PackageFrameworks -Xlinker -object_path_lto -Xlinker /Backyard-Birds/Build/Intermediates.noindex/BackyardBirdsData.build/Debug/BackyardBirdsData\ product.build/Objects-normal/arm64/BackyardBirdsData_lto.o -Xlinker -export_dynamic -Xlinker -no_deduplicate -fobjc-link-runtime -L/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx -L/usr/lib/swift -Wl,-no_warn_duplicate_libraries -Xlinker -dependency_info -Xlinker /Backyard-Birds/Build/Intermediates.noindex/BackyardBirdsData.build/Debug/BackyardBirdsData\ product.build/Objects-normal/arm64/BackyardBirdsData_dependency_info.dat -o /Backyard-Birds/Build/Intermediates.noindex/BackyardBirdsData.build/Debug/BackyardBirdsData\ product.build/Objects-normal/arm64/Binary/BackyardBirdsData -Xlinker -add_ast_path -Xlinker /Backyard-Birds/Build/Intermediates.noindex/BackyardBirdsData.build/Debug/BackyardBirdsData.build/Objects-normal/arm64/BackyardBirdsData.swiftmodule"#
        let captureGroup = try XCTUnwrap(parser.parse(line: input) as? NonPCHClangCommandCaptureGroup)
        XCTAssertEqual(captureGroup.xcodePath, "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang")
    }

    func testUnindentedClangDoesNotMatchShellCommand() throws {
        let input = #"/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang -Xlinker -reproducible -target arm64-apple-macos14.0 -dynamiclib -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX14.2.sdk -O0 -L/Backyard-Birds/Build/Intermediates.noindex/EagerLinkingTBDs/Debug -L/Backyard-Birds/Build/Products/Debug -L/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/usr/lib -F/Backyard-Birds/Build/Intermediates.noindex/EagerLinkingTBDs/Debug -F/Backyard-Birds/Build/Products/Debug/PackageFrameworks -F/Backyard-Birds/Build/Products/Debug -F/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/Library/Frameworks -iframework /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/Library/Frameworks -filelist /Backyard-Birds/Build/Intermediates.noindex/BackyardBirdsData.build/Debug/BackyardBirdsData\ product.build/Objects-normal/arm64/BackyardBirdsData.LinkFileList -install_name @rpath/BackyardBirdsData.framework/Versions/A/BackyardBirdsData -Xlinker -rpath -Xlinker /Backyard-Birds/Build/Products/Debug/PackageFrameworks -Xlinker -object_path_lto -Xlinker /Backyard-Birds/Build/Intermediates.noindex/BackyardBirdsData.build/Debug/BackyardBirdsData\ product.build/Objects-normal/arm64/BackyardBirdsData_lto.o -Xlinker -export_dynamic -Xlinker -no_deduplicate -fobjc-link-runtime -L/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx -L/usr/lib/swift -Wl,-no_warn_duplicate_libraries -Xlinker -dependency_info -Xlinker /Backyard-Birds/Build/Intermediates.noindex/BackyardBirdsData.build/Debug/BackyardBirdsData\ product.build/Objects-normal/arm64/BackyardBirdsData_dependency_info.dat -o /Backyard-Birds/Build/Intermediates.noindex/BackyardBirdsData.build/Debug/BackyardBirdsData\ product.build/Objects-normal/arm64/Binary/BackyardBirdsData -Xlinker -add_ast_path -Xlinker /Backyard-Birds/Build/Intermediates.noindex/BackyardBirdsData.build/Debug/BackyardBirdsData.build/Objects-normal/arm64/BackyardBirdsData.swiftmodule"#
        XCTAssertNil(parser.parse(line: input) as? ShellCommandCaptureGroup)
    }

    func testIndentedClangDoesNotMatchShellCommand() throws {
        throw XCTSkip("FIXME: This improperly matches against ShellCommandCaptureGroup.")
        let input = #"    /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang -Xlinker -reproducible -target arm64-apple-macos14.0 -dynamiclib -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX14.2.sdk -O0 -L/Backyard-Birds/Build/Intermediates.noindex/EagerLinkingTBDs/Debug -L/Backyard-Birds/Build/Products/Debug -L/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/usr/lib -F/Backyard-Birds/Build/Intermediates.noindex/EagerLinkingTBDs/Debug -F/Backyard-Birds/Build/Products/Debug/PackageFrameworks -F/Backyard-Birds/Build/Products/Debug -F/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/Library/Frameworks -iframework /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/Library/Frameworks -filelist /Backyard-Birds/Build/Intermediates.noindex/BackyardBirdsData.build/Debug/BackyardBirdsData\ product.build/Objects-normal/arm64/BackyardBirdsData.LinkFileList -install_name @rpath/BackyardBirdsData.framework/Versions/A/BackyardBirdsData -Xlinker -rpath -Xlinker /Backyard-Birds/Build/Products/Debug/PackageFrameworks -Xlinker -object_path_lto -Xlinker /Backyard-Birds/Build/Intermediates.noindex/BackyardBirdsData.build/Debug/BackyardBirdsData\ product.build/Objects-normal/arm64/BackyardBirdsData_lto.o -Xlinker -export_dynamic -Xlinker -no_deduplicate -fobjc-link-runtime -L/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx -L/usr/lib/swift -Wl,-no_warn_duplicate_libraries -Xlinker -dependency_info -Xlinker /Backyard-Birds/Build/Intermediates.noindex/BackyardBirdsData.build/Debug/BackyardBirdsData\ product.build/Objects-normal/arm64/BackyardBirdsData_dependency_info.dat -o /Backyard-Birds/Build/Intermediates.noindex/BackyardBirdsData.build/Debug/BackyardBirdsData\ product.build/Objects-normal/arm64/Binary/BackyardBirdsData -Xlinker -add_ast_path -Xlinker /Backyard-Birds/Build/Intermediates.noindex/BackyardBirdsData.build/Debug/BackyardBirdsData.build/Objects-normal/arm64/BackyardBirdsData.swiftmodule"#
        XCTAssertNil(parser.parse(line: input) as? ShellCommandCaptureGroup)
    }

    func testSwiftTaskExecutionDoesMatchesShellCommand() throws {
        let input = #"    builtin-swiftTaskExecution -- /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-frontend -frontend -c /Backyard-Birds/Widgets/Backyard/BackyardWidgetIntent.swift /Backyard-Birds/Widgets/Backyard/BackyardWidget.swift -primary-file /Backyard-Birds/Widgets/Backyard/ResupplyBackyardIntent.swift /Backyard-Birds/Widgets/WidgetsBundle.swift /Backyard-Birds/Widgets/Backyard/BackyardSnapshotTimelineProvider.swift /Backyard-Birds/Widgets/Backyard/BackyardWidgetView.swift /Backyard-Birds/Build/Intermediates.noindex/Backyard\ Birds.build/Debug/Widgets.build/DerivedSources/GeneratedAssetSymbols.swift -emit-dependencies-path /Backyard-Birds/Build/Intermediates.noindex/Backyard\ Birds.build/Debug/Widgets.build/Objects-normal/arm64/ResupplyBackyardIntent.d -emit-const-values-path /Backyard-Birds/Build/Intermediates.noindex/Backyard\ Birds.build/Debug/Widgets.build/Objects-normal/arm64/ResupplyBackyardIntent.swiftconstvalues -emit-reference-dependencies-path /Backyard-Birds/Build/Intermediates.noindex/Backyard\ Birds.build/Debug/Widgets.build/Objects-normal/arm64/ResupplyBackyardIntent.swiftdeps -serialize-diagnostics-path /Backyard-Birds/Build/Intermediates.noindex/Backyard\ Birds.build/Debug/Widgets.build/Objects-normal/arm64/ResupplyBackyardIntent.dia -emit-localized-strings -emit-localized-strings-path /Backyard-Birds/Build/Intermediates.noindex/Backyard\ Birds.build/Debug/Widgets.build/Objects-normal/arm64 -target arm64-apple-macos14.2 -Xllvm -aarch64-use-tbi -enable-objc-interop -stack-check -sdk /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX14.2.sdk -I /Backyard-Birds/Build/Products/Debug -F /Backyard-Birds/Build/Products/Debug/PackageFrameworks -F /Backyard-Birds/Build/Products/Debug/PackageFrameworks -F /Backyard-Birds/Build/Products/Debug/PackageFrameworks -F /Backyard-Birds/Build/Products/Debug -no-color-diagnostics -application-extension -enable-testing -g -module-cache-path /Backyard-Birds/ModuleCache.noindex -swift-version 5 -enforce-exclusivity\=checked -Onone -D DEBUG -serialize-debugging-options -const-gather-protocols-file /Backyard-Birds/Build/Intermediates.noindex/Backyard\ Birds.build/Debug/Widgets.build/Objects-normal/arm64/Widgets_const_extract_protocols.json -enable-bare-slash-regex -empty-abi-descriptor -validate-clang-modules-once -clang-build-session-file /Backyard-Birds/ModuleCache.noindex/Session.modulevalidation -Xcc -working-directory -Xcc /Backyard-Birds -resource-dir /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift -enable-anonymous-context-mangled-names -Xcc -ivfsstatcache -Xcc /Backyard-Birds/SDKStatCaches.noindex/macosx14.2-23C53-df0db8920d7ae99241a1bc0f08d2dced.sdkstatcache -Xcc -I/Backyard-Birds/Build/Intermediates.noindex/Backyard\ Birds.build/Debug/Widgets.build/swift-overrides.hmap -Xcc -iquote -Xcc /Backyard-Birds/Build/Intermediates.noindex/Backyard\ Birds.build/Debug/Widgets.build/Widgets-generated-files.hmap -Xcc -I/Backyard-Birds/Build/Intermediates.noindex/Backyard\ Birds.build/Debug/Widgets.build/Widgets-own-target-headers.hmap -Xcc -I/Backyard-Birds/Build/Intermediates.noindex/Backyard\ Birds.build/Debug/Widgets.build/Widgets-all-non-framework-target-headers.hmap -Xcc -ivfsoverlay -Xcc /Backyard-Birds/Build/Intermediates.noindex/Backyard\ Birds.build/Debug/Widgets.build/all-product-headers.yaml -Xcc -iquote -Xcc /Backyard-Birds/Build/Intermediates.noindex/Backyard\ Birds.build/Debug/Widgets.build/Widgets-project-headers.hmap -Xcc -I/Backyard-Birds/Build/Products/Debug/include -Xcc -I/Backyard-Birds/Build/Intermediates.noindex/Backyard\ Birds.build/Debug/Widgets.build/DerivedSources-normal/arm64 -Xcc -I/Backyard-Birds/Build/Intermediates.noindex/Backyard\ Birds.build/Debug/Widgets.build/DerivedSources/arm64 -Xcc -I/Backyard-Birds/Build/Intermediates.noindex/Backyard\ Birds.build/Debug/Widgets.build/DerivedSources -Xcc -DDEBUG\=1 -module-name Widgets -frontend-parseable-output -disable-clang-spi -target-sdk-version 14.2 -target-sdk-name macosx14.2 -external-plugin-path /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX14.2.sdk/usr/lib/swift/host/plugins\#\/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX14.2.sdk/usr/bin/swift-plugin-server -external-plugin-path /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX14.2.sdk/usr/local/lib/swift/host/plugins\#\/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX14.2.sdk/usr/bin/swift-plugin-server -external-plugin-path /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/usr/lib/swift/host/plugins\#\/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/usr/bin/swift-plugin-server -external-plugin-path /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/usr/local/lib/swift/host/plugins\#\/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/usr/bin/swift-plugin-server -plugin-path /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/host/plugins -plugin-path /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/local/lib/swift/host/plugins -o /Backyard-Birds/Build/Intermediates.noindex/Backyard\ Birds.build/Debug/Widgets.build/Objects-normal/arm64/ResupplyBackyardIntent.o -index-unit-output-path /Backyard\ Birds.build/Debug/Widgets.build/Objects-normal/arm64/ResupplyBackyardIntent.o -index-store-path /Backyard-Birds/Index.noindex/DataStore -index-system-modules"#
        XCTAssertNotNil(parser.parse(line: input) as? ShellCommandCaptureGroup)
    }

    func testMatchSwiftDriverJobDiscoveryCompilingCaptureGroupOneFile() throws {
        let input = #"SwiftDriverJobDiscovery normal arm64 Compiling resource_bundle_accessor.swift (in target 'Some Target' from project 'Some Project')"#
        let captureGroup = try XCTUnwrap(parser.parse(line: input) as? SwiftDriverJobDiscoveryCompilingCaptureGroup)
        XCTAssertEqual(captureGroup.state, "normal")
        XCTAssertEqual(captureGroup.architecture, .arm64)
        XCTAssertEqual(captureGroup.filenames, ["resource_bundle_accessor.swift"])
        XCTAssertEqual(captureGroup.target, "Some Target")
        XCTAssertEqual(captureGroup.project, "Some Project")
    }

    func testMatchSwiftDriverJobDiscoveryCompilingCaptureGroupMultipleFiles() throws {
        let input = #"SwiftDriverJobDiscovery normal x86_64 Compiling BackyardVisitorEvent+DataGeneration.swift, BackyardVisitors\ &\ Events.swift, Bird+DataGeneration.swift, Bird.swift (in target 'BackyardBirdsDataTarget' from project 'BackyardBirdsDataProject')"#
        let captureGroup = try XCTUnwrap(parser.parse(line: input) as? SwiftDriverJobDiscoveryCompilingCaptureGroup)
        XCTAssertEqual(captureGroup.state, "normal")
        XCTAssertEqual(captureGroup.architecture, .x86_64)
        XCTAssertEqual(captureGroup.filenames, ["BackyardVisitorEvent+DataGeneration.swift", #"BackyardVisitors\ &\ Events.swift"#, "Bird+DataGeneration.swift", "Bird.swift"])
        XCTAssertEqual(captureGroup.target, "BackyardBirdsDataTarget")
        XCTAssertEqual(captureGroup.project, "BackyardBirdsDataProject")
    }

    func testMatchSwiftCompile() throws {
        let input = #"SwiftCompile normal arm64 /Backyard-Birds/BackyardBirdsData/Food\ &\ Drink/BirdFood+DataGeneration.swift (in target 'BackyardBirdsData' from project 'BackyardBirdsData')"#
        let captureGroup = try XCTUnwrap(parser.parse(line: input) as? SwiftCompileCaptureGroup)
        XCTAssertEqual(captureGroup.filePath, #"/Backyard-Birds/BackyardBirdsData/Food\ &\ Drink/BirdFood+DataGeneration.swift"#)
        XCTAssertEqual(captureGroup.filename, #"BirdFood+DataGeneration.swift"#)
        XCTAssertEqual(captureGroup.target, "BackyardBirdsData")
    }

    func testMatchSwiftDriverJobDiscoveryCompilingCaptureGroup() throws {
        let input = #"SwiftMergeGeneratedHeaders /Backyard-Birds/Build/Intermediates.noindex/GeneratedModuleMaps/LayeredArtworkLibrary-Swift.h /Backyard-Birds/Build/Intermediates.noindex/LayeredArtworkLibrary.build/Debug/LayeredArtworkLibrary.build/Objects-normal/arm64/LayeredArtworkLibrary-Swift.h /Backyard-Birds/Build/Intermediates.noindex/LayeredArtworkLibrary.build/Debug/LayeredArtworkLibrary.build/Objects-normal/x86_64/LayeredArtworkLibrary-Swift.h (in target 'LayeredArtworkLibraryTarget' from project 'LayeredArtworkLibraryProject')"#
        let captureGroup = try XCTUnwrap(parser.parse(line: input) as? SwiftMergeGeneratedHeadersCaptureGroup)
        XCTAssertEqual(captureGroup.headerFilePaths, "/Backyard-Birds/Build/Intermediates.noindex/GeneratedModuleMaps/LayeredArtworkLibrary-Swift.h /Backyard-Birds/Build/Intermediates.noindex/LayeredArtworkLibrary.build/Debug/LayeredArtworkLibrary.build/Objects-normal/arm64/LayeredArtworkLibrary-Swift.h /Backyard-Birds/Build/Intermediates.noindex/LayeredArtworkLibrary.build/Debug/LayeredArtworkLibrary.build/Objects-normal/x86_64/LayeredArtworkLibrary-Swift.h")
        XCTAssertEqual(captureGroup.target, "LayeredArtworkLibraryTarget")
        XCTAssertEqual(captureGroup.project, "LayeredArtworkLibraryProject")
    }

    func testMatchExplicitDependency() throws {
        let input = #"        ➜ Explicit dependency on target 'BackyardBirdsData_BackyardBirdsData' in project 'Backyard Birds Data'"#
        let captureGroup = try XCTUnwrap(parser.parse(line: input) as? ExplicitDependencyCaptureGroup)
        XCTAssertEqual(captureGroup.target, "BackyardBirdsData_BackyardBirdsData")
        XCTAssertEqual(captureGroup.project, "Backyard Birds Data")
    }

    func testMatchTestingStarted() throws {
        let input = "Testing started"
        let captureGroup = try XCTUnwrap(parser.parse(line: input) as? TestingStartedCaptureGroup)
        XCTAssertEqual(captureGroup.wholeMessage, "Testing started")
    }

    func testNotMatchTestingStarted() throws {
        let input = #"2024-08-18 18:17:52.619 xcodebuild[9799:394817] [MT] IDETestOperationsObserverDebug: 21.975 elapsed -- Testing started completed."#
        XCTAssertNil(parser.parse(line: input))
    }

    func testMatchSigning() throws {
        let input = "Signing Some+File.bundle (in target 'Target' from project 'Project')"
        let captureGroup = try XCTUnwrap(parser.parse(line: input) as? SigningCaptureGroup)
        XCTAssertEqual(captureGroup.file, "Some+File.bundle")
        XCTAssertEqual(captureGroup.target, "Target")
        XCTAssertEqual(captureGroup.project, "Project")
    }

    func testMatchSwiftTestingRunStarted() throws {
        let input = "􀟈 Test run started."
        let captureGroup = try XCTUnwrap(parser.parse(line: input) as? SwiftTestingRunStartedCaptureGroup)
        XCTAssertEqual(captureGroup.message, "Test run started.")
    }

    func testMatchSwiftTestingRunCompletion() throws {
        let input = "􁁛  Test run with 5 tests passed after 3.2 seconds."
        let captureGroup = try XCTUnwrap(parser.parse(line: input) as? SwiftTestingRunCompletionCaptureGroup)
        XCTAssertEqual(captureGroup.numberOfTests, 5)
        XCTAssertEqual(captureGroup.totalTime, "3.2")
    }

    func testMatchSwiftTestingRunFailed() throws {
        let input = "􀢄 Test run with 7 tests failed after 4.8 seconds with 2 issues."
        let captureGroup = try XCTUnwrap(parser.parse(line: input) as? SwiftTestingRunFailedCaptureGroup)
        XCTAssertEqual(captureGroup.numberOfTests, 7)
        XCTAssertEqual(captureGroup.totalTime, "4.8")
        XCTAssertEqual(captureGroup.numberOfIssues, 2)
    }

    func testMatchSwiftTestingSuiteStarted() throws {
        let input = "􀟈  Suite SampleTestSuite started."
        let captureGroup = try XCTUnwrap(parser.parse(line: input) as? SwiftTestingSuiteStartedCaptureGroup)
        XCTAssertEqual(captureGroup.suiteName, "SampleTestSuite")
    }

    func testMatchSwiftTestingTestStarted() throws {
        let input = "􀟈  Test ExampleTest started."
        let captureGroup = try XCTUnwrap(parser.parse(line: input) as? SwiftTestingTestStartedCaptureGroup)
        XCTAssertEqual(captureGroup.testName, "ExampleTest")
    }

    func testMatchSwiftTestingSuitePassed() throws {
        let input = "􁁛 Suite TestSuiteName passed after 5.3 seconds."
        let captureGroup = try XCTUnwrap(parser.parse(line: input) as? SwiftTestingSuitePassedCaptureGroup)
        XCTAssertEqual(captureGroup.suiteName, "TestSuiteName")
        XCTAssertEqual(captureGroup.timeTaken, "5.3")
    }

    func testMatchSwiftTestingSuiteFailed() throws {
        let input = #"􀢄 Suite "AnotherTestSuite" failed after 6.4 seconds with 3 issues."#
        let captureGroup = try XCTUnwrap(parser.parse(line: input) as? SwiftTestingSuiteFailedCaptureGroup)
        XCTAssertEqual(captureGroup.suiteName, "\"AnotherTestSuite\"")
        XCTAssertEqual(captureGroup.timeTaken, "6.4")
        XCTAssertEqual(captureGroup.numberOfIssues, 3)
    }

    func testMatchSwiftTestingTestFailed() throws {
        let input = #"􀢄 Test "SomeTest" failed after 2.5 seconds with 1 issue."#
        let captureGroup = try XCTUnwrap(parser.parse(line: input) as? SwiftTestingTestFailedCaptureGroup)
        XCTAssertEqual(captureGroup.testName, "\"SomeTest\"")
        XCTAssertEqual(captureGroup.timeTaken, "2.5")
        XCTAssertEqual(captureGroup.numberOfIssues, 1)
    }

    func testMatchSwiftTestingTestPassed() throws {
        let input = "􁁛 Test SampleTest passed after 3.0 seconds."
        let captureGroup = try XCTUnwrap(parser.parse(line: input) as? SwiftTestingTestPassedCaptureGroup)
        XCTAssertEqual(captureGroup.testName, "SampleTest")
        XCTAssertEqual(captureGroup.timeTaken, "3.0")
    }

    func testMatchSwiftTestingTestSkipped() throws {
        let input = #"􀙟 Test "SkippedTest" skipped."#
        let captureGroup = try XCTUnwrap(parser.parse(line: input) as? SwiftTestingTestSkippedCaptureGroup)
        XCTAssertEqual(captureGroup.testName, "\"SkippedTest\"")
    }

    func testMatchSwiftTestingTestSkippedWithReason() throws {
        let input = #"􀙟 Test "SkippedTest" skipped: "Not relevant for this platform.""#
        let captureGroup = try XCTUnwrap(parser.parse(line: input) as? SwiftTestingTestSkippedReasonCaptureGroup)
        XCTAssertEqual(captureGroup.testName, "\"SkippedTest\"")
        XCTAssertEqual(captureGroup.reason, "Not relevant for this platform.")
    }

    func testMatchSwiftTestingIssue() throws {
        let input = #"􀢄  Test "Selected tests by ID" recorded an issue at PlanTests.swift:43:5: Expectation failed"#
        let captureGroup = try XCTUnwrap(parser.parse(line: input) as? SwiftTestingIssueCaptureGroup)
        XCTAssertEqual(captureGroup.testDescription, "\"Selected tests by ID\"")
        XCTAssertEqual(captureGroup.issueDetails, "PlanTests.swift:43:5: Expectation failed")
    }

    func testMatchSwiftTestingPassingArgument() throws {
        let input = #"􀟈 Passing 2 arguments input → "argument1, argument2""#
        let captureGroup = try XCTUnwrap(parser.parse(line: input) as? SwiftTestingPassingArgumentCaptureGroup)
        XCTAssertEqual(captureGroup.numberOfArguments, 2)
    }

    func testMatchScanDependencies() throws {
        let input = #"ScanDependencies /Users/Some/Random-Path/_To/A/Build/Intermediates.noindex/Some/Other.build/x86_64/file-ABC123.o /Users/Some/Other-Random-Path/_To/A/Build/Intermediates.noindex/Some/Other.build/x86_64/file-DEF456.m normal x86_64 objective-c com.apple.compilers.llvm.clang.1_0.compiler (in target 'SomeTarget' from project 'SomeProject')"#
        let captureGroup = try XCTUnwrap(parser.parse(line: input) as? ScanDependenciesCaptureGroup)
        XCTAssertEqual(captureGroup.target, "SomeTarget")
        XCTAssertEqual(captureGroup.project, "SomeProject")
    }

    func testSwiftDriverTargetCaptureGroup() throws {
        let input = #"SwiftDriver BackyardBirdsData normal arm64 com.apple.xcode.tools.swift.compiler (in target \'BackyardBirdsData\' from project \'BackyardBirdsData\')"#
        let captureGroup = try XCTUnwrap(parser.parse(line: input) as? SwiftDriverTargetCaptureGroup)
        XCTAssertEqual(captureGroup.target, "BackyardBirdsData")
    }

    func testSwiftDriverCompilationTarget() throws {
        let input = #"SwiftDriver\ Compilation SomeTarget normal x86_64 com.apple.xcode.tools.swift.compiler (in target 'Target' from project 'Project')"#
        let captureGroup = try XCTUnwrap(parser.parse(line: input) as? SwiftDriverCompilationTarget)
        XCTAssertEqual(captureGroup.target, "SomeTarget")
    }

    func testSwiftDriverCompilationRequirementsCaptureGroup() throws {
        let input = #"SwiftDriver\ Compilation\ Requirements Backyard\ Birds normal arm64 com.apple.xcode.tools.swift.compiler (in target 'Backyard Birds' from project 'Backyard Birds')"#
        let captureGroup = try XCTUnwrap(parser.parse(line: input) as? SwiftDriverCompilationRequirementsCaptureGroup)
        XCTAssertEqual(captureGroup.target, #"Backyard\ Birds"#)
    }

    func testParseSwiftTestingParallelTestOutputPassed() throws {
        let resultSuccess = try XCTUnwrap(parser.parse(line: "Test case 'SomeStructThatsNotASuite/someFunctionName()' passed on 'Clone 1 of iPhone 16 Pro - xctest (38347)' (13.060 seconds)") as? ParallelTestCasePassedCaptureGroup)
        XCTAssertEqual(resultSuccess.device, "Clone 1 of iPhone 16 Pro - xctest (38347)")
        XCTAssertEqual(resultSuccess.suite, "SomeStructThatsNotASuite")
        XCTAssertEqual(resultSuccess.time, "13.060")
        XCTAssertEqual(resultSuccess.testCase, "someFunctionName")
    }

    func testParseSwiftTestingParallelTestOutputFailed() throws {
        let resultFailed = try XCTUnwrap(parser.parse(line: "Test case 'SubFolderTestDemoTests/exampleFalse()' failed on 'My Mac - TestDemo (29692)' (0.001 seconds)") as? ParallelTestCaseFailedCaptureGroup)
        XCTAssertEqual(resultFailed.device, "My Mac - TestDemo (29692)")
        XCTAssertEqual(resultFailed.suite, "SubFolderTestDemoTests")
        XCTAssertEqual(resultFailed.time, "0.001")
        XCTAssertEqual(resultFailed.testCase, "exampleFalse")
    }

    func tesPrecompileModule() throws {
        let input = try XCTUnwrap(parser.parse(line: "PrecompileModule /Users/Some/Random-Path/_To/A/Build/Intermediates.noindex/ExplicitPrecompileModules/file-ABC123.scan") as? PrecompileModuleCaptureGroup)
        XCTAssertEqual(input.path, "/Users/Some/Random-Path/_To/A/Build/Intermediates.noindex/ExplicitPrecompileModules/file-ABC123.scan")
    }

    func testRegisterExecutionPolicyException() throws {
        let captureGroup = try XCTUnwrap(parser.parse(line: "RegisterExecutionPolicyException /path/to/output.o (in target 'Target' from project 'Project')") as? RegisterExecutionPolicyExceptionCaptureGroup)
        XCTAssertEqual(captureGroup.filePath, "/path/to/output.o")
        XCTAssertEqual(captureGroup.filename, "output.o")
        XCTAssertEqual(captureGroup.target, "Target")
        XCTAssertEqual(captureGroup.project, "Project")
    }

    func testSwiftEmitModule() throws {
        let captureGroup = try XCTUnwrap(parser.parse(line: #"SwiftEmitModule normal i386 Emitting\ module\ for\ CasePaths (in target 'CasePathsTarget' from project 'swift-case-paths')"#) as? SwiftEmitModuleCaptureGroup)
        XCTAssertEqual(captureGroup.arch, .i386)
        XCTAssertEqual(captureGroup.module, "CasePaths")
        XCTAssertEqual(captureGroup.target, "CasePathsTarget")
        XCTAssertEqual(captureGroup.project, "swift-case-paths")
    }

    func testEmitSwiftModule() throws {
        let captureGroup = try XCTUnwrap(parser.parse(line: #"EmitSwiftModule normal arm64 (in target 'Target' from project 'Project')"#) as? EmitSwiftModuleCaptureGroup)
        XCTAssertEqual(captureGroup.arch, .arm64)
        XCTAssertEqual(captureGroup.target, "Target")
        XCTAssertEqual(captureGroup.project, "Project")
    }

    func testMatchNote() throws {
        let inputs = [
            ("note:", "Building targets in dependency order"),
            ("Note:", "Building targets in dependency order"),
            ("note:", "Metadata extraction skipped. No AppIntents.framework dependency found. (in target 'Target' from project 'Project')"),
            ("Note:", "Metadata extraction skipped. No AppIntents.framework dependency found. (in target 'Target' from project 'Project')"),
            ("note:", #"Run script build phase 'SomeRunScriptBuildPhase' will be run during every build because the option to run the script phase "Based on dependency analysis" is unchecked. (in target 'Target' from project 'Project')"#),
            ("Note:", #"Run script build phase 'SomeRunScriptBuildPhase' will be run during every build because the option to run the script phase "Based on dependency analysis" is unchecked. (in target 'Target' from project 'Project')"#),
            ("note:", "Target dependency graph (12 targets)"),
            ("Note:", "Target dependency graph (12 targets)"),
        ]

        for (keyword, note) in inputs {
            let input = "\(keyword) \(note)"
            let captureGroup = try XCTUnwrap(parser.parse(line: input) as? NoteCaptureGroup)
            XCTAssertEqual(captureGroup.note, note)
        }
    }

    func testNotMatchNote() throws {
        let inputs = [
            "in the note middle",
            "in the note: middle",
            "note Building targets in dependency order",
            "Note Metadata extraction skipped.",
            "Target dependency graph (12 targets) note",
            "Target dependency graph (12 targets) note:",
            "Target dependency graph (12 targets): note:",
        ]

        for input in inputs {
            XCTAssertNil(parser.parse(line: input))
        }
    }
}

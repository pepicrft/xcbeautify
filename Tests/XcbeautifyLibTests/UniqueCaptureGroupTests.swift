//
//  UniqueCaptureGroupTests.swift
//  xcbeautify
//
//  Created by Charles Pisciotta on 1/22/25.
//

import XCTest
@testable import XcbeautifyLib

final class UniqueCaptureGroupTests: XCTestCase {

    let captureGroupTypes = Parser().__for_test__captureGroupTypes()

    func testUniqueCaptureGroups() throws {
        let url = try XCTUnwrap(Bundle.module.url(forResource: "clean_build_xcode_15_1", withExtension: "txt"))

        var buildLog: [String] = try String(contentsOf: url)
            .components(separatedBy: .newlines)

        while !buildLog.isEmpty {
            let line = buildLog.removeFirst()

            let capturedTypes = captureGroupTypes.filter { type in
                guard let groups = type.regex.captureGroups(for: line) else { return false }
                XCTAssertNotNil(type.init(groups: groups))
                return true
            }

            XCTAssertLessThanOrEqual(
                capturedTypes.count,
                1,
                """
                Failed to uniquely parse xcodebuild output.
                Line: \(line)
                Captured Types: \(ListFormatter.localizedString(byJoining: capturedTypes.map(String.init(describing:))))
                """
            )
        }
    }

}

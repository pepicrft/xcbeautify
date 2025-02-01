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

    private let parallelTests = """
      Test suite 'MobileWebURLRouteTest' started on 'Clone 1 of iPhone 13 mini - xctest (32505)'
      Test suite 'BuildFlagTests' started on 'Clone 1 of iPhone 13 mini - xctest (32507)'
      Test case 'URL_OutgoingEmailTests.test_outgoingEmailLinkName_urlContainsQueryItem_valueIsReturned()' passed on 'Clone 1 of iPhone 13 mini - xctest (32506)' (0.002 seconds)
      Test case 'MobileWebURLRouteTest.testReportingDescriptionContainsUrl()' passed on 'Clone 1 of iPhone 13 mini - xctest (32505)' (0.003 seconds)
      Test case 'URLRoutingComponentsTests.test_init_urlWithQueryItems_queryItemsReturnsCorrectly()' passed on 'Clone 1 of iPhone 13 mini - xctest (32504)' (0.004 seconds)
      Test case 'BuildFlagTests.test_logClicksToConsole_isFalse()' passed on 'Clone 1 of iPhone 13 mini - xctest (32507)' (0.003 seconds)
      Test case 'URL_OutgoingEmailTests.test_outgoingEmailToken_urlContainsQueryItem_valueIsReturned()' passed on 'Clone 1 of iPhone 13 mini - xctest (32506)' (0.003 seconds)
      Test case 'MobileWebURLRouteTest.testRouteContainsUrl()' passed on 'Clone 1 of iPhone 13 mini - xctest (32505)' (0.002 seconds)
      Test suite 'GeneratedTestingFlagTests' started on 'Clone 1 of iPhone 13 mini - xctest (32504)'
      Test case 'BuildFlagTests.test_logEventsToConsole_isFalse()' passed on 'Clone 1 of iPhone 13 mini - xctest (32507)' (0.002 seconds)
      Test case 'GeneratedTestingFlagTests.test_generatedTesting_expectedValue()' passed on 'Clone 1 of iPhone 13 mini - xctest (32504)' (0.001 seconds)
      Test suite 'Event_EmailTests' started on 'Clone 1 of iPhone 13 mini - xctest (32505)'
      Test case 'Event_EmailTests.test_path_isCorrectValue()' passed on 'Clone 1 of iPhone 13 mini - xctest (32505)' (0.001 seconds)
      Test case 'UserCoordinatorTests.test_loginWithEmailPasswordAndSSO_callsAuthenticationService_thenCallsCompletion()' passed on 'Clone 1 of iPhone 13 mini - xctest (32503)' (0.015 seconds)
      Test case 'BuildFlagTests.test_failIntentionally()' failed on 'Clone 1 of iPhone 13 mini - xctest (59522)' (0.278 seconds)
      Test case 'UserCoordinatorTests.test_refreshLoginToken_failure_completionIsCalled()' passed on 'Clone 1 of iPhone 13 mini - xctest (32503)' (0.012 seconds)
      Test case 'UserCoordinatorTests.test_refreshLoginToken_failure_recordsError()' passed on 'Clone 1 of iPhone 13 mini - xctest (32503)' (0.014 seconds)
      Test case 'UserCoordinatorTests.test_refreshLoginToken_success_completionIsCalled()' passed on 'Clone 1 of iPhone 13 mini - xctest (32503)' (0.008 seconds)
      Test case 'UserCoordinatorTests.test_refreshLoginToken_success_storesLoginToken()' passed on 'Clone 1 of iPhone 13 mini - xctest (32503)' (0.006 seconds)
      Test case 'UserCoordinatorTests.test_refreshUser_failure_completionIsCalled()' passed on 'Clone 1 of iPhone 13 mini - xctest (32503)' (0.005 seconds)
      Test case 'UserCoordinatorTests.test_refreshUser_failure_logsError()' passed on 'Clone 1 of iPhone 13 mini - xctest (32503)' (0.005 seconds)
      Test case 'UserCoordinatorTests.test_refreshUser_success_completionIsCalled()' passed on 'Clone 1 of iPhone 13 mini - xctest (32503)' (0.005 seconds)
      Test case 'UserCoordinatorTests.test_refreshUser_success_userIsStoredInUserDefaults()' passed on 'Clone 1 of iPhone 13 mini - xctest (32503)' (0.006 seconds)
      Test case 'UserCoordinatorTests.test_refreshUser_success_userPropertyIsUpdated()' passed on 'Clone 1 of iPhone 13 mini - xctest (32503)' (0.032 seconds)
      Test case 'UserCoordinatorTests.test_resetPassword_requestSucceeds_completionCalledWithSuccess()' skipped on 'Clone 1 of iPhone 13 mini - xctest (32503)' (0.005 seconds)
    """

    func testUniqueParallelCaptureGroups() throws {
        var buildLog: [String] = parallelTests
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

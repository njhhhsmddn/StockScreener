//
//  RequestThrottleTest.swift
//  StockScreenerTests
//
//  Created by Najihah on 15/02/2025.
//

import XCTest
@testable import StockScreener

class RequestThrottleTests: XCTestCase {
    let viewModel = BaseViewModel()
    var requestTimestamps: [String: [Date]] = [:]

    func testAllowFirstFiveRequests() {
        for _ in 1...5 {
            XCTAssertFalse(viewModel.shouldThrottleRequest(endpoint: "testEndpoint"))
        }
    }

    func testThrottleOnSixthRequest() {
        _ = (1...5).map { _ in viewModel.shouldThrottleRequest(endpoint: "testEndpoint") }
        XCTAssertTrue(viewModel.shouldThrottleRequest(endpoint: "testEndpoint"))
    }

    func testAllowAfterOneMinute() {
        _ = (1...5).map { _ in viewModel.shouldThrottleRequest(endpoint: "testEndpoint") }
        sleep(61) // Simulate wait time
        XCTAssertFalse(viewModel.shouldThrottleRequest(endpoint: "testEndpoint"))
    }
}

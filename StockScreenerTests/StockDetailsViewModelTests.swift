//
//  StockDetailsViewModelTests.swift
//  StockScreenerTests
//
//  Created by Najihah on 17/02/2025.
//

import XCTest
import Combine
@testable import StockScreener

class StockDetailsViewModelTests: XCTestCase {
    var viewModel: StockDetailsViewModel!
    var mockAPIService: MockAPIService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockAPIService = MockAPIService()
        viewModel = StockDetailsViewModel()
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        mockAPIService = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testFetchStockDetails_Success() {
        // Given
        let stock = StockListModel(
            symbol: "A",
            name: "Agilent Technologies Inc",
            exchange: "NYSE",
            assetType: "Stock",
            ipoDate: "1999-11-18",
            delistingDate: "",
            status: "Active"
        )
        let stockDetails = StockDetails(
            symbol: "A",
            name: "Agilent Technologies Inc",
            marketCapitalization: "38420001000",
            dividendYield: "0.0074",
            week52High: "154.53",
            week52Low: "123.73",
            latestQuarter: "2024-10-31",
            eps: "4.43"
        )
        mockAPIService.mockStockDetails = stockDetails
        
        let expectation = self.expectation(description: "Stock details fetch succeeds")
        
        viewModel.$stockDetails
            .dropFirst()
            .sink { details in
                XCTAssertEqual(details?.name, "Agilent Technologies Inc")
                XCTAssertEqual(details?.marketCapitalization, "38420001000")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        viewModel.fetchStockData(stock: stock)
        
        // Then
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testFetchStockDetails_Failure() {
        // Given
        let stock = StockListModel(
            symbol: "APPL",
            name: "Apple Inc",
            exchange: "NASDAQ",
            assetType: "Stock",
            ipoDate: "1999-11-18",
            delistingDate: "",
            status: "Active"
        )
        mockAPIService.shouldReturnError = true
        
        let expectation = self.expectation(description: "Stock details fetch fails")
        
        viewModel.$errorMessage
            .dropFirst()
            .sink { errorMessage in
                XCTAssertNotNil(errorMessage)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        viewModel.fetchStockData(stock: stock)
        
        // Then
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testFetchTimeSeriesMonthly_Success() {
        // Given
        let stock = StockListModel(
            symbol: "A",
            name: "Agilent Technologies Inc",
            exchange: "NYSE",
            assetType: "Stock",
            ipoDate: "1999-11-18",
            delistingDate: "",
            status: "Active"
        )
        let mockResponse = TimeSeriesResponse(
            metaData: MetaData(
                information: "Monthly Prices (open, high, low, close) and Volumes",
                symbol: "A",
                lastRefreshed: "2025-02-14"
            ),
            timeSeries: [
                "2025-02-14": StockData(open: "252.4000", high: "265.7200", low: "246.8700", close: "261.2800", volume: "50047921"),
                "2025-01-31": StockData(open: "221.8200", high: "261.8000", low: "214.6100", close: "255.7000", volume: "92424171"),
                "2024-12-31": StockData(open: "227.5000", high: "239.3500", low: "217.6523", close: "219.8300", volume: "81535689")
            ]
        )

        mockAPIService.mockTimeSeries = mockResponse
        
        let expectation = self.expectation(description: "Time series fetch succeeds")
        
        viewModel.$stockChart
            .dropFirst()
            .sink { chart in
                XCTAssertEqual(chart.count, 2)
                XCTAssertEqual(chart.first?.1, 150)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        viewModel.fetchStockData(stock: stock)
        
        // Then
        wait(for: [expectation], timeout: 2.0)
    }
}

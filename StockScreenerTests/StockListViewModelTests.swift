//
//  StockListViewModelTests.swift
//  StockScreenerTests
//
//  Created by Najihah on 16/02/2025.
//

import XCTest
import Combine
@testable import StockScreener

class StockListViewModelTests: XCTestCase {
    var viewModel: StockListViewModel!
    var mockAPIService: MockAPIService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockAPIService = MockAPIService()
        viewModel = StockListViewModel()
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        mockAPIService = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testFetchStockList_Success() {
        // Given
        let mockStocks = [StockListModel] = [
            StockListModel(
                symbol: "A",
                name: "Agilent Technologies Inc",
                exchange: "NYSE",
                assetType: "Stock",
                ipoDate: "1999-11-18",
                delistingDate: "",
                status: "Active"
            ),
            StockListModel(
                symbol: "AA",
                name: "Alcoa Corp",
                exchange: "NYSE",
                assetType: "Stock",
                ipoDate: "2016-10-18",
                delistingDate: "",
                status: "Active"
            )
           ]
        mockAPIService.mockStockList = mockStocks
        
        let expectation = self.expectation(description: "Stock list fetch succeeds")
        
        viewModel.$stocks
            .dropFirst()
            .sink { stocks in
                XCTAssertEqual(stocks.count, 2)
                XCTAssertEqual(stocks.first?.symbol, "AAPL")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        viewModel.fetchStockList()
        
        // Then
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testFetchStockList_Failure() {
        // Given
        mockAPIService.shouldReturnError = true
        
        let expectation = self.expectation(description: "Stock list fetch fails")
        
        viewModel.$errorMessage
            .dropFirst()
            .sink { errorMessage in
                XCTAssertNotNil(errorMessage)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        viewModel.fetchStockList()
        
        // Then
        wait(for: [expectation], timeout: 2.0)
    }
}

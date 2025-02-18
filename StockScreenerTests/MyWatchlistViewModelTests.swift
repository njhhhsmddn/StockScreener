//
//  MyWatchlistViewModelTests.swift
//  StockScreenerTests
//
//  Created by Najihah on 18/02/2025.
//

import XCTest
@testable import StockScreener

class MyWatchlistViewModelTests: XCTestCase {
    var viewModel: MyWatchlistViewModel!

    override func setUp() {
        super.setUp()
        viewModel = MyWatchlistViewModel()
    }
        
        override func tearDown() {
            viewModel = nil
            super.tearDown()
        }
        
        func testToggleWatchlist_AddsAndRemovesStock() {
            let stock = StockListModel(
                symbol: "A",
                name: "Agilent Technologies Inc",
                exchange: "NYSE",
                assetType: "Stock",
                ipoDate: "1999-11-18",
                delistingDate: "",
                status: "Active"
            )
            
            viewModel.toggleWatchlist(stock: stock)
            XCTAssertTrue(viewModel.watchlist.contains { $0.symbol == stock.symbol })
            
            viewModel.toggleWatchlist(stock: stock)
            XCTAssertFalse(viewModel.watchlist.contains { $0.symbol == stock.symbol })
        }
        
        func testSaveAndLoadWatchlist() {
            let stock = StockListModel(
                symbol: "A",
                name: "Agilent Technologies Inc",
                exchange: "NYSE",
                assetType: "Stock",
                ipoDate: "1999-11-18",
                delistingDate: "",
                status: "Active"
            )
            viewModel.toggleWatchlist(stock: stock)
            
            let newViewModel = MyWatchlistViewModel()
            XCTAssertTrue(newViewModel.watchlist.contains { $0.symbol == stock.symbol })
        }

}

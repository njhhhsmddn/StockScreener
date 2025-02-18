//
//  MockAPIService.swift
//  StockScreener
//
//  Created by Najihah on 17/02/2025.
//
import Foundation
import Combine
@testable import StockScreener

class MockAPIService {
    var mockStockList: [StockListModel]?
    var mockStockDetails: StockDetails?
    var mockTimeSeries: TimeSeriesResponse?
    var shouldReturnError = false
    
    func fetchData<T: Decodable>(from urlString: String, expectingCSV: Bool) -> AnyPublisher<T, Error> {
        if shouldReturnError {
            return Fail(error: URLError(.badServerResponse)).eraseToAnyPublisher()
        }
        
        if let stockList = mockStockList as? T {
            return Just(stockList)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        if let stockDetails = mockStockDetails as? T {
            return Just(stockDetails)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        if let timeSeries = mockTimeSeries as? T {
            return Just(timeSeries)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
    }
}

//
//  StockChartModel.swift
//  StockScreener
//
//  Created by Najihah on 12/02/2025.
//
import Foundation

struct TimeSeriesResponse: Decodable {
    let metaData: MetaData
    let timeSeries: [String: StockData]

    enum CodingKeys: String, CodingKey {
        case metaData = "Meta Data"
        case timeSeries = "Monthly Time Series"
    }
}

struct MetaData: Decodable {
    let information: String
    let symbol: String
    let lastRefreshed: String
    let timeZone: String

    enum CodingKeys: String, CodingKey {
        case information = "1. Information"
        case symbol = "2. Symbol"
        case lastRefreshed = "3. Last Refreshed"
        case timeZone = "4. Time Zone"
    }
}

struct StockData: Decodable {
    let open: String
    let high: String
    let low: String
    let close: String
    let volume: String

    enum CodingKeys: String, CodingKey {
        case open = "1. open"
        case high = "2. high"
        case low = "3. low"
        case close = "4. close"
        case volume = "5. volume"
    }
}


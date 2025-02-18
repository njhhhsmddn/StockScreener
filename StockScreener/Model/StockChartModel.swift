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
    }
    
    init(metaData: MetaData, timeSeries: [String: StockData]) {
        self.metaData = metaData
        self.timeSeries = timeSeries
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        metaData = try container.decode(MetaData.self, forKey: .metaData)

        let fullContainer = try decoder.container(keyedBy: DynamicCodingKeys.self)

        if let monthlyData = try? fullContainer.decode([String: StockData].self, forKey: DynamicCodingKeys(stringValue: "Monthly Time Series")!) {
            timeSeries = monthlyData
        } else if let dailyData = try? fullContainer.decode([String: StockData].self, forKey: DynamicCodingKeys(stringValue: "Time Series (Daily)")!) {
            timeSeries = dailyData
        } else {
            throw DecodingError.dataCorruptedError(forKey: DynamicCodingKeys(stringValue: "TimeSeries")!, in: fullContainer, debugDescription: "Neither 'Monthly Time Series' nor 'Time Series (Daily)' found")
        }
    }

    private struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        init?(stringValue: String) { self.stringValue = stringValue }
        var intValue: Int? { return nil }
        init?(intValue: Int) { return nil }
    }
}

struct MetaData: Decodable {
    let information: String
    let symbol: String
    let lastRefreshed: String

    enum CodingKeys: String, CodingKey {
        case information = "1. Information"
        case symbol = "2. Symbol"
        case lastRefreshed = "3. Last Refreshed"
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


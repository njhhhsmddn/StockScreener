//
//  StockDetailsModel.swift
//  StockScreener
//
//  Created by Najihah on 07/02/2025.
//

import Foundation

struct StockDetails: Codable {
    let symbol: String
    let name: String
    let marketCapitalization: String
    let dividendYield: String
    let week52High: String
    let week52Low: String
    let latestQuarter: String
    let eps: String

    enum CodingKeys: String, CodingKey {
        case symbol = "Symbol"
        case name = "Name"
        case marketCapitalization = "MarketCapitalization"
        case dividendYield = "DividendYield"
        case week52High = "52WeekHigh"
        case week52Low = "52WeekLow"
        case latestQuarter = "LatestQuarter"
        case eps = "EPS"
    }
}

struct StockChart: Codable {
    let monthlyTimeSeries: [String: StockPrice]

    enum CodingKeys: String, CodingKey {
        case monthlyTimeSeries = "Monthly Time Series"
    }
}

struct StockPrice: Codable {
    let close: String

    enum CodingKeys: String, CodingKey {
        case close = "4. close"
    }
}

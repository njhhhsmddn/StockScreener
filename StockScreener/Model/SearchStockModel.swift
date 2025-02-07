//
//  SearchStockModel.swift
//  StockScreener
//
//  Created by Najihah on 06/02/2025.
//
import Foundation

struct SearchStockModel: Identifiable, Codable {
    let id = UUID()
    let symbol: String
    let name: String
    let type: String
    let region: String
    let currency: String

    enum CodingKeys: String, CodingKey {
        case symbol = "1. symbol"
        case name = "2. name"
        case type = "3. type"
        case region = "4. region"
        case currency = "8. currency"
    }
}

//
//  StockListModel.swift
//  StockScreener
//
//  Created by Najihah on 04/02/2025.
//

import Foundation

struct StockListModel: Identifiable, Codable {
    var id = UUID()
    let symbol: String
    let name: String
    let exchange: String
    let assetType: String
    let ipoDate: String
    let delistingDate: String
    let status: String
}


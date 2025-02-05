//
//  StockListModel.swift
//  StockScreener
//
//  Created by Najihah on 04/02/2025.
//

import Foundation

struct StockListModel: Identifiable, Equatable {
    let id = UUID()
    let symbol: String
    let name: String
    let exchange: String
    let assetType: String
    let ipoDate: String
    let delistingDate: String
    let status: String
    
    static func == (lhs: StockListModel, rhs: StockListModel) -> Bool {
            return lhs.symbol == rhs.symbol
        }
}


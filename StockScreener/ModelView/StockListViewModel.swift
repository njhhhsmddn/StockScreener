//
//  StockListViewModel.swift
//  StockScreener
//
//  Created by Najihah on 04/02/2025.
//
import Foundation

import SwiftUI

class StockListViewModel: ObservableObject {
    @Published var stocks: [StockListModel] = []
    
    private let apiKey = "5NT266T5BEMJWU3Y"

    func fetchCSV() {
        let urlString = "https://www.alphavantage.co/query?function=LISTING_STATUS&apikey=\(apiKey)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data, let csvString = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.stocks = self.parseCSV(csvString)
                }
            } else {
                print("Error fetching CSV: \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume()
    }
    
    private func parseCSV(_ csvString: String) -> [StockListModel] {
        let lines = csvString.components(separatedBy: "\n").dropFirst() // Skip header
        return lines.compactMap { line in
            let columns = line.components(separatedBy: ",")
            guard columns.count >= 6 else { return nil }
            
            return StockListModel(
                symbol: columns[0],
                name: columns[1],
                exchange: columns[2],
                assetType: columns[3],
                ipoDate: columns[4],
                delistingDate: columns[5],
                status: columns.count > 6 ? columns[6] : ""
            )
        }
    }
}


//
//  StockListViewModel.swift
//  StockScreener
//
//  Created by Najihah on 04/02/2025.
//
import Foundation


class StockListViewModel: ObservableObject {
    @Published var stocks: [StockListModel] = []
    @Published var searchResults: [SearchStockModel] = []
    
    private let apiKey = "5NT266T5BEMJWU3Y"

    func fetchCSV() {
        let urlString = "https://www.alphavantage.co/query?function=LISTING_STATUS&apikey=\(apiKey)"
        
        NetworkManager.shared.fetchRawData(urlString: urlString) { result in
            switch result {
            case .success(let data):
                if let csvString = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        self.stocks = self.parseCSV(csvString)
                    }
                } else {
                    print("Failed to convert CSV data to string")
                }
            case .failure(let error):
                print("Error fetching CSV: \(error)")
            }
        }
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
    
    func searchStocks(query: String) {
        guard !query.isEmpty else {
            DispatchQueue.main.async { self.searchResults = [] }
            return
        }

        let urlString = "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=\(query)&apikey=\(apiKey)"

        NetworkManager.shared.fetch(urlString: urlString, decodingType: [String: [SearchStockModel]].self) { result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self.searchResults = response["bestMatches"] ?? []
                    print("Search bar results: \(self.searchResults)")
                }
            case .failure(let error):
                print("Error fetching search results: \(error)")
            }
        }
    }
    
    var filteredStocks: [StockListModel] {
            if searchResults.isEmpty {
                return stocks  // Show all stocks if no search
            } else {
                let allMatch = stocks.allSatisfy { stock in
                    searchResults.contains { $0.symbol == stock.symbol }
                }

                let searchFilter = allMatch ? stocks : stocks.filter { stock in
                    searchResults.contains { $0.symbol == stock.symbol }
                }

                print("result compare \(searchFilter)")
                return searchFilter
               
            }
        }
}


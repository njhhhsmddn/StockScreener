//
//  MyWatchlistViewModel.swift
//  StockScreener
//
//  Created by Najihah on 14/02/2025.
//

import Foundation
import Combine

class MyWatchlistViewModel: BaseViewModel {
    private var cancellables = Set<AnyCancellable>()
    @Published var stockDetails: [String: (currentPrice: Double, percentageChange: Double)] = [:]
    @Published var watchlist: [StockListModel] = [] {
        didSet {
            saveWatchlist()
        }
    }
    
    private let watchlistKey = "watchlistKey"
   
    override init() {
        super.init()
        self.loadWatchlist()
    }
    
    func toggleWatchlist(stock: StockListModel) {
        if let index = watchlist.firstIndex(where: { $0.symbol == stock.symbol }) {
            watchlist.remove(at: index)
        } else {
            watchlist.append(stock)
        }
    }
    
    private func saveWatchlist() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(watchlist) {
            UserDefaults.standard.set(encoded, forKey: watchlistKey)
        }
    }

    func loadWatchlist() {
        if let savedData = UserDefaults.standard.data(forKey: watchlistKey) {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([StockListModel].self, from: savedData) {
                watchlist = decoded
                fetchTimeSeriesForWatchlist()
            }
        }
    }
    
    private func fetchTimeSeriesForWatchlist() {
        for stock in watchlist {
            fetchTimeSeriesDaily(stock: stock)
        }
    }
    
    private func fetchTimeSeriesDaily(stock: StockListModel) {
        let urlString = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=\(stock.symbol)&apikey=\(apiKey)"
        
        fetchData(from: urlString, expectingCSV: false)
            .sink(receiveCompletion: { [weak self] completion in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                }
            }, receiveValue: { [weak self] (result: TimeSeriesResponse) in
                DispatchQueue.main.async {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"

                    // Convert and sort dates in descending order
                    let sortedPrices = result.timeSeries.compactMap { (key, value) -> (Date, Double)? in
                        guard let date = dateFormatter.date(from: key),
                              let closePrice = Double(value.close) else { return nil }
                        return (date, closePrice)
                    }
                    .sorted { $0.0 > $1.0 } // Sort by date, latest first
    
                    // Calculate percentage change
                    if let currentPrice = sortedPrices.first?.1,
                       let previousPrice = sortedPrices.dropFirst().first?.1 {
                        
                        let percentageChange = ((currentPrice - previousPrice) / previousPrice) * 100
                        let formattedPercentageChange = Double(String(format: "%.2f", percentageChange)) ?? 0.0
                        print("Current Price: \(currentPrice), Previous Price: \(previousPrice)")
                        print("Percentage Change: \(formattedPercentageChange)%")
                        
                        self?.stockDetails[stock.symbol] = (currentPrice: currentPrice, percentageChange: formattedPercentageChange)
                        
                    }
                }
            })
            .store(in: &cancellables)
    }
}

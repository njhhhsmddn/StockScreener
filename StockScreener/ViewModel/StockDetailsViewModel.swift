//
//  StockDetailsViewModel.swift
//  StockScreener
//
//  Created by Najihah on 07/02/2025.
//
import Foundation
import Combine

class StockDetailsViewModel: BaseViewModel {
    private var cancellables = Set<AnyCancellable>()
    @Published var stockDetails: StockDetails?
    @Published var stockChart: [(Date, Double)] = []
    @Published var currentPrice: Double = 0
    @Published var marketCap: String = "N/A"
    @Published var dividendYield: String = "N/A"
    @Published var week52High: Double?
    @Published var week52Low: Double?
    @Published var stockName: String = "N/A"
   
    
    func fetchStockData(stock: StockListModel) {
        let stockDetailsURL = "https://www.alphavantage.co/query?function=OVERVIEW&symbol=\(stock.symbol)&apikey=\(apiKey)"
        let timeSeriesURL = "https://www.alphavantage.co/query?function=TIME_SERIES_MONTHLY&symbol=\(stock.symbol)&apikey=\(apiKey)"

        fetchStockDetails(urlString: stockDetailsURL)
        fetchTimeSeriesMonthly(urlString: timeSeriesURL)
    }

    private func fetchStockDetails(urlString: String) {
        isLoading = true
        fetchData(from: urlString, expectingCSV: false)
            .sink(receiveCompletion: { [weak self] completion in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                }
            }, receiveValue: { [weak self] result in
                DispatchQueue.main.async {
                    self?.stockDetails = result
                    self?.stockName = self?.stockDetails?.name ?? "N/A"
                    self?.marketCap = self?.formattedNumber(numberString: self?.stockDetails?.marketCapitalization ?? "0") ?? "N/A"
                    self?.dividendYield = "\(String(format: "%.2f", Double((self?.stockDetails!.dividendYield)!) ?? 0))%"
                    self?.week52High = Double(self?.stockDetails!.week52High ?? "0")
                    self?.week52Low = Double(self?.stockDetails!.week52Low ?? "0")
                    
                }
            })
            .store(in: &cancellables)
    }
    
    private func fetchTimeSeriesMonthly(urlString: String) {
        isLoading = true
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
                    

                    // Take the latest 12 months
                    self?.stockChart = Array(sortedPrices.prefix(12))
                    
                    // Get current price
                    if let currentPrice = sortedPrices.first?.1 {
                        self?.currentPrice = currentPrice
                    }
                }
            })
            .store(in: &cancellables)
    }
    
    func formattedNumber(numberString: String) -> String {
        if let number = Int(numberString) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter.string(from: NSNumber(value: number)) ?? numberString
        }
        return numberString
    }
}


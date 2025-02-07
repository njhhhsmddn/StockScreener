//
//  StockDetailsViewModel.swift
//  StockScreener
//
//  Created by Najihah on 07/02/2025.
//
import SwiftUI

class StockDetailsViewModel: ObservableObject {
    @Published var stockPrices: [(date: Date, close: Double)] = []
    @Published var currentPrice: Double?
    @Published var marketCap: String = "N/A"
    @Published var dividendYield: String = "N/A"
    @Published var week52High: Double?
    @Published var week52Low: Double?
    @Published var stockName: String = "Loading..."
    private let apiKey = "5NT266T5BEMJWU3Y"
    func fetchStockData() {
        let stockDetailsURL = "https://www.alphavantage.co/query?function=OVERVIEW&symbol=IBM&apikey=\(apiKey)"
        let timeSeriesURL = "https://www.alphavantage.co/query?function=TIME_SERIES_MONTHLY&symbol=IBM&apikey=\(apiKey)"

        fetchStockDetails(urlString: stockDetailsURL)
        fetchTimeSeries(urlString: timeSeriesURL)
    }

    private func fetchStockDetails(urlString: String) {
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }

            do {
                let decodedData = try JSONDecoder().decode(StockDetails.self, from: data)
                
                DispatchQueue.main.async {
                    self.stockName = decodedData.name
                    self.marketCap = "$\(decodedData.marketCapitalization)"
                    self.dividendYield = "\(String(format: "%.2f", Double(decodedData.dividendYield) ?? 0))%"
                    self.week52High = Double(decodedData.week52High)
                    self.week52Low = Double(decodedData.week52Low)
                }
            } catch {
                print("Error decoding stock details JSON: \(error)")
            }
        }.resume()
    }

    private func fetchTimeSeries(urlString: String) {
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }

            do {
                let decodedData = try JSONDecoder().decode(StockChart.self, from: data)

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"

                var prices: [(Date, Double)] = []

                for (key, value) in decodedData.monthlyTimeSeries {
                    if let date = dateFormatter.date(from: key),
                       let closePrice = Double(value.close) {
                        prices.append((date, closePrice))
                    }
                }

                prices.sort { (lhs: (date: Date, close: Double), rhs: (date: Date, close: Double)) in
                    lhs.date < rhs.date
                }

                DispatchQueue.main.async {
                    self.stockPrices = prices
                    self.currentPrice = prices.last?.1
                }

            } catch {
                print("Error decoding time series JSON: \(error)")
            }
        }.resume()
    }
}


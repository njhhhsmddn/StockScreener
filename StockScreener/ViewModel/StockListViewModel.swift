//
//  StockListViewModel.swift
//  StockScreener
//
//  Created by Najihah on 04/02/2025.
//
import Foundation
import Combine

class StockListViewModel: BaseViewModel {
    private var cancellables = Set<AnyCancellable>()
    @Published var stocks: [StockListModel] = []

    func fetchStockList() {
        isLoading = true
        fetchData(from: "https://www.alphavantage.co/query?function=LISTING_STATUS&apikey=\(apiKey)", expectingCSV: true, fileName: "stock_list")
            .sink(receiveCompletion: { [weak self] completion in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                }
            }, receiveValue: { [weak self] (result: [StockListModel]) in
                DispatchQueue.main.async {
                    self?.stocks = result.filter { $0.assetType == "Stock" } // Filter only shows when assetType == "Stock" not "ETF"
                }
            })
            .store(in: &cancellables)
    }
}


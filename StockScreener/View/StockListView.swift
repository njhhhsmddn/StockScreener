//
//  ContentView.swift
//  StockScreener
//
//  Created by Najihah on 04/02/2025.
//

import SwiftUI

struct StockListView: View {
    @StateObject private var viewModel = StockListViewModel()
    @State private var searchText = ""
    @State private var watchlist: [StockListModel] = [] // Holds favorite stocks

    var filteredStocks: [StockListModel] {
        if searchText.isEmpty {
            return viewModel.stocks
        } else {
            return viewModel.stocks.filter {
                $0.symbol.lowercased().contains(searchText.lowercased()) ||
                $0.name.lowercased().contains(searchText.lowercased())
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                // 🔎 Search Bar
                TextField("🔎 Search stocks...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                // 📜 Stock List
                List(filteredStocks) { stock in
                    StockRow(stock: stock, isWatchlisted: watchlist.contains(stock)) {
                        addToWatchlist(stock)
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                    .listRowSeparator(.hidden)
                    .background(Color.black)
                    .cornerRadius(8)
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Stock Listings")
            .onAppear {
                viewModel.fetchCSV()
            }
        }
    }

    // Add to Watchlist
    private func addToWatchlist(_ stock: StockListModel) {
        if !watchlist.contains(stock) {
            watchlist.append(stock)
        }
    }

    // Remove from Watchlist
    private func removeFromWatchlist(_ stock: StockListModel) {
        watchlist.removeAll { $0.id == stock.id }
    }
}

// Stock Row Component
struct StockRow: View {
    let stock: StockListModel
    let isWatchlisted: Bool
    let action: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(stock.symbol)
                    .font(.headline)
                    .foregroundStyle(Color.white)
                Text(stock.name)
                    .font(.subheadline)
                    .foregroundStyle(Color.white)
            }
            .padding()
            Spacer()
            Button(action: action) {
                Image(systemName: isWatchlisted ? "star.fill" : "star")
                    .foregroundColor(isWatchlisted ? .yellow : .gray)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}


#Preview {
    StockListView()
}

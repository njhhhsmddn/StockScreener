//
//  ContentView.swift
//  StockScreener
//
//  Created by Najihah on 04/02/2025.
//

import SwiftUI

struct StockListView: View {
    @EnvironmentObject var watchlistViewModel: MyWatchlistViewModel
    @ObservedObject var viewModel: StockListViewModel
    @State private var searchText = ""
    @State private var showCancelButton: Bool = false
    @State private var showToast = false
    
    var filteredStocks: [StockListModel] {
            if searchText.isEmpty {
                return viewModel.stocks
            } else {
                return viewModel.stocks.filter {
                    $0.symbol.lowercased().contains(searchText.lowercased())
                }
            }
        }
    
    var body: some View {
        NavigationView {
                   VStack {
                       // Stock List with searchable
                       if viewModel.isLoading {
                            ProgressView("Loading...")
                        } else if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                        } else if viewModel.stocks.isEmpty {
                            Text("No data available.")
                            .foregroundColor(.gray)
                            .padding()
                        } else if filteredStocks.isEmpty && !searchText.isEmpty {
                            Text("No match found.")
                            .foregroundColor(.gray)
                            .padding()
                        } else {
                            List(filteredStocks) { stock in
                                HStack{
                                    NavigationLink(destination: StockDetailsView(stock: stock)) {
                                        StockRow(stock: stock, isWatchlisted: watchlistViewModel.watchlist.contains(where: { $0.symbol == stock.symbol })) {
                                            watchlistViewModel.toggleWatchlist(stock: stock)
                                            if watchlistViewModel.watchlist.contains(where: { $0.symbol == stock.symbol }) {
                                                showToast.toggle()
                                            }
                                            }
                                        }
                                        .background(Color.teal.gradient, in: RoundedRectangle(cornerRadius: 10))
                                        .listRowSeparator(.hidden)
                                    }
                                    .listRowSeparator(.hidden)
                                    .foregroundStyle(Color.clear)
                                }
                                .listStyle(PlainListStyle())
                            }
                   }
                   .navigationTitle("Stock Listings")
                   .onAppear {
                        viewModel.fetchStockList()
                    }
                   .searchable(text: $searchText, prompt: "Search stocks")
                   .toast(toastView: ToastView(dataModel: ToastDataModel(title: "Added to watchlist", image: "star"), show: $showToast), show: $showToast)
               }
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
                    .foregroundColor(isWatchlisted ? .yellow : .white)
            }
            .buttonStyle(BorderlessButtonStyle())
            .padding()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    let mockViewModel = StockListViewModel()
    mockViewModel.stocks = [
        StockListModel(symbol: "AA", name: "Apple Inc.", exchange: "", assetType: "", ipoDate: "", delistingDate: "", status: ""),
        StockListModel(symbol: "TESC", name: "tesco", exchange: "", assetType: "", ipoDate: "", delistingDate: "", status: "")
       ]
    return StockListView(viewModel: mockViewModel)
        .environmentObject(MyWatchlistViewModel())
}

//
//  ContentView.swift
//  StockScreener
//
//  Created by Najihah on 04/02/2025.
//

import SwiftUI

struct StockListView: View {
    @ObservedObject var viewModel: StockListViewModel
    @State private var searchText = ""
    @State private var showCancelButton: Bool = false
    
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
                       List(filteredStocks) { stock in
                           HStack{
                               NavigationLink(destination: StockDetailsView(stock: stock)) {
                                   StockRow(stock: stock, isWatchlisted: viewModel.watchlist.contains(where: { $0.symbol == stock.symbol })) {
                                       viewModel.toggleWatchlist(stock: stock)
                                   }
                           }
                               .listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                               .listRowSeparator(.hidden)
                               .background(Color.black.gradient, in: RoundedRectangle(cornerRadius: 10))
                               .cornerRadius(8)
                           }
                           .listRowSeparator(.hidden)
                           .foregroundStyle(Color.clear)
                       }
                       .listStyle(PlainListStyle())
                   }
                   .navigationTitle("Stock Listings")
                   .onAppear {
                       viewModel.fetchCSV()
                   }
                   .searchable(text: $searchText, prompt: "Search stocks")
                       
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
                    .foregroundColor(isWatchlisted ? .yellow : .gray)
            }
            .buttonStyle(BorderlessButtonStyle())
            .padding()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

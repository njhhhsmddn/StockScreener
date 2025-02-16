//
//  MyWatchlistView.swift
//  StockScreener
//
//  Created by Najihah on 07/02/2025.
//

import SwiftUI

struct MyWatchlistView: View {
    @EnvironmentObject var viewModel: MyWatchlistViewModel
    
    var body: some View {
         NavigationView {
             VStack {
                 if viewModel.watchlist.isEmpty {
                     Text("You have no watchlist yet!")
                     .foregroundColor(.gray)
                     .padding()
                 } else {
                     List {
                         ForEach(viewModel.watchlist, id: \.id) { stock in
                             if let stockInfo = viewModel.stockDetails[stock.symbol] {
                                 ListCell(
                                     stock: stock,
                                     isWatchlisted: true,
                                     currentPrice: stockInfo.currentPrice,
                                     percentageChange: stockInfo.percentageChange
                                 ) {
                                     viewModel.toggleWatchlist(stock: stock)
                                 }
                                 .listRowSeparator(.hidden)
                             } else {
                                 // Show a placeholder while data loads
                                 ListCell(
                                     stock: stock,
                                     isWatchlisted: true,
                                     currentPrice: 0.0,
                                     percentageChange: 0.0
                                 ) {
                                     viewModel.toggleWatchlist(stock: stock)
                                 }
                                 .listRowSeparator(.hidden)
                             }
                             
                         }
                         .onMove(perform: moveRow) // Enable row moving
                         
                     }
                     .listStyle(.plain)
                 }
             }
             .navigationTitle("My Watchlist")
             .navigationBarTitleDisplayMode(.inline)
                 .toolbar {
                     if !viewModel.watchlist.isEmpty {
                        EditButton()
                    }
                 }
         }
     }

    func moveRow(from source: IndexSet, to destination: Int) {
        viewModel.watchlist.move(fromOffsets: source, toOffset: destination)
    }
}

struct ListCell: View {
    let stock: StockListModel
    let isWatchlisted: Bool
    let currentPrice: Double
    let percentageChange: Double
    let action: () -> Void
    var body: some View {
        ZStack(alignment: .leading) {
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
                VStack(alignment: .trailing, spacing: 0) {
                    Text(String(format: "$%.2f", currentPrice))
                        .font(.headline)
                        .foregroundStyle(Color.white)
                    HStack{
                        Image(systemName: percentageChange > 0 ? "arrowshape.up" : "arrowshape.down")
                            .resizable()
                            .frame(width: 12, height: 12)
                            .foregroundStyle(percentageChange > 0 ? .black : .red)
                        
                        Text(String(format: "%.2f%%", percentageChange))
                            .font(.subheadline)
                            .foregroundStyle(percentageChange > 0 ? Color.black : Color.red)
                    }
                    
                }
                .padding(.trailing, 5)
                
                Button(action: action) {
                    Image(systemName: isWatchlisted ? "star.fill" : "star")
                        .foregroundColor(isWatchlisted ? .yellow : .gray)
                }
                .padding()
            }.buttonStyle(BorderlessButtonStyle())
            
            NavigationLink(destination: StockDetailsView(stock: stock)) {
                EmptyView()
            }
            .opacity(0.0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .background(Color.teal.gradient, in: RoundedRectangle(cornerRadius: 10))
        .foregroundColor(.white)
        .listRowSeparator(.hidden)
    }
}

#Preview {
    MyWatchlistView()
}

//
//  MyWatchlistView.swift
//  StockScreener
//
//  Created by Najihah on 07/02/2025.
//

import SwiftUI

struct MyWatchlistView: View {
    @ObservedObject var viewModel: StockListViewModel
    
    var body: some View {
         NavigationView {
             VStack {
                 List {
                     ForEach(viewModel.watchlist) { stock in
//                         NavigationLink(destination: StockDetailsView(stock: stock)) {
                             ListCell(stock: stock, isWatchlisted: true) {
                                 viewModel.toggleWatchlist(stock: stock)
                             }
//                         }
                         .listRowSeparator(.hidden)
                         
                     }
                     .onMove(perform: moveRow) // Enable row moving
                     
                 }
                 .listStyle(.plain)
             }
             .navigationTitle("My Watchlist")
             .navigationBarTitleDisplayMode(.inline)
                 .toolbar {
                     EditButton()
                 }
         }
     }

    func moveRow(from source: IndexSet, to destination: Int) {
        viewModel.watchlist.move(fromOffsets: source, toOffset: destination)
    }
}

struct MyWatchlistRow: View {
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
            VStack(alignment: .trailing) {
                Text(stock.symbol)
                    .font(.headline)
                    .foregroundStyle(Color.white)
                Text(stock.name)
                    .font(.subheadline)
                    .foregroundStyle(Color.white)
            }
            .padding(.trailing, 5)
            
            Button(action: action) {
                Image(systemName: isWatchlisted ? "star.fill" : "star")
                    .foregroundColor(isWatchlisted ? .yellow : .gray)
            }
            .padding()
            
        }
        .buttonStyle(BorderlessButtonStyle())

    }
}

struct ListCell: View {
    let stock: StockListModel
    let isWatchlisted: Bool
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
                VStack(alignment: .trailing) {
                    Text(stock.symbol)
                        .font(.headline)
                        .foregroundStyle(Color.white)
                    Text(stock.name)
                        .font(.subheadline)
                        .foregroundStyle(Color.white)
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
        
        .frame(height: 50)
        .padding(.horizontal)
        .background(Color.teal.gradient, in: RoundedRectangle(cornerRadius: 10))
        .foregroundColor(.white)
        .listRowSeparator(.hidden)
    }
}

#Preview {
    let mockViewModel = StockListViewModel()
       mockViewModel.watchlist = [
        StockListModel(symbol: "ABC", name: "ABC DEFG", exchange: "", assetType: "", ipoDate: "", delistingDate: "", status: ""),
        StockListModel(symbol: "TESC", name: "tesco", exchange: "", assetType: "", ipoDate: "", delistingDate: "", status: "")
       ]
    return MyWatchlistView(viewModel: mockViewModel)
}

//
//  MainView.swift
//  StockScreener
//
//  Created by Najihah on 10/02/2025.
//

import SwiftUI

enum StockTab {
    case allStocks
    case watchlist
}

struct MainView: View {
    @StateObject var stockListViewModel = StockListViewModel()
    
    
    var body: some View {
        TabView {
            StockListView(viewModel: stockListViewModel)
                .tabItem { Label("Stocks", systemImage: "chart.bar") }
            
            MyWatchlistView()
                .tabItem { Label("Watchlist", systemImage: "star") }
        }
    }
}

#Preview {
    MainView()
}

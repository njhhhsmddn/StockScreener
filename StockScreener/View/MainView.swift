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
    @StateObject var viewModel = StockListViewModel()
    
    var body: some View {
        TabView {
            StockListView(viewModel: viewModel)
                .tabItem { Label("Stocks", systemImage: "chart.bar") }
            
            MyWatchlistView(viewModel: viewModel)
                .tabItem { Label("Watchlist", systemImage: "star") }
        }
    }
}

#Preview {
    MainView()
}

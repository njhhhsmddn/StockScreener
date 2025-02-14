//
//  StockScreenerApp.swift
//  StockScreener
//
//  Created by Najihah on 04/02/2025.
//

import SwiftUI

@main
struct StockScreenerApp: App {
    @StateObject var watchlistViewModel = MyWatchlistViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(watchlistViewModel)
        }
    }
}

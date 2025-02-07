//
//  StockDetailView.swift
//  StockScreener
//
//  Created by Najihah on 07/02/2025.
//

import SwiftUI

struct StockDetailView: View {
    let stock: StockListModel  // Replace with your stock model

    var body: some View {
        VStack {
            Text(stock.name) // Example usage
            Text("More stock details here...")
        }
        .navigationTitle(stock.name)
    }
}

#Preview {
    StockDetailView(stock: StockListModel(symbol: "", name: "Tesco", exchange: "", assetType: "", ipoDate: "", delistingDate: "", status: ""))
}

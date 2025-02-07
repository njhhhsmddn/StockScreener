//
//  StockDetailView.swift
//  StockScreener
//
//  Created by Najihah on 07/02/2025.
//

import SwiftUI
import Charts

struct StockDetailsView: View {
    let stock: StockListModel  // Replace with your stock model
    @StateObject var viewModel = StockDetailsViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(viewModel.stockName)
                .font(.largeTitle)
                .bold()
                .padding(.bottom)

            HStack {
                Text("Current Price: ")
                Spacer()
                Text(viewModel.currentPrice != nil ? "$\(String(format: "%.2f", viewModel.currentPrice!))" : "Loading...")
                    .bold()
            }

            HStack {
                Text("Market Cap:")
                Spacer()
                Text(viewModel.marketCap)
                    .bold()
            }

            HStack {
                Text("Dividend Yield:")
                Spacer()
                Text(viewModel.dividendYield)
                    .bold()
            }

            HStack {
                Text("52-Week High:")
                Spacer()
                Text(viewModel.week52High != nil ? "$\(String(format: "%.2f", viewModel.week52High!))" : "Loading...")
                    .bold()
            }

            HStack {
                Text("52-Week Low:")
                Spacer()
                Text(viewModel.week52Low != nil ? "$\(String(format: "%.2f", viewModel.week52Low!))" : "Loading...")
                    .bold()
            }

            Text("Historical Performance")
                .font(.headline)
                .padding(.top)

            Chart(viewModel.stockPrices, id: \.date) { stock in
                LineMark(
                    x: .value("Date", stock.date),
                    y: .value("Close Price", stock.close)
                )
                .foregroundStyle(.blue)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .symbol(.circle)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .month)) { value in
                    AxisValueLabel(format: .dateTime.month(.abbreviated))
                }
            }
            .chartYAxis {
                AxisMarks()
            }
            .frame(height: 250)
            .padding()

        }
        .padding()
        .onAppear {
            viewModel.fetchStockData()
        }
    }
}

#Preview {
    StockDetailsView(stock: StockListModel(symbol: "", name: "Tesco", exchange: "", assetType: "", ipoDate: "", delistingDate: "", status: ""))
}

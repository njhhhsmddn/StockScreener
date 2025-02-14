//
//  StockDetailView.swift
//  StockScreener
//
//  Created by Najihah on 07/02/2025.
//

import SwiftUI
import Charts

struct StockDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var watchlistViewModel: MyWatchlistViewModel
    let stock: StockListModel
    @StateObject var viewModel = StockDetailsViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Back button and star button
                HStack {
                    Button(action: { dismiss() }) {
                                    Image(systemName: "arrow.backward")
                                        .foregroundColor(.blue)
                                        .padding(.vertical, 8)
                                        .contentShape(Rectangle())
                                }
                    Spacer()
                    Button(action: {
                        watchlistViewModel.toggleWatchlist(stock: stock)
                    }) {
                        Image(systemName: watchlistViewModel.watchlist.contains(where: { $0.symbol == stock.symbol }) ? "star.fill" : "star")
                            .foregroundColor(watchlistViewModel.watchlist.contains(where: { $0.symbol == stock.symbol }) ? .yellow : .gray)
                    }
                    .frame(width: 55, height: 55)
                    
                }
                
                // Stock Header
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundColor(.blue)
                        .imageScale(.large)
                    Text(viewModel.stockName)
                        .font(.title2)
                        .bold()
                }
                .padding(.horizontal)
                
                // Price and Change Info
                HStack {
                    Text("Current price:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(viewModel.currentPrice != 0 ? "$\(String(format: "%.2f", viewModel.currentPrice))" : "$0")
                        .font(.title)
                        .bold()
                }
                .padding(.horizontal)

                // Chart
                LineChartView(stockPrices: viewModel.stockChart)
                    .frame(height: 400)
                    .padding(.horizontal)
               
                // Market Info Cards
                VStack(spacing: 12) {
                    HStack(spacing: 16) {
                        ItemView(value: "$\(viewModel.marketCap)", title: "Market Cap")
                        ItemView(value: viewModel.dividendYield, title: "Dividend Yield")
                    }
                    
                    Divider().padding(.horizontal)

                    HStack(spacing: 16) {
                        ItemView(value: viewModel.week52High != nil ? "$\(String(format: "%.2f", viewModel.week52High!))" : "N/A", title: "52-Week High")
                        ItemView(value: viewModel.week52Low != nil ? "$\(String(format: "%.2f", viewModel.week52Low!))" : "N/A", title: "52-Week Low")
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 4)
                )
                .padding(.horizontal)
            }
            .padding()
        }
        .onAppear {
            viewModel.fetchStockData(stock: stock)
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.backward")
                }
                .contentShape(Rectangle()) // Ensures better tap area
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    watchlistViewModel.toggleWatchlist(stock: stock)
                }) {
                    Image(systemName: watchlistViewModel.watchlist.contains(where: { $0.symbol == stock.symbol }) ? "star.fill" : "star")
                        .foregroundColor(watchlistViewModel.watchlist.contains(where: { $0.symbol == stock.symbol }) ? .yellow : .gray)
                }
                .frame(width: 44, height: 44) // Better tap area
            }
        }
    }

}

#Preview {
    StockDetailsView(stock: StockListModel(symbol: "A", name: "Tesco", exchange: "", assetType: "", ipoDate: "", delistingDate: "", status: ""))
}

struct ItemView: View {
    let value: String
    let title: String

    var body: some View {
        VStack {
            Text(value)
                .font(.headline)
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity) // Ensure equal spacing
    }
}

struct LineChartView: View {
    let stockPrices: [(Date, Double)]
    
    var gradientColor: LinearGradient {
        LinearGradient(
            gradient: Gradient(
                colors: [
                    Color.pink.opacity(0.8),
                    Color.pink.opacity(0.01),
                ]
            ),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    var body: some View {
        Chart {
            ForEach(stockPrices, id: \.0) { (date, closePrice) in
                AreaMark(
                    x: .value("Date", date, unit: .month),
                    yStart: .value("Close Price", 20),
                    yEnd: .value("Close Price",  closePrice)
                )
              .foregroundStyle(gradientColor)
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) { _ in
                AxisValueLabel(format: .dateTime.month(.abbreviated))
            }
        }
        .chartYAxis {
            AxisMarks() {
                AxisValueLabel()
                AxisGridLine()
            }
        }
        .frame(height: 400)
        .padding()
    }
}

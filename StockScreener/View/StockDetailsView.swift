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
    @State private var showToast = false

    var body: some View {
        ZStack {
            if viewModel.isLoading {
                CustomBackButtonView(action: { dismiss() })
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else if let errorMessage = viewModel.errorMessage {
                CustomBackButtonView(action: { dismiss() })
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                VStack {
                    // Normal content layout when not loading/error
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "arrow.backward")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .padding(.vertical, 8)
                                .contentShape(Rectangle())
                        }
                        Spacer()
                        Button(action: {
                            watchlistViewModel.toggleWatchlist(stock: stock)
                            if watchlistViewModel.watchlist.contains(where: { $0.symbol == stock.symbol }) {
                                showToast.toggle()
                            }
                            
                        }) {
                            Image(systemName: watchlistViewModel.watchlist.contains(where: { $0.symbol == stock.symbol }) ? "star.fill" : "star")
                                .foregroundColor(watchlistViewModel.watchlist.contains(where: { $0.symbol == stock.symbol }) ? .yellow : .gray)
                                .font(.title2)
                        }
                        .frame(width: 55, height: 55)
                    }
                    .padding(.horizontal)
                    
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
            }
        }
        .padding(.horizontal)
        .onAppear {
            viewModel.fetchStockData(stock: stock)
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .toast(toastView: ToastView(dataModel: ToastDataModel(title: "Added to watchlist", image: "star"), show: $showToast), show: $showToast)
    }
}

#Preview {
    let mockStock = StockListModel(
        symbol: "AAPL",
        name: "Apple Inc.",
        exchange: "NASDAQ",
        assetType: "Stock",
        ipoDate: "1980-12-12",
        delistingDate: "",
        status: "Active"
    )

    let mockViewModel = StockDetailsViewModel()
    mockViewModel.stockName = "Apple Inc."
    mockViewModel.currentPrice = 175.50
    mockViewModel.marketCap = "2.8T"
    mockViewModel.dividendYield = "0.60%"
    mockViewModel.week52High = 180.75
    mockViewModel.week52Low = 135.25

    let now = Date()
    mockViewModel.stockChart = [
        (Calendar.current.date(byAdding: .month, value: -5, to: now)!, 200.0),
        (Calendar.current.date(byAdding: .month, value: -4, to: now)!, 172.0),
        (Calendar.current.date(byAdding: .month, value: -3, to: now)!, 168.0),
        (Calendar.current.date(byAdding: .month, value: -2, to: now)!, 120.0),
        (Calendar.current.date(byAdding: .month, value: -1, to: now)!, 150.0),
        (now, 176.0)
    ]

    return StockDetailsView(stock: mockStock, viewModel: mockViewModel)
        .environmentObject(MyWatchlistViewModel()) 
}


struct CustomBackButtonView: View {
    let action: () -> Void

    var body: some View {
        VStack {
            // Back button at the top-left
            HStack {
                Button(action: action) {
                    Image(systemName: "arrow.backward")
                        .foregroundColor(.blue)
                        .padding()
                        .contentShape(Rectangle())
                }
                Spacer() // Pushes button to the left
            }
            .frame(maxWidth: .infinity, alignment: .leading) // Ensures it stays on the left
            .padding(.top, 16) // Adds spacing from the top
            
            Spacer() // Pushes content to center
        }
    }
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

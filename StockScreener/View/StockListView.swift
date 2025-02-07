//
//  ContentView.swift
//  StockScreener
//
//  Created by Najihah on 04/02/2025.
//

import SwiftUI

struct StockListView: View {
    @StateObject private var viewModel = StockListViewModel()
    @State private var searchText = ""
    @State private var showCancelButton: Bool = false
    @State private var watchlist: [StockListModel] = [] // Holds favorite stocks

    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                HStack{
                    HStack {
                        Image(systemName: "magnifyingglass")
                        
                        TextField("Search stocks", text: $searchText, onEditingChanged: { isEditing in
                            self.showCancelButton = true
                        }).foregroundColor(.primary)
                            .onChange(of: searchText) { newValue in
                                    viewModel.searchStocks(query: newValue)
                                }

                        
                        Button(action: {
                            self.searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill").opacity(searchText == "" ? 0 : 1)
                        }
                    }
                    .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
                    .foregroundColor(.secondary)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10.0)
                    
                    if showCancelButton  {
                        Button("Cancel") {
                                UIApplication.shared.endEditing(true) // this must be placed before the other commands here
                                self.searchText = ""
                                self.showCancelButton = false
                        }
                        .foregroundColor(Color(.systemBlue))
                    }
                }
            .padding(.horizontal)
            .navigationBarHidden(showCancelButton)
               
                
                // Stock List
                List(viewModel.filteredStocks) { stock in
                    NavigationLink(destination: StockDetailsView(stock: stock)) {
                        StockRow(stock: stock, isWatchlisted: watchlist.contains(stock)) {
                            addToWatchlist(stock)
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                        .listRowSeparator(.hidden)
                        .background(Color.black)
                        .cornerRadius(8)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Stock Listings")
            .onAppear {
                viewModel.fetchCSV()
            }
            .resignKeyboardOnDragGesture()
        }
    }

    // Add to Watchlist
    private func addToWatchlist(_ stock: StockListModel) {
        if !watchlist.contains(stock) {
            watchlist.append(stock)
        }
    }

    // Remove from Watchlist
    private func removeFromWatchlist(_ stock: StockListModel) {
        watchlist.removeAll { $0.id == stock.id }
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
            .padding()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    StockListView()
}

// MARK: - UIApplication extension for resgning keyboard on pressing the cancel buttion of the search bar
extension UIApplication {
    /// Resigns the keyboard.
    ///
    /// Used for resigning the keyboard when pressing the cancel button in a searchbar based on [this](https://stackoverflow.com/a/58473985/3687284) solution.
    /// - Parameter force: set true to resign the keyboard.
    func endEditing(_ force: Bool) {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        window?.endEditing(force)
    }
}

struct ResignKeyboardOnDragGesture: ViewModifier {
    var gesture = DragGesture().onChanged{_ in
        UIApplication.shared.endEditing(true)
    }
    func body(content: Content) -> some View {
        content.gesture(gesture)
    }
}

extension View {
    func resignKeyboardOnDragGesture() -> some View {
        return modifier(ResignKeyboardOnDragGesture())
    }
}

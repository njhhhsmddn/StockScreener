# ![40](https://github.com/user-attachments/assets/b3f66113-4648-49a2-bda5-fbebddff475d) Stock Screener App

Stock Screener App is a SwiftUI-based iOS application that provides stock data using an MVVM architecture. It efficiently handles API requests, supports offline caching, and implements request throttling to ensure a smooth user experience.
Application allows user to search for stocks, view the details and add watchlist of stocks.

## 🔖 Setup Instructions

### Prerequisites

- macOS with the latest version of Xcode (currently Xcode 15)
- Swift Package Manager (SPM) for dependency management

### Installation
1. Clone the repository:
```sh
https://github.com/njhhhsmddn/StockScreener.git
```
2. Install dependencies:
Ensure you have CocoaPods or Swift Package Manager installed, then run the following commands:
  * CocoaPods:
      ```sh
      pod install
      ```
  * Swift Package Manager (if using): Open the .xcodeproj or .xcworkspace file, and Xcode should automatically handle dependencies.

3. Open the project in Xcode:
Open the .xcworkspace file in Xcode.

4. Build and run the app:
Select the appropriate simulator or device, and hit ```Cmd + R``` to build and run the app.

## 📌 Architecture Overview

Stock Screener App follows the MVVM (Model-View-ViewModel) architecture pattern:

### **Model**

- Represents stock data and API response structures
- Example:
  ```swift
  struct StockListModel: Identifiable, Codable {
      var id: String { symbol }
      let symbol: String
      let name: String
      let exchange: String
      let assetType: String
      let ipoDate: String
      let delistingDate: String?
      let status: String?
  }
  ```

### **ViewModel**

- Handles API requests, data processing, and state management
- Implements caching, request throttling, and error handling
- Example:
  ```swift
  class StockListViewModel: BaseViewModel {
      private var cancellables = Set<AnyCancellable>()
      @Published var stocks: [StockListModel] = []
  
      func fetchStockList() {
          isLoading = true
          fetchData(from: "https://www.alphavantage.co/query?function=LISTING_STATUS&apikey=\(apiKey)", expectingCSV: true, fileName: "stock_list")
              .sink(receiveCompletion: { [weak self] completion in
                  DispatchQueue.main.async {
                      self?.isLoading = false
                      if case .failure(let error) = completion {
                          self?.errorMessage = error.localizedDescription
                      }
                  }
              }, receiveValue: { [weak self] result in
                  DispatchQueue.main.async {
                      self?.stocks = result
                  }
              })
              .store(in: &cancellables)
      }
  }
  ```

### **View**

- SwiftUI-based UI components that react to ViewModel state changes
- Example:
  ```swift
  struct StockListView: View {
      @StateObject var viewModel = StockListViewModel()
      
      var body: some View {
          List(viewModel.stocks) { stock in
              StockRow(stock: stock)
          }
          .onAppear {
              viewModel.fetchStocks()
          }
      }
  }
  ```
### Additional information
- Application only support offline for view List of Stocks.
- Current Price and Percentage Change at My Watchlist row is return from API time-series daily (might be display an empty value if limit usage of API is exceeded).

  
## ✨ Future Improvements

- **Better Offline Support**: Implement Core Data or File-based caching for stock data.
- **Pagination**: Support fetching data in chunks to improve performance.
- **Push Notifications**: Notify users of significant stock price changes.
- **Dark Mode Support**: Enhance UI/UX with dynamic themes.
- **Unit & UI Testing**: Expand test coverage with XCTest and SwiftUI previews.


## Screenshot of Application
<a List of Stocks>
<img src="https://github.com/user-attachments/assets/1368253c-11b3-4387-aaef-7215643b59ab" width="200">
  <a Stock Details>
  <img src="https://github.com/user-attachments/assets/b764c27b-085b-4e32-b63b-21c7e2daf38a" width="200">
  <a My Watchlist>
  <img src="https://github.com/user-attachments/assets/167c861d-e3e8-4baa-b791-a18a7ebee5d4" width="200">





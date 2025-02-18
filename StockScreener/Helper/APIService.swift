//
//  APIService.swift
//  StockScreener
//
//  Created by Najihah on 11/02/2025.
//

import Foundation
import Combine
import Network

class APIService {
    static let shared = APIService()
    
    func fetchData(from url: String, expectingCSV: Bool = false, fileName: String? = nil) -> AnyPublisher<Result<Data, APIError>, Never> {
        guard let requestURL = URL(string: url) else {
            return Just(.failure(.invalidURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: requestURL)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                    throw APIError.invalidResponse
                }
                
                if expectingCSV, let csvString = String(data: output.data, encoding: .utf8) {
                    if csvString.isEmpty || csvString == "{}" {
                        if let csvContent = self.readCSVFromBundle(fileName: fileName ?? "stock_list") {
                            let parsedData = self.parseCSV(csvContent)
                            return try JSONEncoder().encode(parsedData)
                        }
                    } else {
                        let csvData = self.parseCSV(csvString)
                        return try JSONEncoder().encode(csvData) // Convert CSV to JSON format
                    }
                } else if let csvString = String(data: output.data, encoding: .utf8) {
                    if csvString == "{}" {
                        throw APIError.emptyData
                    } 
                }
                
                return output.data
            }
            .map { .success($0) }
            .catch { error in Just(.failure(error as? APIError ?? .unknown)) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func readCSVFromBundle(fileName: String) -> String? {
        if let filePath = Bundle.main.path(forResource: fileName, ofType: "csv") {
            do {
                let content = try String(contentsOfFile: filePath, encoding: .utf8)
                return content
            } catch {
                print("Error reading CSV file: \(error)")
            }
        }
        return nil
    }

    private func parseCSV(_ csvString: String) -> [[String: String]] {
        var result: [[String: String]] = []
        let rows = csvString.components(separatedBy: "\n").filter { !$0.isEmpty }
        guard let headers = rows.first?.components(separatedBy: ",") else { return [] }
        
        for row in rows.dropFirst() {
            let values = row.components(separatedBy: ",")
            var rowDict: [String: String] = [:]
            for (index, header) in headers.enumerated() {
                if index < values.count {
                    rowDict[header] = values[index]
                }
            }
            result.append(rowDict)
        }
        return result
    }
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case noInternet
    case emptyData
    case rateLimitExceeded
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .invalidResponse: return "Invalid response from server"
        case .noInternet: return "No internet connection"
        case .emptyData: return "No data found"
        case .rateLimitExceeded: return "API rate limit exceeded"
        case .unknown: return "An unknown error occurred"
        }
    }
}

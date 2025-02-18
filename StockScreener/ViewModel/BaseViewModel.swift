//
//  BaseViewModel.swift
//  StockScreener
//
//  Created by Najihah on 11/02/2025.
//

import Foundation
import Combine

class BaseViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private var requestTimestamps: [String: [Date]] = [:] // Track API call limits
    private let cache = NSCache<NSString, NSData>() // Basic in-memory cache
    
    let apiKey = "4NJ7XGTM7G4QJ1WB"
    
    // MARK: - Throttling & Caching
    func shouldThrottleRequest(endpoint: String) -> Bool {
        let now = Date()
        let oneMinuteAgo = now.addingTimeInterval(-60)
        requestTimestamps[endpoint] = requestTimestamps[endpoint]?.filter { $0 > oneMinuteAgo } ?? []
        
        if requestTimestamps[endpoint]!.count >= 5 {
            return true
        }
        
        requestTimestamps[endpoint]?.append(now)
        return false
    }
    
    func cacheResponse(_ data: Data, forKey key: String) {
        cache.setObject(data as NSData, forKey: key as NSString)
    }
    
    func getCachedResponse(forKey key: String) -> Data? {
        return cache.object(forKey: key as NSString) as Data?
    }
    
    // MARK: - Generic API Call
    func fetchData<T: Decodable>(from url: String, expectingCSV: Bool = false, fileName: String? = nil) -> AnyPublisher<T, APIError> {
        // Check for cache
        if let cachedData = getCachedResponse(forKey: url),
           let decodedData = try? JSONDecoder().decode(T.self, from: cachedData) {
            return Just(decodedData)
                .setFailureType(to: APIError.self)
                .eraseToAnyPublisher()
        }

        // Check throttling
        if shouldThrottleRequest(endpoint: url) {
            return Fail(error: APIError.rateLimitExceeded).eraseToAnyPublisher()
        }
        
        return APIService.shared.fetchData(from: url, expectingCSV: expectingCSV, fileName: fileName)
            .tryMap { result -> T in
                switch result {
                case .success(let data):
                    do {
                        let decodedData = try JSONDecoder().decode(T.self, from: data)
                        self.cacheResponse(data, forKey: url)
                        return decodedData
                    } catch {
                        print("Decoding error:", error) // Log the exact decoding issue
                            throw APIError.invalidResponse
                    }
                case .failure(let error):
                    throw error
                }
            }
            .mapError { $0 as? APIError ?? .unknown }
            .eraseToAnyPublisher()
    }
}

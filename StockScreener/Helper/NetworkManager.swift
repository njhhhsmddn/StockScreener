//
//  NetworkManager.swift
//  StockScreener
//
//  Created by Najihah on 06/02/2025.
//

import Foundation
import Combine

class NetworkManager {
    static let shared = NetworkManager() // Singleton instance

    private var cache: [String: Data] = [:]  // API Response Cache
    private var lastRequestTime: Date?
    private let rateLimitInterval: TimeInterval = 12  // 60 seconds / 5 requests
    private var requestQueue = DispatchQueue(label: "NetworkManagerQueue")
        
    private var caches = NSCache<NSString, NSData>()
    /// Generic function to fetch data from an API with caching and rate limiting
    func fetch<T: Decodable>(urlString: String, decodingType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        requestQueue.async { [weak self] in
            guard let self = self else { return }

            // Check rate limit
            let now = Date()
            if let lastRequest = self.lastRequestTime, now.timeIntervalSince(lastRequest) < self.rateLimitInterval {
                print("Rate limit reached. Skipping request to \(urlString)")
                return
            }
            self.lastRequestTime = now  // Update last request time

            // Check cache
            if let cachedData = self.cache[urlString] {
                do {
                    let decodedData = try JSONDecoder().decode(T.self, from: cachedData)
                    DispatchQueue.main.async {
                        completion(.success(decodedData))
                    }
                    return
                } catch {
                    print("Cache decoding error: \(error)")
                }
            }

            // Make API request
            guard let url = URL(string: urlString) else {
                completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
                return
            }

            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }

                if let data = data {
                    self.cache[urlString] = data  // Cache response
                    do {
                        let decodedData = try JSONDecoder().decode(T.self, from: data)
                        DispatchQueue.main.async {
                            completion(.success(decodedData))
                        }
                    } catch {
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                    }
                }
            }.resume()
        }
    }
    
    func fetchRawData(urlString: String, completion: @escaping (Result<Data, Error>) -> Void) {
            if let cachedData = caches.object(forKey: urlString as NSString) {
                completion(.success(cachedData as Data))
                return
            }

            guard let url = URL(string: urlString) else {
                completion(.failure(NSError(domain: "Invalid URL", code: 400)))
                return
            }

            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    self.caches.setObject(data as NSData, forKey: urlString as NSString)
                    completion(.success(data))
                } else {
                    completion(.failure(error ?? NSError(domain: "Unknown error", code: 500)))
                }
            }.resume()
        }
}

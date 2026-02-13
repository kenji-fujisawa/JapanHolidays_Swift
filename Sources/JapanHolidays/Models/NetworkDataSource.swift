//
//  NetworkDataSource.swift
//  JapanHolidays
//
//  Created by uhimania on 2026/02/06.
//

import Foundation

protocol NetworkDataSource {
    func getHolidays(_ callback: @escaping @Sendable (Result<Dictionary<String, String>, Error>) -> Void)
}

class DefaultNetworkDataSource: NetworkDataSource {
    enum NetworkError: Error {
        case unknown
    }
    
    func getHolidays(_ callback: @escaping @Sendable (Result<Dictionary<String, String>, Error>) -> Void) {
        guard let url = URL(string: "https://www8.cao.go.jp/chosei/shukujitsu/syukujitsu.csv") else {
            callback(.failure(NetworkError.unknown))
            return
        }
        
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                callback(.failure(error))
                return
            }
            
            if let data = data,
               let text = String(data: data, encoding: .shiftJIS) {
                let holidays = text
                    .components(separatedBy: .newlines)
                    .dropFirst()
                    .filter { $0.contains(",") }
                    .map { $0.components(separatedBy: ",") }
                    .reduce(into: [String: String]()) { result, value in
                        result[value[0]] = value[1]
                    }
                callback(.success(holidays))
                return
            }
            
            callback(.failure(NetworkError.unknown))
        }.resume()
    }
}

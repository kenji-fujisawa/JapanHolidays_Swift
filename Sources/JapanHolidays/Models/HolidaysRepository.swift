//
//  HolidaysRepository.swift
//  JapanHolidays
//
//  Created by uhimania on 2026/02/09.
//

import Foundation

protocol HolidaysRepository {
    func getHolidays(_ callback: @escaping @Sendable (Result<Dictionary<String, String>, Error>) -> Void) throws
}

class DefaultHolidaysRepository: HolidaysRepository, @unchecked Sendable {
    private let localSource: LocalDataSource
    private let networkSource: NetworkDataSource
    
    init(localSource: LocalDataSource, networkSource: NetworkDataSource) {
        self.localSource = localSource
        self.networkSource = networkSource
    }
    
    func getHolidays(_ callback: @escaping @Sendable (Result<Dictionary<String, String>, Error>) -> Void) throws {
        let updated = try localSource.getLastUpdated()
        let day30: TimeInterval = 30 * 24 * 60 * 60
        if Date().timeIntervalSince(updated) < day30 {
            callback(.success(try localSource.getHolidays()))
        } else {
            networkSource.getHolidays { result in
                switch result {
                case .success(let holidays):
                    do {
                        try self.localSource.updateHolidays(holidays)
                        callback(.success(holidays))
                    } catch {
                        callback(.failure(error))
                    }
                case .failure(let error):
                    callback(.failure(error))
                }
            }
        }
    }
}

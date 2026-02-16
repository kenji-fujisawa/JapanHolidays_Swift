//
//  HolidaysRepositoryTests.swift
//  JapanHolidays
//
//  Created by uhimania on 2026/02/12.
//

import Foundation
import Testing

@testable import JapanHolidays

struct HolidaysRepositoryTests {

    @Test func testGetHolidays() async throws {
        let localSource = FakeLocalDataSource()
        let networkSource = FakeNetworkDataSource()
        let repository = DefaultHolidaysRepository(localSource: localSource, networkSource: networkSource)
        
        await withCheckedContinuation { continuation in
            do {
                try repository.getHolidays { result in
                    switch result {
                    case .success(let holidays):
                        #expect(holidays.count == 2)
                        #expect(holidays["2026/1/1"] == "new year's day")
                        #expect(holidays["2026/1/12"] == "coming of age day")
                        continuation.resume()
                    case .failure(let error):
                        Issue.record(error)
                        continuation.resume()
                    }
                }
            } catch {
                Issue.record(error)
                continuation.resume()
            }
        }
        #expect(localSource.updated.count == 0)
        
        localSource.lastUpdated = Date(timeIntervalSinceNow: -29 * 24 * 60 * 60)
        await withCheckedContinuation { continuation in
            do {
                try repository.getHolidays { result in
                    switch result {
                    case .success(let holidays):
                        #expect(holidays.count == 2)
                        #expect(holidays["2026/1/1"] == "new year's day")
                        #expect(holidays["2026/1/12"] == "coming of age day")
                        continuation.resume()
                    case .failure(let error):
                        Issue.record(error)
                        continuation.resume()
                    }
                }
            } catch {
                Issue.record(error)
                continuation.resume()
            }
        }
        #expect(localSource.updated.count == 0)
        
        localSource.lastUpdated = Date(timeIntervalSinceNow: -30 * 24 * 60 * 60)
        await withCheckedContinuation { continuation in
            do {
                try repository.getHolidays { result in
                    switch result {
                    case .success(let holidays):
                        #expect(holidays.count == 3)
                        #expect(holidays["2026/1/1"] == "new year's day")
                        #expect(holidays["2026/1/12"] == "coming of age day")
                        #expect(holidays["2026/2/11"] == "national foundation day")
                        continuation.resume()
                    case .failure(let error):
                        Issue.record(error)
                        continuation.resume()
                    }
                }
            } catch {
                Issue.record(error)
                continuation.resume()
            }
        }
        #expect(localSource.updated.count == 3)
        #expect(localSource.updated["2026/1/1"] == "new year's day")
        #expect(localSource.updated["2026/1/12"] == "coming of age day")
        #expect(localSource.updated["2026/2/11"] == "national foundation day")
    }

    class FakeLocalDataSource: LocalDataSource {
        let holidays = [
            "2026/1/1": "new year's day",
            "2026/1/12": "coming of age day"
        ]
        func getHolidays() throws -> Dictionary<String, String> {
            holidays
        }
        
        var lastUpdated = Date()
        func getLastUpdated() throws -> Date {
            lastUpdated
        }
        
        var updated: Dictionary<String, String> = [:]
        func updateHolidays(_ holidays: Dictionary<String, String>) throws {
            updated = holidays
        }
    }
    
    class FakeNetworkDataSource: NetworkDataSource {
        let holidays = [
            "2026/1/1": "new year's day",
            "2026/1/12": "coming of age day",
            "2026/2/11": "national foundation day"
        ]
        func getHolidays(_ callback: @escaping (Result<Dictionary<String, String>, any Error>) -> Void) {
            callback(.success(holidays))
        }
    }
}

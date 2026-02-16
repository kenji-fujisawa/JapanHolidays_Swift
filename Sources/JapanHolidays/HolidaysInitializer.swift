//
//  HolidaysInitializer.swift
//  JapanHolidays
//
//  Created by uhimania on 2026/02/05.
//

import Foundation

@objcMembers
public class HolidaysInitializer: NSObject {
    private static let group = DispatchGroup()
    
    public static func setup() {
        DispatchQueue.global().async(group: group) {
            do {
                let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let db = documents.appendingPathComponent("JapanHolidays.db")
                let localSource = try DefaultLocalDataSource(url: db)
                let networkSource = DefaultNetworkDataSource()
                let repository = DefaultHolidaysRepository(localSource: localSource, networkSource: networkSource)
                
                let semaphore = DispatchSemaphore(value: 0)
                try repository.getHolidays { result in
                    switch result {
                    case .success(let holidays):
                        HolidaysStore.shared.updateHolidays(holidays)
                    case .failure(let error):
                        print(error)
                    }
                    
                    semaphore.signal()
                }
                
                semaphore.wait()
            } catch {
                print(error)
            }
        }
    }
    
    static func wait() {
        group.wait()
    }
}

class HolidaysStore: @unchecked Sendable {
    private var holidays = JapanHolidays.holidays
    private let lock = NSLock()
    
    static let shared = HolidaysStore()
    
    func getHolidays() -> Dictionary<String, String> {
        lock.withLock {
            return holidays
        }
    }
    
    func updateHolidays(_ holidays: Dictionary<String, String>) {
        lock.withLock {
            self.holidays = holidays
        }
    }
}

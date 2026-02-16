//
//  LocalDataSourceTests.swift
//  JapanHolidays
//
//  Created by uhimania on 2026/02/06.
//

import Foundation
import Testing

@testable import JapanHolidays

struct LocalDataSourceTests {

    @Test func testGetAndUpdate() async throws {
        let url = URL(string: "::memory:")
        let source = try DefaultLocalDataSource(url: url!)
        
        var results = try source.getHolidays()
        #expect(results.count == 0)
        
        var updated = try source.getLastUpdated()
        #expect(updated == .distantPast)
        
        var holidays = [
            "2026/1/1": "new year's day",
            "2026/1/12": "coming of age day"
        ]
        try source.updateHolidays(holidays)
        
        results = try source.getHolidays()
        #expect(results.count == 2)
        holidays.forEach {
            #expect(results[$0.key] == $0.value)
        }
        
        let formatter = Date.FormatStyle.dateTime.year().month().day()
        updated = try source.getLastUpdated()
        #expect(updated.formatted(formatter) == Date().formatted(formatter))
        
        holidays["2026/2/11"] = "national foundation day"
        holidays["2026/2/23"] = "emperor's birthday"
        try source.updateHolidays(holidays)
        
        results = try source.getHolidays()
        #expect(results.count == 4)
        holidays.forEach {
            #expect(results[$0.key] == $0.value)
        }
        
        updated = try source.getLastUpdated()
        #expect(updated.formatted(formatter) == Date().formatted(formatter))
    }

}

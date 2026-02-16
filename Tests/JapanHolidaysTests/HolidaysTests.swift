//
//  HolidaysTests.swift
//  JapanHolidays
//
//  Created by uhimania on 2026/02/12.
//

import Foundation
import Testing

@testable import JapanHolidays

struct HolidaysTests {

    @Test func testIsHoliday() async throws {
        #expect(Holidays.isHoliday(year: 2026, month: 1, day: 12) == true)
        #expect(Holidays.isHoliday(year: 2025, month: 1, day: 12) == false)
        
        #expect(Holidays.isHoliday(Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 12)) ?? Date()) == true)
        #expect(Holidays.isHoliday(Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 12)) ?? Date()) == false)
    }

    @Test func testGetName() async throws {
        #expect(Holidays.getName(year: 2026, month: 1, day: 12) == "成人の日")
        #expect(Holidays.getName(year: 2025, month: 1, day: 12) == nil)
        
        #expect(Holidays.getName(Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 12)) ?? Date()) == "成人の日")
        #expect(Holidays.getName(Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 12)) ?? Date()) == nil)
    }
}

//
//  Holidays.swift
//  JapanHolidays
//
//  Created by uhimania on 2026/02/05.
//

import Foundation

public class Holidays {
    public static func isHoliday(year: Int, month: Int, day: Int) -> Bool {
        let key = "\(year)/\(month)/\(day)"
        return HolidaysStore.shared.getHolidays().keys.contains { $0 == key }
    }
    
    public static func isHoliday(_ date: Date) -> Bool {
        let year = Calendar.current.component(.year, from: date)
        let month = Calendar.current.component(.month, from: date)
        let day = Calendar.current.component(.day, from: date)
        return isHoliday(year: year, month: month, day: day)
    }
    
    public static func getName(year: Int, month: Int, day: Int) -> String? {
        let key = "\(year)/\(month)/\(day)"
        return HolidaysStore.shared.getHolidays()[key]
    }
    
    public static func getName(_ date: Date) -> String? {
        let year = Calendar.current.component(.year, from: date)
        let month = Calendar.current.component(.month, from: date)
        let day = Calendar.current.component(.day, from: date)
        return getName(year: year, month: month, day: day)
    }
    
    public static func joinInit() {
        HolidaysInitializer.wait()
    }
}

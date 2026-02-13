//
//  LocalDataSource.swift
//  JapanHolidays
//
//  Created by uhimania on 2026/02/05.
//

import Foundation
import SQLite3

protocol LocalDataSource {
    func getHolidays() throws -> Dictionary<String, String>
    func getLastUpdated() throws -> Date
    func updateHolidays(_ holidays: Dictionary<String, String>) throws
}

class DefaultLocalDataSource: LocalDataSource {
    struct DatabaseError: Error {
        let message: String
    }
    
    private var db: OpaquePointer?
    
    init(url: URL) throws {
        let flags = SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX
        guard sqlite3_open_v2(url.path, &db, flags, nil) == SQLITE_OK else {
            throw DatabaseError(message: getErrorMessage())
        }
        
        try exec("""
            CREATE TABLE IF NOT EXISTS holidays(
                date TEXT PRIMARY KEY,
                name TEXT
            )
        """)
        try exec("""
            CREATE TABLE IF NOT EXISTS last_updated(
                date REAL PRIMARY KEY
            )
        """)
    }
    
    deinit {
        if sqlite3_close_v2(db) != SQLITE_OK {
            print(getErrorMessage())
        }
    }
    
    func getHolidays() throws -> Dictionary<String, String> {
        var holidays: Dictionary<String, String> = [:]
        
        let values = try select("SELECT date, name FROM holidays")
        for value in values {
            let date = value[0] as! String
            let name = value[1] as! String
            holidays[date] = name
        }
        
        return holidays
    }
    
    func getLastUpdated() throws -> Date {
        var updated = Date.distantPast
        
        let values = try select("SELECT date FROM last_updated")
        if !values.isEmpty {
            updated = Date(timeIntervalSince1970: values[0][0] as! Double)
        }
        
        return updated
    }
    
    func updateHolidays(_ holidays: Dictionary<String, String>) throws {
        try exec("BEGIN TRANSACTION")
        
        do {
            try exec("DELETE FROM holidays")
            try exec("DELETE FROM last_updated")
            
            var values: [[Any]] = holidays.map { [$0, $1] }
            try exec("INSERT INTO holidays VALUES(?, ?)", values)
            
            values = [[Date().timeIntervalSince1970]]
            try exec("INSERT INTO last_updated VALUES(?)", values)
            
            try exec("COMMIT")
        } catch {
            try exec("ROLLBACK")
            throw error
        }
    }
    
    private func exec(_ sql: String) throws {
        if sqlite3_exec(db, sql, nil, nil, nil) != SQLITE_OK {
            throw DatabaseError(message: getErrorMessage())
        }
    }
    
    private func exec(_ sql: String, _ values: [[Any?]]) throws {
        var statement: OpaquePointer? = nil
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            throw DatabaseError(message: getErrorMessage())
        }
        defer { sqlite3_finalize(statement) }
        
        for row in values {
            for index in 0..<row.count {
                var ret = SQLITE_OK
                switch row[index] {
                case is Int:
                    ret = sqlite3_bind_int(statement, Int32(index + 1), Int32(row[index] as! Int))
                case is Double:
                    ret = sqlite3_bind_double(statement, Int32(index + 1), row[index] as! Double)
                case is String:
                    ret = sqlite3_bind_text(statement, Int32(index + 1), (row[index] as! NSString).utf8String, -1, nil)
                case nil:
                    ret = sqlite3_bind_null(statement, Int32(index + 1))
                default: break
                }
                
                guard ret == SQLITE_OK else {
                    throw DatabaseError(message: getErrorMessage())
                }
            }
            
            guard sqlite3_step(statement) == SQLITE_DONE else {
                throw DatabaseError(message: getErrorMessage())
            }
            sqlite3_reset(statement)
        }
    }
    
    private func select(_ sql: String) throws -> [[Any?]] {
        var statement: OpaquePointer? = nil
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            throw DatabaseError(message: getErrorMessage())
        }
        defer { sqlite3_finalize(statement) }
        
        let columns = sqlite3_column_count(statement)
        var result: [[Any?]] = []
        while sqlite3_step(statement) == SQLITE_ROW {
            var row: [Any?] = []
            for index in 0..<columns {
                let type = sqlite3_column_type(statement, index)
                switch type {
                case SQLITE_INTEGER:
                    row.append(Int(sqlite3_column_int(statement, index)))
                case SQLITE_FLOAT:
                    row.append(sqlite3_column_double(statement, index))
                case SQLITE_TEXT:
                    row.append(String(cString: sqlite3_column_text(statement, index)))
                case SQLITE_NULL:
                    row.append(nil)
                default: break
                }
            }
            
            result.append(row)
        }
        
        return result
    }
    
    private func getErrorMessage() -> String {
        if let msg = sqlite3_errmsg(db) {
            return String(cString: msg)
        } else {
            return ""
        }
    }
}

//
//  NetworkDataSourceTests.swift
//  JapanHolidays
//
//  Created by uhimania on 2026/02/06.
//

import OHHTTPStubs
import OHHTTPStubsSwift
import Testing

@testable import JapanHolidays

@Suite(.serialized)
class NetworkDataSourceTests {
    private let responseBody = """
        国民の祝日・休日月日,国民の祝日・休日名称
        1955/1/1,元日
        1955/1/15,成人の日
        1955/3/21,春分の日

        """
    
    deinit {
        HTTPStubs.removeAllStubs()
    }
    
    @Test func testGetHolidays() async throws {
        stub(condition: isHost("www8.cao.go.jp")) { _ in
            return HTTPStubsResponse(data: self.responseBody.data(using: .shiftJIS) ?? Data(), statusCode: 200, headers: nil)
        }
        
        await withCheckedContinuation { continuation in
            let source = DefaultNetworkDataSource()
            source.getHolidays { result in
                switch result {
                case .success(let holidays):
                    #expect(holidays.count == 3)
                    #expect(holidays["1955/1/1"] == "元日")
                    #expect(holidays["1955/1/15"] == "成人の日")
                    #expect(holidays["1955/3/21"] == "春分の日")
                    continuation.resume()
                case .failure(let error):
                    Issue.record(error)
                    continuation.resume()
                }
            }
        }
    }
    
    @Test func testGetHolidays_error() async throws {
        stub(condition: isHost("www8.cao.go.jp")) { _ in
            return HTTPStubsResponse(error: NSError(domain: "test", code: 100))
        }
        
        await withCheckedContinuation { continuation in
            let source = DefaultNetworkDataSource()
            source.getHolidays { result in
                switch result {
                case .success:
                    Issue.record()
                    continuation.resume()
                case .failure(let error):
                    #expect((error as NSError).domain == "test")
                    #expect((error as NSError).code == 100)
                    continuation.resume()
                }
            }
        }
    }
}

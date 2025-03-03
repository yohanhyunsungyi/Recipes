//
//  TestsHelper.swift
//  YohansRecipes
//
//  Created by Yohan Yi on 3/2/25.
//

import Foundation

// MARK: - Mock URLSession

protocol URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

class MockURLSession: URLSessionProtocol {
    var mockData = Data()
    var mockError: Error?
    
    func data(from url: URL) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }
        
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        
        return (mockData, response)
    }
}

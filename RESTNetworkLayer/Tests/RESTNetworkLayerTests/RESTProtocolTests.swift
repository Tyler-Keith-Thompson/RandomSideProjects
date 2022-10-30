//
//  File.swift
//  
//
//  Created by Tyler Thompson on 10/29/22.
//

import Foundation
import Combine
import XCTest

import OHHTTPStubs
import OHHTTPStubsSwift

import RESTNetworkLayer

final class RESTProtocolTests: XCTestCase {
    struct JSONPlaceholder: RESTAPIProtocol {
        var baseURL: String = "https://jsonplaceholder.typicode.com"
    }

    override func setUpWithError() throws {
        HTTPStubs.removeAllStubs()

        stub { _ in true } response: { req in
            XCTFail("Unexpected request made: \(req)")
            return HTTPStubsResponse(error: URLError.init(.badURL))
        }
    }

    func testAPIMakesAGETRequest() async throws {
        let responseData = try XCTUnwrap(UUID().uuidString.data(using: .utf8))

        StubResponse(on: isAbsoluteURLString("https://jsonplaceholder.typicode.com/posts") && isMethodGET()) { _ in
            HTTPStubsResponse(data: responseData, statusCode: 200, headers: nil)
        }

        let api = JSONPlaceholder()

        let value = try await api.get(endpoint: "posts").firstValue().get()

        XCTAssertEqual(value.response.statusCode, 200)
        XCTAssertEqual(String(data: value.data, encoding: .utf8), String(data: responseData, encoding: .utf8))
    }

    func testAPIRecalculatesRequestOnRetry() async throws {
        let responseData = try XCTUnwrap(UUID().uuidString.data(using: .utf8))
        let headerField = "Custom-Header-Field"
        let firstHeaderVal = UUID().uuidString
        let secondHeaderVal = UUID().uuidString
        StubResponse(on: isAbsoluteURLString("https://jsonplaceholder.typicode.com/posts") && isMethodGET()) { request in
            // first call
            XCTAssertEqual(request.value(forHTTPHeaderField: headerField), firstHeaderVal)
            return HTTPStubsResponse(error: URLError(.badServerResponse))
        }.thenRespond(on: isAbsoluteURLString("https://jsonplaceholder.typicode.com/posts") && isMethodGET()) { request in
            XCTAssertEqual(request.value(forHTTPHeaderField: headerField), secondHeaderVal)
            return HTTPStubsResponse(data: responseData, statusCode: 200, headers: nil)
        }
        let api = JSONPlaceholder()

        var headerVal = firstHeaderVal
        let value = try await api
            .get(endpoint: "posts") {
                $0.addingValue(headerVal, forHTTPHeaderField: headerField)
            }
            .tryCatch { err -> AnyPublisher<RESTAPIProtocol.Output, RESTAPIProtocol.Failure> in
                headerVal = secondHeaderVal
                throw err
            }
            .retry(1)
            .firstValue().get()

        XCTAssertEqual(value.response.statusCode, 200)
        XCTAssertEqual(String(data: value.data, encoding: .utf8), String(data: responseData, encoding: .utf8))
    }

    func testAPIThrowsErrorWhenGETtingWithInvalidURL() async {
        var api = JSONPlaceholder()
        api.baseURL = "FA KE"

        let result = await api.get(endpoint: "posts").firstValue()

        XCTAssertThrowsError(try result.get()) {
            XCTAssertEqual(($0 as? URLError), URLError(.badURL))
        }
    }

    func testAPIMakesAPOSTRequest() async throws {
        let responseData = try XCTUnwrap(UUID().uuidString.data(using: .utf8))
        let sentBody = try? JSONSerialization.data(withJSONObject: ["": ""], options: [])
        StubResponse(on: isAbsoluteURLString("https://jsonplaceholder.typicode.com/posts") && isMethodPOST()) { req in
            XCTAssertEqual(req.bodySteamAsData(), sentBody)
            return HTTPStubsResponse(data: responseData, statusCode: 201, headers: nil)
        }

        let api = JSONPlaceholder()

        let value = try await api.post(endpoint: "posts", body: sentBody).firstValue().get()

        XCTAssertEqual(value.response.statusCode, 201)
        XCTAssertEqual(String(data: value.data, encoding: .utf8), String(data: responseData, encoding: .utf8))
    }

    func testAPIThrowsErrorWhenPOSTtingWithInvalidURL() async {
        var api = JSONPlaceholder()
        api.baseURL = "FA KE"

        let result = await api.post(endpoint: "notreal", body: nil).firstValue()

        XCTAssertThrowsError(try result.get()) {
            XCTAssertEqual(($0 as? URLError), URLError(.badURL))
        }
    }

    func testAPIMakesAPUTRequest() async throws {
        let responseData = try XCTUnwrap(UUID().uuidString.data(using: .utf8))
        let sentBody = try? JSONSerialization.data(withJSONObject: ["": ""], options: [])
        StubResponse(on: isAbsoluteURLString("https://jsonplaceholder.typicode.com/posts/1") && isMethodPUT()) { req in
            XCTAssertEqual(req.bodySteamAsData(), sentBody)
            return HTTPStubsResponse(data: responseData, statusCode: 200, headers: nil)
        }

        let api = JSONPlaceholder()

        let value = try await api.put(endpoint: "posts/1", body: sentBody).firstValue().get()

        XCTAssertEqual(value.response.statusCode, 200)
        XCTAssertEqual(String(data: value.data, encoding: .utf8), String(data: responseData, encoding: .utf8))
    }

    func testAPIThrowsErrorWhenPUTtingWithInvalidURL() async {
        var api = JSONPlaceholder()
        api.baseURL = "FA KE"

        let result = await api.put(endpoint: "notreal", body: nil).firstValue()

        XCTAssertThrowsError(try result.get()) {
            XCTAssertEqual(($0 as? URLError), URLError(.badURL))
        }
    }

    func testAPIMakesAPATCHRequest() async throws {
        let responseData = try XCTUnwrap(UUID().uuidString.data(using: .utf8))
        let sentBody = try? JSONSerialization.data(withJSONObject: ["": ""], options: [])
        StubResponse(on: isAbsoluteURLString("https://jsonplaceholder.typicode.com/posts/1") && isMethodPATCH()) { req in
            XCTAssertEqual(req.bodySteamAsData(), sentBody)
            return HTTPStubsResponse(data: responseData, statusCode: 200, headers: nil)
        }

        let api = JSONPlaceholder()

        let value = try await api.patch(endpoint: "posts/1", body: sentBody).firstValue().get()

        XCTAssertEqual(value.response.statusCode, 200)
        XCTAssertEqual(String(data: value.data, encoding: .utf8), String(data: responseData, encoding: .utf8))
    }

    func testAPIThrowsErrorWhenPATCHingWithInvalidURL() async {
        var api = JSONPlaceholder()
        api.baseURL = "FA KE"

        let result = await api.patch(endpoint: "notreal", body: nil).firstValue()

        XCTAssertThrowsError(try result.get()) {
            XCTAssertEqual(($0 as? URLError), URLError(.badURL))
        }
    }

    func testAPIMakesADELETERequest() async throws {
        let responseData = try XCTUnwrap(UUID().uuidString.data(using: .utf8))
        StubResponse(on: isAbsoluteURLString("https://jsonplaceholder.typicode.com/posts/1") && isMethodDELETE()) { _ in
            HTTPStubsResponse(data: responseData, statusCode: 200, headers: nil)
        }

        let api = JSONPlaceholder()

        let value = try await api.delete(endpoint: "posts/1").firstValue().get()

        XCTAssertEqual(value.response.statusCode, 200)
        XCTAssertEqual(String(data: value.data, encoding: .utf8), String(data: responseData, encoding: .utf8))
    }

    func testAPIThrowsErrorWhenDELETEingWithInvalidURL() async {
        var api = JSONPlaceholder()
        api.baseURL = "FA KE"

        let result = await api.delete(endpoint: "notreal").firstValue()

        XCTAssertThrowsError(try result.get()) {
            XCTAssertEqual(($0 as? URLError), URLError(.badURL))
        }
    }
}

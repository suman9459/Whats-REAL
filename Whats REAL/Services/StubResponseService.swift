//
//  StubResponseService.swift
//  Whats REAL
//
//  Created by Sai Suman Pothedar on 4/5/26.
//

import Foundation
import Combine

/// Stub implementation of ResponseServiceProtocol for development/testing
final class StubResponseService: ResponseServiceProtocol {
    func addResponse(questionId: String, response: WRResponse) async throws {
        print("StubResponseService: Would add response to question \(questionId)")
    }

    func fetchResponses(questionId: String) async throws -> [WRResponse] {
        return []
    }

    func observeResponses(questionId: String) -> AnyPublisher<[WRResponse], Error> {
        Just([WRResponse]())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

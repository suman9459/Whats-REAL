//
//  ResponseServiceProtocol.swift
//  Whats REAL
//
//  Created by Sai Suman Pothedar on 4/5/26.
//

import Foundation
import Combine

/// Service for managing responses to questions
protocol ResponseServiceProtocol {
    /// Add a text response to a question
    /// - Parameters:
    ///   - questionId: Question ID
    ///   - response: Response data
    func addResponse(questionId: String, response: WRResponse) async throws

    /// Fetch responses for a question
    /// - Parameter questionId: Question ID
    /// - Returns: Array of responses
    func fetchResponses(questionId: String) async throws -> [WRResponse]

    /// Listen to responses in real-time
    /// - Parameter questionId: Question ID
    /// - Returns: Publisher emitting response updates
    func observeResponses(questionId: String) -> AnyPublisher<[WRResponse], Error>
}

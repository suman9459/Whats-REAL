//
//  StubQuestionService.swift
//  Whats REAL
//
//  Created by Sai Suman Pothedar on 4/5/26.
//

import Foundation
import Combine

/// Stub implementation of QuestionServiceProtocol for development/testing
final class StubQuestionService: QuestionServiceProtocol {
    func createQuestion(_ question: WRQuestion) async throws -> String {
        print("StubQuestionService: Would create question")
        return UUID().uuidString
    }

    func fetchRecentQuestions(limit: Int) async throws -> [WRQuestion] {
        // Return empty for now
        return []
    }

    func observeQuestions(limit: Int) -> AnyPublisher<[WRQuestion], Error> {
        // Return empty publisher
        Just([WRQuestion]())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func fetchQuestion(id: String) async throws -> WRQuestion? {
        return nil
    }

    func observeNearbyQuestions(geohashPrefix: String, limit: Int) -> AnyPublisher<[WRQuestion], Error> {
        Just([WRQuestion]())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

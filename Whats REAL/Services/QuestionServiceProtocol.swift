//
//  QuestionServiceProtocol.swift
//  Whats REAL
//
//  Created by Sai Suman Pothedar on 4/5/26.
//

import Foundation
import Combine

/// Service for managing questions in Firestore
protocol QuestionServiceProtocol {
    /// Create a new question
    /// - Parameter question: Question data
    /// - Returns: Created question ID
    func createQuestion(_ question: WRQuestion) async throws -> String

    /// Fetch recent questions
    /// - Parameter limit: Maximum number of questions
    /// - Returns: Array of questions
    func fetchRecentQuestions(limit: Int) async throws -> [WRQuestion]

    /// Listen to questions in real-time
    /// - Parameter limit: Maximum number of questions
    /// - Returns: Publisher emitting question updates
    func observeQuestions(limit: Int) -> AnyPublisher<[WRQuestion], Error>

    /// Fetch question by ID
    func fetchQuestion(id: String) async throws -> WRQuestion?

    /// Listen to questions near a geohash prefix in real-time.
    /// Uses Firestore range query on the geohash field, then caller filters by exact distance.
    /// - Parameters:
    ///   - geohashPrefix: The leading chars of the geohash cell to search (e.g. 4 chars ≈ 40km cell)
    ///   - limit: Maximum documents to return from Firestore before in-memory filter
    func observeNearbyQuestions(geohashPrefix: String, limit: Int) -> AnyPublisher<[WRQuestion], Error>
}

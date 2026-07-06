//
//  VoteServiceProtocol.swift
//  Whats REAL
//
//  Created by Sai Suman Pothedar on 4/6/26.
//

import Foundation
import Combine

/// Protocol for managing votes on responses
@MainActor
protocol VoteServiceProtocol {
    /// Cast a vote on a response
    func castVote(userId: String, responseId: String, voteType: WRVote.VoteType) async throws
    
    /// Remove a vote
    func removeVote(userId: String, responseId: String) async throws
    
    /// Get user's vote on a response (if any)
    func getUserVote(userId: String, responseId: String) async throws -> WRVote?
    
    /// Get vote counts for a response
    func getVoteCounts(responseId: String) async throws -> VoteCounts
    
    /// Observe vote changes for a response in real-time
    func observeVotes(responseId: String) -> AnyPublisher<VoteCounts, Error>
}

/// Vote counts for a response
struct VoteCounts: Codable, Equatable {
    var upvotes: Int
    var downvotes: Int
    
    var total: Int {
        upvotes - downvotes
    }
}

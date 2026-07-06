//
//  WRVote.swift
//  Whats REAL
//

import Foundation

struct WRVote: Codable, Identifiable, Equatable {
    let id: String
    let userId: String
    let responseId: String
    let voteType: VoteType
    let createdAt: Date

    enum VoteType: String, Codable {
        case upvote = "upvote"
        case downvote = "downvote"
    }
}

/// Trust scoring data — populated as users earn reputation
struct WRTrustScore: Codable {
    var totalPoints: Int
    var level: TrustLevel
    var badges: [String]
    var responsesGiven: Int
    var upvotesReceived: Int
    var downvotesReceived: Int
    var questionsAsked: Int
}

enum TrustLevel: String, Codable, CaseIterable {
    case newbie       = "Newbie"
    case contributor  = "Contributor"
    case trustedLocal = "Trusted Local"
    case expert       = "Expert"
    case legend       = "Legend"
}

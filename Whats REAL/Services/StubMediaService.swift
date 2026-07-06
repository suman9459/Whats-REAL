//
//  StubMediaService.swift
//  Whats REAL
//
//  Created by Sai Suman Pothedar on 4/5/26.
//

import Foundation

/// Stub implementation of MediaServiceProtocol for development/testing
final class StubMediaService: MediaServiceProtocol {
    func uploadVideo(from videoURL: URL, to path: String) async throws -> String {
        print("StubMediaService: Would upload video from \(videoURL) to \(path)")
        return "https://example.com/mock-video.mp4"
    }

    func deleteVideo(at path: String) async throws {
        print("StubMediaService: Would delete video at \(path)")
    }
}

//
//  MediaServiceProtocol.swift
//  Whats REAL
//
//  Created by Sai Suman Pothedar on 4/5/26.
//

import Foundation

/// Service for uploading and managing media files (videos, images)
protocol MediaServiceProtocol {
    /// Upload video to Firebase Storage
    /// - Parameters:
    ///   - videoURL: Local video file URL
    ///   - path: Storage path (e.g., "questions/qId/video.mp4")
    /// - Returns: Download URL string
    func uploadVideo(from videoURL: URL, to path: String) async throws -> String

    /// Delete video from Firebase Storage
    /// - Parameter path: Storage path
    func deleteVideo(at path: String) async throws
}

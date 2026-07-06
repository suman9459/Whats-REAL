//
//  FirebaseStorageService.swift
//  Whats REAL
//

import Foundation
import FirebaseStorage

@MainActor
final class FirebaseStorageService: MediaServiceProtocol {
    private lazy var storage = Storage.storage()

    func uploadVideo(from videoURL: URL, to path: String) async throws -> String {
        let storageRef = storage.reference().child(path)
        let metadata = StorageMetadata()
        metadata.contentType = "video/mp4"

        let _ = try await storageRef.putFileAsync(from: videoURL, metadata: metadata)
        let downloadURL = try await storageRef.downloadURL()
        return downloadURL.absoluteString
    }

    func deleteVideo(at path: String) async throws {
        let storageRef = storage.reference().child(path)
        try await storageRef.delete()
    }
}

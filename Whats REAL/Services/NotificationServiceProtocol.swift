//
//  NotificationServiceProtocol.swift
//  Whats REAL
//
//  Created by Sai Suman Pothedar on 4/5/26.
//

import Foundation
import UserNotifications

/// Service for managing notifications (local and push)
@MainActor
protocol NotificationServiceProtocol {
    /// Request notification permission
    /// - Returns: True if granted
    func requestPermission() async -> Bool

    /// Send local notification
    /// - Parameters:
    ///   - title: Notification title
    ///   - body: Notification body
    func sendLocalNotification(title: String, body: String) async throws

    /// Register FCM token (for future push notifications)
    /// - Parameter token: FCM device token
    func registerFCMToken(_ token: String) async throws
}

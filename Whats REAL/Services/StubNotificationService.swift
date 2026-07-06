//
//  StubNotificationService.swift
//  Whats REAL
//
//  Created by Sai Suman Pothedar on 4/5/26.
//

import Foundation
import UserNotifications

/// Stub implementation of NotificationServiceProtocol for development/testing
@MainActor
final class StubNotificationService: NotificationServiceProtocol {
    func requestPermission() async -> Bool {
        print("StubNotificationService: Would request permission")
        return true
    }

    func sendLocalNotification(title: String, body: String) async throws {
        print("StubNotificationService: Would send notification - \(title): \(body)")
    }

    func registerFCMToken(_ token: String) async throws {
        print("StubNotificationService: Would register FCM token \(token)")
    }
}

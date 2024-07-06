//
//  Whats_REALApp.swift
//  Whats REAL
//
//  Created by Sai Suman Pothedar on 7/3/24.
//

import SwiftUI
import Firebase
import FirebaseCore

@main
struct Whats_REALApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

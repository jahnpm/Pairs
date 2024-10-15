//
//  PairsApp.swift
//  Pairs
//
//  Created by Jahn Michel on 17.09.24.
//

import SwiftUI
import SwiftData

@main
struct PairsApp: App {
    var body: some Scene {
        WindowGroup {
            StartView()
        }
        .modelContainer(for: PairSet.self)
    }
}

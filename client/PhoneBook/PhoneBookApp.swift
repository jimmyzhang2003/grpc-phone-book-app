//
//  PhoneBookApp.swift
//  PhoneBook
//
//  Created by Jimmy Zhang on 6/26/23.
//

import SwiftUI

@main
struct PhoneBookApp: App {
    @StateObject private var grpcManager = GRPCManager()

    var body: some Scene {
        WindowGroup {
            ContactListView()
                .environmentObject(grpcManager)
        }
    }
}

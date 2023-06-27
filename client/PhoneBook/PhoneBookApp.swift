//
//  PhoneBookApp.swift
//  PhoneBook
//
//  Created by Jimmy Zhang on 6/26/23.
//

import SwiftUI

@main
struct PhoneBookApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

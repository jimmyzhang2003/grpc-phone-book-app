//
//  ContactListViewModel.swift
//  PhoneBook
//
//  Created by Jimmy Zhang on 6/27/23.
//

import Foundation

extension ContactListView {
    @MainActor class ContactListViewModel: ObservableObject {
        @Published var contactsList: [Contact] = []
        @Published var showConfirmationDialog: Bool = false
        
        func updateContactsList(_ newContactsList: [Contact]) {
            self.contactsList = newContactsList
            self.contactsList.sort { $0.firstName < $1.firstName }
        }
        
        func clearContactsList() {
            self.contactsList.removeAll()
        }
    }
}

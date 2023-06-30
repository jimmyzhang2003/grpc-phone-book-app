//
//  Contact.swift
//  PhoneBook
//
//  Created by Jimmy Zhang on 6/27/23.
//

import Foundation

public class Contact: Identifiable, Equatable, ObservableObject {
    public let id: String
    public let firstName: String
    public let lastName: String
    public let phoneNumber: String
    public let email: String
    
    @Published var groceryList: [GroceryItem]
    
    public init(id: String, firstName: String, lastName: String, phoneNumber: String, email: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.email = email
        self.groceryList = []
    }
    
    public static func == (lhs: Contact, rhs: Contact) -> Bool {
        return lhs.id == rhs.id
    }
}

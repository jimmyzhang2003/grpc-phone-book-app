//
//  Contact.swift
//  PhoneBook
//
//  Created by Jimmy Zhang on 6/27/23.
//

import Foundation

public class Contact: Identifiable, Equatable {
    public let id: String
    public let firstName: String
    public let lastName: String
    public let phoneNumber: String
    public let email: String
    
    public init(id: String, firstName: String, lastName: String, phoneNumber: String, email: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.email = email
    }
    
    public static func == (lhs: Contact, rhs: Contact) -> Bool {
        return lhs.id == rhs.id && lhs.firstName == rhs.firstName && lhs.phoneNumber == rhs.phoneNumber && lhs.email == rhs.email
    }
}

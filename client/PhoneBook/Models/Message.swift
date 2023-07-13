//
//  Message.swift
//  PhoneBook
//
//  Created by Jimmy Zhang on 7/12/23.
//

import Foundation

public struct Message: Identifiable, Equatable, Hashable {
    public let id: String = UUID().uuidString
    public let content: String
    public let fromServer: Bool
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}

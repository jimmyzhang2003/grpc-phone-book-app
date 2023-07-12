//
//  Message.swift
//  PhoneBook
//
//  Created by Jimmy Zhang on 7/12/23.
//

import Foundation

public struct Message: Identifiable {
    public let id: String = UUID().uuidString
    public let content: String
    public let fromServer: Bool
}

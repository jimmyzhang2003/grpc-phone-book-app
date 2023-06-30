//
//  GroceryItem.swift
//  PhoneBook
//
//  Created by Jimmy Zhang on 6/29/23.
//

import Foundation

public struct GroceryItem: Identifiable {
    public let id: String = UUID().uuidString
    public let name: String
    public let amount: Int32
}

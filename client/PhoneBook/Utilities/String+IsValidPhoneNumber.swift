//
//  String+IsValidPhoneNumber.swift
//  PhoneBook
//
//  Created by Jimmy Zhang on 6/28/23.
//

import Foundation

// validation function taken from Rajesh Loganathan's answer: https://stackoverflow.com/questions/27998409/email-phone-validation-in-swift
public extension String {
    var isValidPhoneNumber: Bool {
        let phoneRegex = "^[0-9+]{0,1}+[0-9]{5,16}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: self)
    }
}

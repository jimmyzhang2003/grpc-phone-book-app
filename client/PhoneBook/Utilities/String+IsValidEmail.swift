//
//  String+IsValidEmail.swift
//  PhoneBook
//
//  Created by Jimmy Zhang on 6/28/23.
//

import Foundation

// validation function taken from Rajesh Loganathan's answer: https://stackoverflow.com/questions/27998409/email-phone-validation-in-swift
public extension String {
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
}

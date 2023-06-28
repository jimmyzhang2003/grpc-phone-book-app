//
//  EditContactView.swift
//  PhoneBook
//
//  Created by Jimmy Zhang on 6/26/23.
//

import SwiftUI

struct EditContactView: View {
    var contact: Contact
    
    var body: some View {
        VStack {
            Text(contact.id)
            Text(contact.firstName)
            Text(contact.lastName)
            Text(contact.phoneNumber)
            Text(contact.email)
        }
    }
}

struct EditContactView_Previews: PreviewProvider {
    static var previews: some View {
        let exampleContact: Contact = Contact(id: "123", firstName: "ABC", lastName: "DEF", phoneNumber: "888-888-8888", email: "123@abc.com")
        
        EditContactView(contact: exampleContact)
    }
}

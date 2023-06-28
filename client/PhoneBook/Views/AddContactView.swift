//
//  AddContactView.swift
//  PhoneBook
//
//  Created by Jimmy Zhang on 6/26/23.
//

import SwiftUI

struct AddContactView: View {
    @State private var id: String = ""
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var phoneNumber: String = ""
    @State private var email: String = ""
    
    @EnvironmentObject var grpcManager: GRPCManager
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack {
            TextField("First name (e.g., Jimmy)", text: self.$firstName)
                .border(self.firstName == "" ? .red : .green)
            TextField("Last name (e.g., Zhang)", text: self.$lastName)
                .border(self.lastName == "" ? .red : .green)
            TextField("Phone number (e.g., 8888888888)", text: self.$phoneNumber)
                .border(!self.phoneNumber.isValidPhoneNumber ? .red : .green)
            TextField("Email (e.g., jimmy.zhang@nuance.com)", text: self.$email)
                .border(!self.email.isValidEmail ? .red : .green)
            
            Button(action: {
                let newContact = Contact(
                    id: self.id,
                    firstName: self.firstName,
                    lastName: self.lastName,
                    phoneNumber: self.phoneNumber,
                    email: self.email
                )
                
                _ = grpcManager.addContact(newContact)
                
                print("New contact created")
                
                self.presentationMode.wrappedValue.dismiss()
            }, label: {
                ZStack {
                    Capsule()
                        .fill(.blue)
                    Text("Create New Contact")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                .frame(height: 50)
                .padding(.top)
            })
            .disabled(firstName == "" || lastName == "" || !self.phoneNumber.isValidPhoneNumber || !self.email.isValidEmail)
            .opacity(firstName == "" || lastName == "" || !self.phoneNumber.isValidPhoneNumber || !self.email.isValidEmail ? 0.5 : 1.0)
        }
        .padding(.horizontal)
        .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}

struct AddContactView_Previews: PreviewProvider {
    static var previews: some View {
        AddContactView()
            .environmentObject(GRPCManager())
    }
}

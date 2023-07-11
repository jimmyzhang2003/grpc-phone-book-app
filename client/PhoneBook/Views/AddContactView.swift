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
        Form {
            Section(header: Text("First Name")) {
                TextField("First name (e.g., Jimmy)", text: self.$firstName)
                    .border(self.firstName.isEmpty ? .red : .green)
            }
            
            Section(header: Text("Last Name")) {
                TextField("Last name (e.g., Zhang)", text: self.$lastName)
                    .border(self.lastName.isEmpty ? .red : .green)
            }
            
            Section(header: Text("Phone Number")) {
                TextField("Phone number (e.g., 8888888888)", text: self.$phoneNumber)
                    .border(!self.phoneNumber.isValidPhoneNumber ? .red : .green)
            }
            
            Section(header: Text("Email")) {
                TextField("Email (e.g., jimmy.zhang@nuance.com)", text: self.$email)
                    .border(!self.email.isValidEmail ? .red : .green)
            }
            
            Section(footer: buildSaveButton()) {}
        }
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .autocorrectionDisabled()
        .navigationTitle("Create New Contact")
    }
    
    @ViewBuilder private func buildSaveButton() -> some View {
        Button(action: {
            let newContact = Contact(
                id: self.id,
                firstName: self.firstName,
                lastName: self.lastName,
                phoneNumber: self.phoneNumber,
                email: self.email
            )
            
            _ = grpcManager.addContact(newContact)
            
            self.presentationMode.wrappedValue.dismiss()
        }, label: {
            ZStack {
                Capsule()
                    .fill(.blue)
                Text("Save")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            .frame(height: 50)
        })
        .disabled(firstName.isEmpty || lastName.isEmpty || !self.phoneNumber.isValidPhoneNumber || !self.email.isValidEmail)
        .opacity(firstName.isEmpty || lastName.isEmpty || !self.phoneNumber.isValidPhoneNumber || !self.email.isValidEmail ? 0.5 : 1.0)
    }
    
}

struct AddContactView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddContactView()
                .environmentObject(GRPCManager.shared)
        }
    }
}

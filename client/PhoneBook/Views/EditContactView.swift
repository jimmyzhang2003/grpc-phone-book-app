//
//  EditContactView.swift
//  PhoneBook
//
//  Created by Jimmy Zhang on 6/26/23.
//

import SwiftUI

enum ContactField {
    case firstName
    case lastName
    case phoneNumber
    case email
}

struct EditContactView: View {
    @State var id: String
    @State var firstName: String
    @State var lastName: String
    @State var phoneNumber: String
    @State var email: String
    
    @State private var isEditing = false
    
    @EnvironmentObject var grpcManager: GRPCManager
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    buildContactInfoRow(title: "First Name:", field: .firstName, detail: self.$firstName)
                    buildContactInfoRow(title: "Last Name:", field: .lastName, detail: self.$lastName)
                    buildContactInfoRow(title: "Phone:", field: .phoneNumber, detail: self.$phoneNumber)
                    buildContactInfoRow(title: "Email:", field: .email, detail: self.$email)
                }
                
                Button(
                    action: {
                        isEditing = !isEditing
                    }, label: {
                        ZStack {
                            Circle()
                                .frame(width: 40)
                                .foregroundColor(isEditing ? .pink : .gray)
                            
                            Image(systemName: "pencil")
                        }
                    }
                )
            }
            .padding()
            .border(.cyan)
            
            HStack(spacing: 50) {
                Button(
                    action : {
                        self.presentationMode.wrappedValue.dismiss()
                    }, label: {
                        ZStack {
                            Capsule()
                                .fill(.red)
                            Text("Cancel")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        .frame(height: 50)
                    }
                )
                
                Button(
                    action : {
                        grpcManager.updateContact(
                            Contact(
                                id: id,
                                firstName: firstName,
                                lastName: lastName,
                                phoneNumber: phoneNumber,
                                email: email
                            )
                        )
                        
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
                    }
                )
                .disabled(firstName.isEmpty || lastName.isEmpty || !self.phoneNumber.isValidPhoneNumber || !self.email.isValidEmail)
                .opacity(firstName.isEmpty || lastName.isEmpty || !self.phoneNumber.isValidPhoneNumber || !self.email.isValidEmail ? 0.5 : 1.0)
            }
            .padding()
        }
        .navigationTitle("Contact Info")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    GroceryListView(id: id, firstName: firstName)
                } label: {
                    ZStack {
                        Circle()
                            .fill(.green)
                        Image(systemName: "phone")
                            .foregroundColor(.black)
                    }
                    .frame(width: 50)
                }
            }
        }
    }
    
    @ViewBuilder private func buildContactInfoRow(title: String, field: ContactField, detail: Binding<String>) -> some View {
        HStack {
            Text(title)
                .fontWeight(.bold)
            TextField(detail.wrappedValue, text: detail)
                .disabled(!isEditing)
                .autocorrectionDisabled()
                .border(isEditing ? getBorderColor(field, content: detail.wrappedValue) : .clear)
                .animation(.default, value: isEditing)
        }
        .padding(5)
    }
    
    private func getBorderColor(_ field: ContactField, content: String) -> Color {
        switch field {
        case .phoneNumber:
            return content.isValidPhoneNumber ? .green : .red
        case .email:
            return content.isValidEmail ? .green : .red
        default:
            return content != "" ? .green : .red
        }
    }
}

struct EditContactView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditContactView(id: "123", firstName: "ABC", lastName: "DEF", phoneNumber: "8888888888", email: "123@abc.com")
                .environmentObject(GRPCManager.shared)
        }
    }
}

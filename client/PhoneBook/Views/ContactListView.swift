//
//  ContactListView.swift
//  PhoneBook
//
//  Created by Jimmy Zhang on 6/26/23.
//

import SwiftUI

struct ContactListView: View {
    @StateObject private var viewModel: ContactListViewModel = ContactListViewModel()
    @EnvironmentObject var grpcManager: GRPCManager
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.contactsList) { contact in
                    NavigationLink {
                        EditContactView(contact: Contact(
                            id: contact.id,
                            firstName: contact.firstName,
                            lastName: contact.lastName,
                            phoneNumber: contact.phoneNumber,
                            email: contact.email)
                        )
                    } label: {
                        Text("\(contact.firstName) \(contact.lastName)")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    .swipeActions {
                        Button(
                            role: .destructive,
                            action: {
                                grpcManager.deleteContact(with: contact.id)
                            },
                            label: {
                                Image(systemName: "trash")
                            }
                        )
                    }
                }
            }
            .animation(.default, value: viewModel.contactsList)
            .navigationTitle("My Contacts")
            .navigationBarTitleDisplayMode(.automatic)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(
                        action: {
                            grpcManager.clearContacts()
                            grpcManager.getContactsList { contacts in
                                DispatchQueue.main.async {
                                    viewModel.updateContactsList(contacts)
                                }
                            }
                        }, label: {
                            Text("Clear Contacts")
                        }
                    )
                    .disabled(viewModel.contactsList.isEmpty)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(
                        action: {},
                        label: {
                            NavigationLink(destination: AddContactView()) {
                                Image(systemName: "plus")
                            }
                        }
                    )
                }
            }
            .onAppear {
                grpcManager.getContactsList { contacts in
                    DispatchQueue.main.async {
                        viewModel.updateContactsList(contacts)
                    }
                }
            }
        }
    }
}

struct ContactListView_Previews: PreviewProvider {
    static var previews: some View {
        ContactListView()
            .environmentObject(GRPCManager())
    }
}

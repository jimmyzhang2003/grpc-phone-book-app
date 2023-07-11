//
//  GroceryListView.swift
//  PhoneBook
//
//  Created by Jimmy Zhang on 6/29/23.
//

import SwiftUI

struct GroceryListView: View {
    @ObservedObject var contact: Contact
    @EnvironmentObject var grpcManager: GRPCManager
    
    var body: some View {
        List {
            ForEach(contact.groceryList, id: \.id) { item in
                VStack(alignment: .leading) {
                    Text(item.name)
                        .fontWeight(.bold)
                    Text("Amount: \(item.amount)")
                }
            }
        }
        .navigationTitle("\(contact.firstName)'s Grocery List")
        .onAppear {
            grpcManager.getGroceryListForContact(with: contact.id) { item in
                // TODO: is this the right way to make UI updates publish on the main thread???
                // TODO: stop execution once we leave the view
                DispatchQueue.main.async {
                    contact.groceryList.append(item)
                }
            }
        }
        .onDisappear {
            contact.groceryList.removeAll()
        }
    }
}

struct GroceryListView_Previews: PreviewProvider {
    static var previews: some View {
        let contact: Contact = Contact(id: "123", firstName: "ABC", lastName: "DEF", phoneNumber: "8888888888", email: "123@abc.com")
        
        NavigationView {
            GroceryListView(contact: contact)
                .environmentObject(GRPCManager.shared)
        }
    }
}

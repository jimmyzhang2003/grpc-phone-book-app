//
//  GroceryListView.swift
//  PhoneBook
//
//  Created by Jimmy Zhang on 6/29/23.
//

import SwiftUI

struct GroceryListView: View {
    @State var id: String
    @State var firstName: String
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .navigationTitle("\(firstName)'s Grocery List")
    }
}

struct GroceryListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GroceryListView(id: "123", firstName: "Jimmy")
        }
    }
}

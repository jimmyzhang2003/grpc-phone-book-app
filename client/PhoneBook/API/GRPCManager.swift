//
//  GRPCManager.swift
//  PhoneBook
//
//  Created by Jimmy Zhang on 6/27/23.
//

import Foundation
import GRPC
import SwiftProtobuf
import NIO
import NIOSSL

class GRPCManager: ObservableObject {
    var connection: ClientConnection?
    private var client: Com_Example_Grpc_ContactServiceAsyncClient?
    static let shared: GRPCManager = GRPCManager() // singleton
    
    private init() {
        let conf = ClientConnection.Configuration.default(
            target: .hostAndPort("localhost", 50051),
            eventLoopGroup: MultiThreadedEventLoopGroup(numberOfThreads: 1)
        )
        
        self.connection = ClientConnection.init(configuration: conf)
        
        guard let connection = connection else {
            self.client = nil
            return
        }
        
        self.client = Com_Example_Grpc_ContactServiceAsyncClient(channel: connection)
    }
    
    deinit {
        guard let connection = connection else { return }
        
        do {
            try connection.close().wait()
        } catch {
            print("Close connection failed with error: \(error)")
        }
    }
    
    func addContact(_ contact: Contact) -> Task<String, Never> {
        guard let client = client else { return Task { "" } }
        
        let contactInfo = Com_Example_Grpc_ContactInfo.with {
            $0.firstName = contact.firstName
            $0.lastName = contact.lastName
            $0.phoneNumber = contact.phoneNumber
            $0.email = contact.email
        }
        
        return Task {
            do {
                let response = try await client.addContact(contactInfo)
                print("Created contact with id \(response.id)")
                return response.id
            } catch {
                print("addContact failed with error: \(error)")
                return ""
            }
        }
    }
    
    func updateContact(_ contact: Contact) {
        guard let client = client else { return }
        
        let contactInfo = Com_Example_Grpc_ContactInfoWithId.with {
            $0.id = contact.id
            $0.firstName = contact.firstName
            $0.lastName = contact.lastName
            $0.phoneNumber = contact.phoneNumber
            $0.email = contact.email
        }
        
        Task {
            do {
                _ = try await client.updateContact(contactInfo)
                print("Updated contact with id \(contact.id)")
            } catch {
                print("addContact failed with error: \(error)")
            }
        }
    }
    
    func deleteContact(with id: String) {
        guard let client = client else { return }
        
        let contactId = Com_Example_Grpc_ContactId.with {
            $0.id = id
        }
        
        Task {
            do {
                _ = try await client.deleteContact(contactId)
                print("Deleted contact with id \(id)")
            } catch {
                print("deleteContact failed with error: \(error)")
            }
        }
    }
    
    func clearContacts() {
        guard let client = client else { return }
        
        Task {
            do {
                _ = try await client.clearContacts(Com_Example_Grpc_Empty())
                print("Cleared all contacts")
            } catch {
                print("clearContacts failed with error: \(error)")
            }
        }
    }
    
    func getContactsList(completion: @escaping([Contact]) -> Void) {
        guard let client = client else { return }
        
        Task {
            do {
                let response = try await client.getContactsList(Com_Example_Grpc_Empty())
                let contactsList = response.contacts.map { Contact(id: $0.id, firstName: $0.firstName, lastName: $0.lastName, phoneNumber: $0.phoneNumber, email: $0.email) }
                completion(contactsList)
            } catch {
                print("getContactsList failed with error: \(error)")
            }
        }
    }
    
//    func getGroceryListForContact(with id: String) {
//        guard let client = client else { return }
//
//        let contactId = Com_Example_Grpc_ContactId.with {
//            $0.id = id
//        }
//
//        let asyncClient = Com_Example_Grpc_ContactServiceAsyncClient(channel: connection!)
//
//        asyncClient.getGroceryListForContact(<#T##request: Com_Example_Grpc_ContactId##Com_Example_Grpc_ContactId#>)
//
//
//        client.getGroceryListForContact(contactId) { response in
//            response.
//        }
//    }
}

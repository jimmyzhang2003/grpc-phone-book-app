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
    let client: Com_Example_Grpc_ContactServiceNIOClient?
    
    init() {
        let conf = ClientConnection.Configuration.default(
            target: .hostAndPort("localhost", 50051),
            eventLoopGroup: MultiThreadedEventLoopGroup(numberOfThreads: 1)
        )
        
        self.connection = ClientConnection.init(configuration: conf)
        
        guard let connection = connection else {
            self.client = nil
            return
        }
        
        self.client = Com_Example_Grpc_ContactServiceNIOClient(channel: connection)
    }
    
    deinit {
        guard let connection = connection else { return }
        
        do {
            try connection.close().wait()
        } catch {
            print("Close connection failed with error: \(error)")
        }
    }
    
    func addContact(_ contact: Contact) -> String {
        guard let client = client else { return "" }
        
        let contactInfo = Com_Example_Grpc_ContactInfo.with {
            $0.firstName = contact.firstName
            $0.lastName = contact.lastName
            $0.phoneNumber = contact.phoneNumber
            $0.email = contact.email
        }

        var contactId: String = ""
        
        client.addContact(contactInfo).response.whenComplete { result in
            switch result {
            case .success(let response):
                contactId = response.id
                print("Created contact with id \(contactId)")
            case .failure(let error):
                print("addContact failed with error: \(error)")
                return
            }
        }
        
        return contactId
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
        
        client.updateContact(contactInfo).response.whenComplete { result in
            switch result {
            case .success:
                print("Updated contact with id \(contact.id)")
            case .failure(let error):
                print("addContact failed with error: \(error)")
                return
            }
        }
    }
    
    func deleteContact(with id: String) {
        guard let client = client else { return }
        
        let contactId = Com_Example_Grpc_ContactId.with {
            $0.id = id
        }
        
        client.deleteContact(contactId).response.whenComplete { result in
            switch result {
            case .success:
                print("Deleted contact with id \(id)")
            case .failure(let error):
                print("deleteContact failed with error: \(error)")
            }
        }
    }
    
    func clearContacts() {
        guard let client = client else { return }
        
        client.clearContacts(Com_Example_Grpc_Empty()).response.whenComplete { result in
            switch result {
            case .success:
                print("Cleared all contacts")
            case .failure(let error):
                print("clearContacts failed with error: \(error)")
            }
        }
    }
    
    func getContactsList(completion: @escaping([Contact]) -> Void) {
        guard let client = client else { return }

        var contactsList: [Contact] = []
        
        client.getContactsList(Com_Example_Grpc_Empty()).response.whenComplete { result in
            switch result {
            case .success(let response):
                contactsList = response.contacts.map { Contact(id: $0.id, firstName: $0.firstName, lastName: $0.lastName, phoneNumber: $0.phoneNumber, email: $0.email) }
                completion(contactsList)
            case .failure(let error):
                print("getContactsList failed with error: \(error)")
                completion(contactsList)
            }
        }
    }
}

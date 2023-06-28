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
    
    init() {
        let conf = ClientConnection.Configuration.default(
            target: .hostAndPort("localhost", 50051),
            eventLoopGroup: MultiThreadedEventLoopGroup(numberOfThreads: 1)
        )
        
        connection = ClientConnection.init(configuration: conf)
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
        guard let connection = connection else { return "" }
        
        let contactInfo = Com_Example_Grpc_ContactInfo.with {
            $0.firstName = contact.firstName
            $0.lastName = contact.lastName
            $0.phoneNumber = contact.phoneNumber
            $0.email = contact.email
        }
        
        let client = Com_Example_Grpc_ContactServiceNIOClient(channel: connection)
        var contactId: String = ""
        
        client.addContact(contactInfo).response.whenComplete { result in
            switch result {
            case .success(let response):
                contactId = response.id
            case .failure(let error):
                print("addContact failed with error: \(error)")
                return
            }
        }
        
        return contactId
    }
    
    func clearContacts() {
        guard let connection = connection else { return }
        
        let client = Com_Example_Grpc_ContactServiceNIOClient(channel: connection)
        
        client.clearContacts(Com_Example_Grpc_Empty()).response.whenComplete { result in
            switch result {
            case .success:
                print("Cleared all contacts")
            case .failure(let error):
                print("clearContacts failed with error: \(error)")
                return
            }
        }
    }
    
    func getContactsList(completion: @escaping([Contact]) -> Void) {
        guard let connection = connection else { return }
        
        let client = Com_Example_Grpc_ContactServiceNIOClient(channel: connection)
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

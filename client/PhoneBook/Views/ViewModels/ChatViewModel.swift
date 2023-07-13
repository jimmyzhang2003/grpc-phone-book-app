//
//  ChatViewModel.swift
//  PhoneBook
//
//  Created by Jimmy Zhang on 7/12/23.
//

import Foundation

extension ChatView {
    @MainActor class ChatViewModel: ObservableObject {
        @Published var text: String = ""
        @Published var chatLog: [Message] = []
        
        func addMessage(_ message: Message) {
            chatLog.append(message)
        }
        
        func clearChatLog() {
            self.chatLog.removeAll()
        }
    }
}

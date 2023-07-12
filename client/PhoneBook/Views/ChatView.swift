//
//  ChatView.swift
//  PhoneBook
//
//  Created by Jimmy Zhang on 7/11/23.
//

import SwiftUI

struct ChatView: View {
    @State private var text: String = ""
    
    @EnvironmentObject var grpcManager: GRPCManager
    
    let messages = [
        Message(content: "hiya", fromServer: false),
        Message(content: "ayih", fromServer: true)
    ]
    
    var body: some View {
        VStack {
            List(messages, id: \.id) { message in
                buildChatBubble(message)
                    .frame(maxWidth: .infinity, alignment: message.fromServer ? .leading : .trailing)
            }
            .listStyle(.plain)
            
            buildMessageComposer()
        }
        .navigationTitle("Chat Room")
    }
    
    @ViewBuilder private func buildChatBubble(_ message: Message) -> some View {
        Text(message.content)
            .padding()
            .background(.blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 15.0, style: .continuous))
            .listRowSeparator(.hidden)
            .overlay(alignment: message.fromServer ? .bottomLeading : .bottomTrailing) {
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.title)
                    .rotationEffect(message.fromServer ? .degrees(45) : .degrees(315))
                    .offset(x: message.fromServer ? -10 : 10, y: 10)
                    .foregroundColor(.blue)
            }
    }
    
    @ViewBuilder private func buildMessageComposer() -> some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .opacity(0.1)
                    .frame(height: 40)
                
                TextField("Send a message...", text: self.$text)
                    .padding(.horizontal)
            }
            
            Button(
                action: {
                    // TODO: FILL IN
                },
                label: {
                    Image(systemName: "paperplane.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                }
            )
        }
        .padding(.horizontal)
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatView()
                .environmentObject(GRPCManager.shared)
        }
    }
}

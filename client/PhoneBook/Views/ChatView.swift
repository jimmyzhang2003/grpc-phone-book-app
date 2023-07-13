//
//  ChatView.swift
//  PhoneBook
//
//  Created by Jimmy Zhang on 7/11/23.
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject var grpcManager: GRPCManager
    @StateObject var viewModel = ChatViewModel()
    @State var contact: Contact
    
    var body: some View {
        VStack {
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack {
                        ForEach(viewModel.chatLog, id: \.self) { message in
                            buildChatBubble(message)
                                .frame(maxWidth: .infinity, alignment: message.fromServer ? .leading : .trailing)
                                .padding(.horizontal)
                                .padding(.bottom, message == viewModel.chatLog.last ? 25 : 5)
                        }
                    }
                    .onChange(of: viewModel.chatLog) { _ in
                        withAnimation {
                            scrollViewProxy.scrollTo(viewModel.chatLog[viewModel.chatLog.endIndex-1])
                        }
                    }
                }
                .padding(.top)
            }
            
            buildMessageComposer()
        }
        .navigationTitle("Chat Room")
        .task {
            await grpcManager.chatWithContact(with: contact.id) { message in
                DispatchQueue.main.async {
                    viewModel.addMessage(
                        Message(
                            content: message,
                            fromServer: true
                        )
                    )
                }
            }
            
            // TODO: maybe need a getChatLog RPC?
        }
        .onDisappear {
            grpcManager.cancelChatWithContact()
            viewModel.clearChatLog()
        }
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
                
                TextField("Send a message...", text: $viewModel.text)
                    .padding(.horizontal)
            }
            
            Button(
                action: {
                    if viewModel.text != "" {
                        grpcManager.chatMessagePublisher.send(viewModel.text)
                        
                        viewModel.addMessage(
                            Message(
                                content: viewModel.text,
                                fromServer: false
                            )
                        )
                        
                        viewModel.text = ""
                    }
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
        let contact: Contact = Contact(id: "123", firstName: "ABC", lastName: "DEF", phoneNumber: "8888888888", email: "123@abc.com")
        
        NavigationView {
            ChatView(contact: contact)
                .environmentObject(GRPCManager.shared)
        }
    }
}

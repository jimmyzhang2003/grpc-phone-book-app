package com.example;

import com.example.grpc.ContactServiceGrpc;
import com.example.grpc.Empty;
import com.example.grpc.GroceryItem;
import com.example.grpc.ContactInfo;
import com.example.grpc.ContactInfoWithId;
import com.example.grpc.ChatMessage;
import com.example.grpc.ChatMessageWithId;
import com.example.grpc.ContactId;
import com.example.grpc.ContactsList;
import io.grpc.stub.StreamObserver;
import io.grpc.Status;
import jakarta.inject.Singleton;
import java.util.HashMap;
import java.util.Map;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.UUID;

@Singleton
public class ContactServiceImpl extends ContactServiceGrpc.ContactServiceImplBase {
    private final Map<String, ContactInfo> contactInfoMap = new HashMap<>();
    private final Map<String, ArrayList<GroceryItem>> groceryListMap = new HashMap<>();
    private final Map<String, ArrayList<ChatMessage>> chatMessageMap = new HashMap<>();

    private ArrayList<String> groceryItemNames = new ArrayList<>(Arrays.asList(
        "Bread", "Butter", "Cheese", "Pasta", "Fish", "Chips", "Milk", "Butter", "Oil", "Ground Beef", "Flour", "Tomatoes", "Broccoli", "Cereal",  "Chicken"
    ));

    private ArrayList<String> chatMessagePhrases = new ArrayList<>(Arrays.asList(
        "Hey!", "How's it going?", "I'm chilling", "Did you get my grocery list yet?", "Bye!", "Let's catch up some time!", "How've you been?", "You busy today?",
        "Want to grab a drink later?", "See ya!", "Sorry, who is this again?"
    ));
    
    @Override
    public void addContact(ContactInfo request, StreamObserver<ContactId> responseObserver) {
         // create a new contact id
        String id = UUID.randomUUID().toString();

        // create new contact and insert into contact info database
        ContactInfo newContact = ContactInfo.newBuilder()
            .setFirstName(request.getFirstName())
            .setLastName(request.getLastName())
            .setPhoneNumber(request.getPhoneNumber())
            .setEmail(request.getEmail())
            .build();

        contactInfoMap.put(id, newContact);

        ArrayList<GroceryItem> groceryList = new ArrayList<>();
        ArrayList<ChatMessage> chatMessageList = new ArrayList<>();
        
        // add any 5 random items to contact's grocery list and add any 5 phrases to contact's vocabulary
        for(int i = 0; i < 5; i++) {
            groceryList.add(
                GroceryItem.newBuilder()
                    .setName(groceryItemNames.get((int) (Math.random() * groceryItemNames.size())))
                    .setAmount((int) Math.random() * 4 + 1) // quantity between 1 and 5
                    .build()
            );

            chatMessageList.add(
                ChatMessage.newBuilder()
                    .setContent(chatMessagePhrases.get((int) (Math.random() * chatMessagePhrases.size())))
                    .build()
            );
        }

        groceryListMap.put(id, groceryList);
        chatMessageMap.put(id, chatMessageList);

        ContactId response = ContactId.newBuilder()
            .setId(id)
            .build();

        responseObserver.onNext(response);
        responseObserver.onCompleted();
    }

    @Override
    public void updateContact(ContactInfoWithId request, StreamObserver<Empty> responseObserver) {
        try {
            String id = request.getId();
            ContactInfo contact = contactInfoMap.get(id);

            if (id == "") {
                throw new MissingIdException("No ID provided");
            }

            if (contact == null) {
                throw new InvalidIdException("ID not found");
            }

            // update the specified fields
            ContactInfo modifiedContact = contact.toBuilder()
                .setFirstName(request.getFirstName())
                .setLastName(request.getLastName())
                .setPhoneNumber(request.getPhoneNumber())
                .setEmail(request.getEmail())
                .build();

            contactInfoMap.put(id, modifiedContact);
            
            Empty response = Empty.newBuilder().build();
            
            responseObserver.onNext(response);
            responseObserver.onCompleted();
        } catch (MissingIdException ex) {
            Status status = Status.FAILED_PRECONDITION.withDescription("ID must be provided to update contact information");
            responseObserver.onError(status.asRuntimeException());
        } catch (InvalidIdException ex) {
            Status status = Status.INVALID_ARGUMENT.withDescription("ID not found");
            responseObserver.onError(status.asRuntimeException());
        }
    }

    @Override
    public void deleteContact(ContactId request, StreamObserver<Empty> responseObserver) {
        try {
            String id = request.getId();

            if (id == "") {
                throw new MissingIdException("No ID provided");
            }

            if (contactInfoMap.remove(id) == null || groceryListMap.remove(id) == null) {
                throw new InvalidIdException("ID not found");
            }

            Empty response = Empty.newBuilder().build();

            responseObserver.onNext(response);
            responseObserver.onCompleted();
        } catch (MissingIdException ex) {
            Status status = Status.FAILED_PRECONDITION.withDescription("ID must be provided to delete contact");
            responseObserver.onError(status.asRuntimeException());
        } catch (InvalidIdException ex) {
            Status status = Status.INVALID_ARGUMENT.withDescription("ID not found");
            responseObserver.onError(status.asRuntimeException());
        }
    }

    @Override
    public void clearContacts(Empty request, StreamObserver<Empty> responseObserver) {
        contactInfoMap.clear();
        groceryListMap.clear();

        Empty response = Empty.newBuilder().build();

        responseObserver.onNext(response);
        responseObserver.onCompleted();
    }

    @Override
    public void getContact(ContactId request, StreamObserver<ContactInfo> responseObserver) {
        try {
            String id = request.getId();
            ContactInfo contact = contactInfoMap.get(id);

            if (id == "") {
                throw new MissingIdException("No ID provided");
            }

            if (contact == null) {
                throw new InvalidIdException("ID not found");
            }

            ContactInfo response = contact;
            
            responseObserver.onNext(response);
            responseObserver.onCompleted();
        } catch (MissingIdException ex) {
            Status status = Status.FAILED_PRECONDITION.withDescription("ID must be provided to delete contact");
            responseObserver.onError(status.asRuntimeException());
        } catch (InvalidIdException ex) {
            Status status = Status.INVALID_ARGUMENT.withDescription("ID not found");
            responseObserver.onError(status.asRuntimeException());
        }
    }

    @Override
    public void getContactsList(Empty request, StreamObserver<ContactsList> responseObserver) {
        ContactsList.Builder responseBuilder = ContactsList.newBuilder();

        for(Map.Entry<String, ContactInfo> entry : contactInfoMap.entrySet()) {
            String id = entry.getKey();
            ContactInfo contact = entry.getValue();

            responseBuilder.addContacts(ContactInfoWithId.newBuilder()
                .setId(id)
                .setFirstName(contact.getFirstName())
                .setLastName(contact.getLastName())
                .setPhoneNumber(contact.getPhoneNumber())
                .setEmail(contact.getEmail())
                .build()
            );
        }

        ContactsList response = responseBuilder.build();

        responseObserver.onNext(response);
        responseObserver.onCompleted();
    }

    @Override
    public void getGroceryListForContact(ContactId request, StreamObserver<GroceryItem> responseObserver) {
        try {
            String id = request.getId();
            ArrayList<GroceryItem> groceryList = groceryListMap.get(id);

            if (id == "") {
                throw new MissingIdException("No ID provided");
            }

            if (groceryList == null) {
                throw new InvalidIdException("ID not found");
            }

            for(GroceryItem item : groceryList) {
                // sleep for a random amount of time between 1 and 5 seconds
                Thread.sleep(1000 * ((int) (Math.random() * 4) + 1));

                responseObserver.onNext(item);

            }

            responseObserver.onCompleted();
        } catch (MissingIdException ex) {
            Status status = Status.FAILED_PRECONDITION.withDescription("ID must be provided to delete contact");
            responseObserver.onError(status.asRuntimeException());
        } catch (InvalidIdException ex) {
            Status status = Status.INVALID_ARGUMENT.withDescription("ID not found");
            responseObserver.onError(status.asRuntimeException());
        } catch (InterruptedException ex) {
            Status status = Status.INTERNAL.withDescription("Thread interrupted");
            responseObserver.onError(status.asRuntimeException());
            Thread.currentThread().interrupt();
        }
    }

    @Override 
    public StreamObserver<ChatMessageWithId> chat(final StreamObserver<ChatMessage> responseObserver) {
        return new StreamObserver<ChatMessageWithId>() {
            @Override
            public void onNext(ChatMessageWithId message) {
                try {
                    String id = message.getId();
                    ArrayList<ChatMessage> chatMessageList = chatMessageMap.get(id);

                    // TODO: NEED TO EVENTUALLY SAVE THE CHAT LOG SOMEWHERE

                    
                    
                    if (id == "") {
                        throw new MissingIdException("No ID provided");
                    }

                    if (chatMessageList == null) {
                        throw new InvalidIdException("ID not found");
                    }

                    for(ChatMessage phrase : chatMessageList) {
                            // sleep for a random amount of time between 1 and 5 seconds
                            Thread.sleep(1000 * ((int) (Math.random() * 4) + 1));

                            responseObserver.onNext(phrase);
                    }
                } catch (MissingIdException ex) {
                    Status status = Status.FAILED_PRECONDITION.withDescription("ID must be provided to delete contact");
                    responseObserver.onError(status.asRuntimeException());
                } catch (InvalidIdException ex) {
                    Status status = Status.INVALID_ARGUMENT.withDescription("ID not found");
                    responseObserver.onError(status.asRuntimeException());
                } catch (InterruptedException ex) {
                    Status status = Status.INTERNAL.withDescription("Thread interrupted");
                    responseObserver.onError(status.asRuntimeException());
                    Thread.currentThread().interrupt();
                }
            }

            @Override
            public void onError(Throwable t) {
                System.out.println("Error: " + t.toString());
            }

            @Override
            public void onCompleted() {
                responseObserver.onCompleted();
            }
        };
    }
}
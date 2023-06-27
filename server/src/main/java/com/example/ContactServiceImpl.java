package com.example;

import com.example.grpc.ContactServiceGrpc;
import com.example.grpc.Empty;
import com.example.grpc.ContactInfo;
import com.example.grpc.ContactInfoWithId;
import com.example.grpc.ContactId;
import com.example.grpc.ContactsList;
import io.grpc.stub.StreamObserver;
import jakarta.inject.Singleton;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Singleton
public class ContactServiceImpl extends ContactServiceGrpc.ContactServiceImplBase {
    private final Map<String, ContactInfo> database = new HashMap<>();

    @Override
    public void addContact(ContactInfo request, StreamObserver<ContactId> responseObserver) {
         // create a new contact id
        String id = UUID.randomUUID().toString();

        // create new contact and insert into database
        ContactInfo newContact = ContactInfo.newBuilder()
            .setFirstName(request.getFirstName())
            .setLastName(request.getLastName())
            .setPhoneNumber(request.getPhoneNumber())
            .setEmail(request.getEmail())
            .build();

        database.put(id, newContact);

        ContactId response = ContactId.newBuilder()
            .setId(id)
            .build();

        responseObserver.onNext(response);
        responseObserver.onCompleted();
    }

    @Override
    public void updateContact(ContactInfoWithId request, StreamObserver<Empty> responseObserver) {
        String id = request.getId();

        ContactInfo contact = database.get(id);

        // CHECK TO MAKE SURE WHETHER THESE FIELDS ARE ACTUALLY PROVIDED

        // update the specified fields
        ContactInfo modifiedContact = contact.toBuilder()
            .setFirstName(request.getFirstName())
            .setLastName(request.getLastName())
            .setPhoneNumber(request.getPhoneNumber())
            .setEmail(request.getEmail())
            .build();

        database.put(id, modifiedContact);
        
        Empty response = Empty.newBuilder().build();
        
        responseObserver.onNext(response);
        responseObserver.onCompleted();
    }

    @Override
    public void getContactsList(Empty request, StreamObserver<ContactsList> responseObserver) {
        ContactsList.Builder responseBuilder = ContactsList.newBuilder();

        for(Map.Entry<String, ContactInfo> entry : database.entrySet()) {
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
}

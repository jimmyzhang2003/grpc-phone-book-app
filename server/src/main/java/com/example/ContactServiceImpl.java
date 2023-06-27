package com.example;

import com.example.grpc.ContactServiceGrpc;
import com.example.grpc.Empty;
import com.example.grpc.ContactInfo;
import com.example.grpc.ContactInfoWithId;
import com.example.grpc.ContactId;
import com.example.grpc.ContactsList;
import io.grpc.stub.StreamObserver;
import io.grpc.Status;
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
        try {
            String id = request.getId();
            ContactInfo contact = database.get(id);

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

            database.put(id, modifiedContact);
            
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

            if (database.remove(id) == null) {
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
        database.clear();

        Empty response = Empty.newBuilder().build();

        responseObserver.onNext(response);
        responseObserver.onCompleted();
    }

    @Override
    public void getContact(ContactId request, StreamObserver<ContactInfo> responseObserver) {
        try {
            String id = request.getId();
            ContactInfo contact = database.get(id);

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
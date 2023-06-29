package com.example;

import com.example.grpc.ContactServiceGrpc;
import com.example.grpc.Empty;
import com.example.grpc.GroceryItem;
import com.example.grpc.ContactInfo;
import com.example.grpc.ContactInfoWithId;
import com.example.grpc.ContactId;
import com.example.grpc.ContactsList;
import io.grpc.stub.StreamObserver;
import io.grpc.Status;
import jakarta.inject.Singleton;
import java.util.HashMap;
import java.util.Map;
import java.util.ArrayList;
import java.util.UUID;

@Singleton
public class ContactServiceImpl extends ContactServiceGrpc.ContactServiceImplBase {
    private final Map<String, ContactInfo> contactInfoMap = new HashMap<>();
    private final Map<String, ArrayList<GroceryItem>> groceryListMap = new HashMap<>();

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
        groceryList.add(
            GroceryItem.newBuilder()
                .setName("Bread")
                .setAmount(1)
                .build()
        );
        groceryList.add(
            GroceryItem.newBuilder()
                .setName("Butter")
                .setAmount(2)
                .build()
        );
        groceryList.add(
            GroceryItem.newBuilder()
                .setName("Cheese")
                .setAmount(4)
                .build()
        );
        groceryList.add(
            GroceryItem.newBuilder()
                .setName("Milk")
                .setAmount(2)
                .build()
        );
        groceryList.add(
            GroceryItem.newBuilder()
                .setName("Fish")
                .setAmount(1)
                .build()
        );

        groceryListMap.put(id, groceryList);

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
                responseObserver.onNext(item);

                // sleep for a short, random amount of time
                Thread.sleep((int) Math.random() * 5000);
            }

            responseObserver.onCompleted();
        } catch (MissingIdException ex) {
            Status status = Status.FAILED_PRECONDITION.withDescription("ID must be provided to delete contact");
            responseObserver.onError(status.asRuntimeException());
        } catch (InvalidIdException ex) {
            Status status = Status.INVALID_ARGUMENT.withDescription("ID not found");
            responseObserver.onError(status.asRuntimeException());
        } catch (InterruptedException ex) {
            Status status = Status.INTERNAL.withDescription("Thread interrupted.");
            responseObserver.onError(status.asRuntimeException());
            Thread.currentThread().interrupt();
        }
    }
}
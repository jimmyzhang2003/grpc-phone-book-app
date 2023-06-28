# grpc-phone-book-app

## Dependencies
To run the app locally, you will need:
- [Java 17](https://www.oracle.com/java/technologies/downloads/#java17)
- [Xcode 14.3](https://itunes.apple.com/us/app/xcode/id497799835?mt=12)
- [grpc-swift 1.17.0](https://github.com/grpc/grpc-swift)
- [swift-protobuf 1.22.0](https://github.com/apple/swift-protobuf)

## Start the Server
To start the gRPC server (in Java), run:
```
cd server
./gradlew run
```

## Start the Client
To start the client, simply build the PhoneBook application in XCode and run on an iPhone simulator.
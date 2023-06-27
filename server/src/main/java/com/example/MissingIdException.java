package com.example;

public class MissingIdException extends RuntimeException {
    public MissingIdException(String message) {
        super(message);
    }
}
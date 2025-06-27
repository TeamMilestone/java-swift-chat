package com.chat.backend.exception;

import org.springframework.http.HttpStatus;

public class UserNotFoundException extends BusinessException {
    public UserNotFoundException(String message) {
        super(message, HttpStatus.NOT_FOUND);
    }
    
    public UserNotFoundException(Long userId) {
        super("User not found with id: " + userId, HttpStatus.NOT_FOUND);
    }
}
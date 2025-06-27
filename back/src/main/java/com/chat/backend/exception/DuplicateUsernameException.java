package com.chat.backend.exception;

import org.springframework.http.HttpStatus;

public class DuplicateUsernameException extends BusinessException {
    public DuplicateUsernameException(String username) {
        super("Username already exists: " + username, HttpStatus.CONFLICT);
    }
}
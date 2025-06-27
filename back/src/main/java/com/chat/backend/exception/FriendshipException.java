package com.chat.backend.exception;

import org.springframework.http.HttpStatus;

public class FriendshipException extends BusinessException {
    public FriendshipException(String message) {
        super(message, HttpStatus.BAD_REQUEST);
    }
    
    public static FriendshipException alreadyFriends() {
        return new FriendshipException("Already friends");
    }
    
    public static FriendshipException cannotAddSelf() {
        return new FriendshipException("Cannot add yourself as friend");
    }
    
    public static FriendshipException notFriends() {
        return new FriendshipException("Friendship not found");
    }
}
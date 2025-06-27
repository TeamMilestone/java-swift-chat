package com.chat.backend.service;

import com.chat.backend.dto.response.UserDTO;

import java.util.List;

public interface FriendService {
    void addFriend(Long userId, Long friendId);
    void removeFriend(Long userId, Long friendId);
    List<UserDTO> getFriends(Long userId);
    List<UserDTO> searchUsers(String query, Long currentUserId);
}
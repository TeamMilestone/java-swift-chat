package com.chat.backend.service.impl;

import com.chat.backend.dto.response.UserDTO;
import com.chat.backend.entity.Friend;
import com.chat.backend.entity.User;
import com.chat.backend.exception.FriendshipException;
import com.chat.backend.exception.UserNotFoundException;
import com.chat.backend.repository.FriendRepository;
import com.chat.backend.repository.UserRepository;
import com.chat.backend.service.FriendService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional
public class FriendServiceImpl implements FriendService {
    
    private final UserRepository userRepository;
    private final FriendRepository friendRepository;
    
    @Override
    public void addFriend(Long userId, Long friendId) {
        log.info("Adding friend: userId={}, friendId={}", userId, friendId);
        
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException(userId));
        User friend = userRepository.findById(friendId)
                .orElseThrow(() -> new UserNotFoundException(friendId));
        
        if (user.getId().equals(friend.getId())) {
            throw FriendshipException.cannotAddSelf();
        }
        
        if (friendRepository.existsFriendship(user, friend)) {
            throw FriendshipException.alreadyFriends();
        }
        
        // 양방향 친구 관계 생성
        createBidirectionalFriendship(user, friend);
        
        log.info("Friend added successfully: userId={}, friendId={}", userId, friendId);
    }
    
    @Override
    public void removeFriend(Long userId, Long friendId) {
        log.info("Removing friend: userId={}, friendId={}", userId, friendId);
        
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException(userId));
        User friend = userRepository.findById(friendId)
                .orElseThrow(() -> new UserNotFoundException(friendId));
        
        // 양방향 친구 관계 삭제
        removeBidirectionalFriendship(user, friend);
        
        log.info("Friend removed successfully: userId={}, friendId={}", userId, friendId);
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<UserDTO> getFriends(Long userId) {
        List<User> friends = friendRepository.findFriendsByUserId(userId);
        return friends.stream()
                .map(this::toUserDTO)
                .collect(Collectors.toList());
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<UserDTO> searchUsers(String query, Long currentUserId) {
        return userRepository.findAll().stream()
                .filter(user -> !user.getId().equals(currentUserId))
                .filter(user -> matchesSearchQuery(user, query))
                .map(this::toUserDTO)
                .collect(Collectors.toList());
    }
    
    private void createBidirectionalFriendship(User user, User friend) {
        Friend friendship1 = Friend.builder()
                .user(user)
                .friend(friend)
                .build();
        friendRepository.save(friendship1);
        
        Friend friendship2 = Friend.builder()
                .user(friend)
                .friend(user)
                .build();
        friendRepository.save(friendship2);
    }
    
    private void removeBidirectionalFriendship(User user, User friend) {
        Friend friendship1 = friendRepository.findFriendship(user, friend)
                .orElseThrow(FriendshipException::notFriends);
        friendRepository.delete(friendship1);
        
        friendRepository.findFriendship(friend, user)
                .ifPresent(friendRepository::delete);
    }
    
    private boolean matchesSearchQuery(User user, String query) {
        return user.getUsername().contains(query) || 
               user.getNickname().contains(query) ||
               user.getId().toString().equals(query);
    }
    
    private UserDTO toUserDTO(User user) {
        return UserDTO.builder()
                .id(user.getId())
                .username(user.getUsername())
                .nickname(user.getNickname())
                .profileImageUrl("/api/files/" + user.getProfileImagePath())
                .lastSeen(user.getLastSeen())
                .build();
    }
}
package com.chat.backend.controller;

import com.chat.backend.dto.response.UserDTO;
import com.chat.backend.service.FriendService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/friends")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class FriendController {
    
    private final FriendService friendService;
    
    @GetMapping("/search")
    public ResponseEntity<List<UserDTO>> searchUsers(
            @RequestParam String query,
            @RequestParam Long userId) {
        List<UserDTO> users = friendService.searchUsers(query, userId);
        return ResponseEntity.ok(users);
    }
    
    @GetMapping
    public ResponseEntity<List<UserDTO>> getFriends(@RequestParam Long userId) {
        List<UserDTO> friends = friendService.getFriends(userId);
        return ResponseEntity.ok(friends);
    }
    
    @PostMapping("/add")
    public ResponseEntity<?> addFriend(@RequestBody Map<String, Long> request) {
        try {
            Long userId = request.get("userId");
            Long friendId = request.get("friendId");
            
            friendService.addFriend(userId, friendId);
            return ResponseEntity.ok(Map.of("success", true, "message", "Friend added successfully"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
    
    @DeleteMapping("/remove")
    public ResponseEntity<?> removeFriend(
            @RequestParam Long userId,
            @RequestParam Long friendId) {
        try {
            friendService.removeFriend(userId, friendId);
            return ResponseEntity.ok(Map.of("success", true, "message", "Friend removed successfully"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}
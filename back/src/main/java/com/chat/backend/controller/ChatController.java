package com.chat.backend.controller;

import com.chat.backend.dto.response.ChatRoomDTO;
import com.chat.backend.dto.response.MessageDTO;
import com.chat.backend.entity.ChatRoom;
import com.chat.backend.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/chat")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ChatController {
    
    private final ChatService chatService;
    
    @GetMapping("/rooms")
    public ResponseEntity<List<ChatRoomDTO>> getUserChatRooms(@RequestParam Long userId) {
        List<ChatRoomDTO> rooms = chatService.getUserChatRooms(userId);
        return ResponseEntity.ok(rooms);
    }
    
    @PostMapping("/rooms/direct")
    public ResponseEntity<?> createDirectChat(@RequestBody Map<String, Long> request) {
        Long userId1 = request.get("userId1");
        Long userId2 = request.get("userId2");
        
        ChatRoom chatRoom = chatService.createOrGetDirectChat(userId1, userId2);
        return ResponseEntity.ok(Map.of("chatRoomId", chatRoom.getId()));
    }
    
    @PostMapping("/rooms/group")
    public ResponseEntity<?> createGroupChat(@RequestBody Map<String, Object> request) {
        String name = (String) request.get("name");
        List<Long> participantIds = (List<Long>) request.get("participantIds");
        
        ChatRoom chatRoom = chatService.createGroupChat(name, participantIds);
        return ResponseEntity.ok(Map.of("chatRoomId", chatRoom.getId()));
    }
    
    @GetMapping("/rooms/{roomId}/messages")
    public ResponseEntity<List<MessageDTO>> getChatRoomMessages(
            @PathVariable Long roomId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "50") int size) {
        List<MessageDTO> messages = chatService.getChatRoomMessages(roomId, page, size);
        return ResponseEntity.ok(messages);
    }
    
    @PutMapping("/rooms/{roomId}/announcement")
    public ResponseEntity<?> updateAnnouncement(
            @PathVariable Long roomId,
            @RequestBody Map<String, String> request) {
        String announcement = request.get("announcement");
        chatService.updateAnnouncement(roomId, announcement);
        return ResponseEntity.ok(Map.of("success", true));
    }
    
    @PostMapping("/rooms/{roomId}/messages")
    public ResponseEntity<MessageDTO> sendMessage(
            @PathVariable Long roomId,
            @RequestBody Map<String, Object> request) {
        Long senderId = ((Number) request.get("senderId")).longValue();
        String content = (String) request.get("content");
        
        var message = chatService.sendMessage(senderId, roomId, content);
        return ResponseEntity.ok(chatService.toMessageDTO(message));
    }
}
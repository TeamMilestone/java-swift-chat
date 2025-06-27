package com.chat.backend.websocket;

import com.chat.backend.dto.response.MessageDTO;
import com.chat.backend.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.stereotype.Controller;

import java.util.Map;

@Controller
@RequiredArgsConstructor
public class ChatWebSocketController {
    
    private final ChatService chatService;
    
    @MessageMapping("/chat.send/{roomId}")
    public void sendMessage(@DestinationVariable Long roomId, @Payload Map<String, Object> message) {
        Long senderId = ((Number) message.get("senderId")).longValue();
        String content = (String) message.get("content");
        
        chatService.sendMessage(senderId, roomId, content);
    }
    
    @MessageMapping("/chat.read/{roomId}")
    public void markAsRead(@DestinationVariable Long roomId, @Payload Map<String, Object> data) {
        Long messageId = ((Number) data.get("messageId")).longValue();
        Long userId = ((Number) data.get("userId")).longValue();
        
        chatService.markAsRead(messageId, userId);
    }
}
package com.chat.backend.service;

import com.chat.backend.dto.response.ChatRoomDTO;
import com.chat.backend.dto.response.MessageDTO;
import com.chat.backend.entity.*;
import com.chat.backend.repository.*;
import com.chat.backend.websocket.SimpleWebSocketHandler;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class ChatService {
    
    private final ChatRoomRepository chatRoomRepository;
    private final MessageRepository messageRepository;
    private final UserRepository userRepository;
    private final MessageReadStatusRepository readStatusRepository;
    private final SimpMessagingTemplate messagingTemplate;
    private final SimpleWebSocketHandler webSocketHandler;
    private final UserService userService;
    
    public ChatRoom createOrGetDirectChat(Long userId1, Long userId2) {
        User user1 = userRepository.findById(userId1)
                .orElseThrow(() -> new RuntimeException("User not found"));
        User user2 = userRepository.findById(userId2)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        return chatRoomRepository.findDirectChatRoom(user1, user2)
                .orElseGet(() -> {
                    ChatRoom chatRoom = new ChatRoom();
                    chatRoom.setGroup(false);
                    chatRoom.setParticipants(Arrays.asList(user1, user2));
                    return chatRoomRepository.save(chatRoom);
                });
    }
    
    public ChatRoom createGroupChat(String name, List<Long> participantIds) {
        List<User> participants = userRepository.findAllById(participantIds);
        
        ChatRoom chatRoom = new ChatRoom();
        chatRoom.setName(name);
        chatRoom.setGroup(true);
        chatRoom.setParticipants(participants);
        
        return chatRoomRepository.save(chatRoom);
    }
    
    public Message sendMessage(Long senderId, Long chatRoomId, String content) {
        User sender = userRepository.findById(senderId)
                .orElseThrow(() -> new RuntimeException("Sender not found"));
        ChatRoom chatRoom = chatRoomRepository.findById(chatRoomId)
                .orElseThrow(() -> new RuntimeException("Chat room not found"));
        
        Message message = new Message();
        message.setSender(sender);
        message.setChatRoom(chatRoom);
        message.setContent(content);
        
        Message savedMessage = messageRepository.save(message);
        
        // Send via both WebSocket types
        MessageDTO messageDTO = toMessageDTO(savedMessage);
        
        // STOMP WebSocket (기존)
        messagingTemplate.convertAndSend("/topic/chatroom." + chatRoomId, messageDTO);
        
        // Simple WebSocket for iOS
        webSocketHandler.broadcastToRoom(chatRoomId, messageDTO);
        
        return savedMessage;
    }
    
    public void markAsRead(Long messageId, Long userId) {
        if (!readStatusRepository.existsByMessageIdAndUserId(messageId, userId)) {
            Message message = messageRepository.findById(messageId)
                    .orElseThrow(() -> new RuntimeException("Message not found"));
            User user = userRepository.findById(userId)
                    .orElseThrow(() -> new RuntimeException("User not found"));
            
            MessageReadStatus readStatus = new MessageReadStatus();
            readStatus.setMessage(message);
            readStatus.setUser(user);
            
            readStatusRepository.save(readStatus);
        }
    }
    
    public void updateAnnouncement(Long chatRoomId, String announcement) {
        ChatRoom chatRoom = chatRoomRepository.findById(chatRoomId)
                .orElseThrow(() -> new RuntimeException("Chat room not found"));
        
        chatRoom.setAnnouncement(announcement);
        chatRoomRepository.save(chatRoom);
    }
    
    public List<ChatRoomDTO> getUserChatRooms(Long userId) {
        List<ChatRoom> chatRooms = chatRoomRepository.findByParticipantId(userId);
        
        return chatRooms.stream()
                .map(room -> toChatRoomDTO(room, userId))
                .collect(Collectors.toList());
    }
    
    public List<MessageDTO> getChatRoomMessages(Long chatRoomId, int page, int size) {
        PageRequest pageRequest = PageRequest.of(page, size);
        return messageRepository.findByChatRoomIdOrderBySentAtDesc(chatRoomId, pageRequest)
                .map(this::toMessageDTO)
                .getContent();
    }
    
    private ChatRoomDTO toChatRoomDTO(ChatRoom chatRoom, Long currentUserId) {
        ChatRoomDTO.ChatRoomDTOBuilder builder = ChatRoomDTO.builder()
                .id(chatRoom.getId())
                .name(chatRoom.getName())
                .isGroup(chatRoom.isGroup())
                .announcement(chatRoom.getAnnouncement())
                .updatedAt(chatRoom.getUpdatedAt())
                .participants(chatRoom.getParticipants().stream()
                        .map(userService::toDTO)
                        .collect(Collectors.toList()));
        
        // Get last message
        List<Message> messages = messageRepository.findByChatRoomIdOrderBySentAtDesc(
                chatRoom.getId(), PageRequest.of(0, 1)).getContent();
        if (!messages.isEmpty()) {
            builder.lastMessage(toMessageDTO(messages.get(0)));
        }
        
        // Calculate unread count
        long unreadCount = chatRoom.getMessages().stream()
                .filter(msg -> !msg.getSender().getId().equals(currentUserId))
                .filter(msg -> msg.getReadStatuses().stream()
                        .noneMatch(rs -> rs.getUser().getId().equals(currentUserId)))
                .count();
        builder.unreadCount((int) unreadCount);
        
        return builder.build();
    }
    
    public MessageDTO toMessageDTO(Message message) {
        return MessageDTO.builder()
                .id(message.getId())
                .content(message.getContent())
                .senderId(message.getSender().getId())
                .senderName(message.getSender().getNickname())
                .senderProfileImageUrl("/api/files/" + message.getSender().getProfileImagePath())
                .chatRoomId(message.getChatRoom().getId())
                .sentAt(message.getSentAt())
                .unreadCount(message.getChatRoom().getParticipants().size() - 1 - message.getReadStatuses().size())
                .build();
    }
}
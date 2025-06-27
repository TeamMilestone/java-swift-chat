package com.chat.backend.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MessageDTO {
    private Long id;
    private String content;
    private Long senderId;
    private String senderName;
    private String senderProfileImageUrl;
    private Long chatRoomId;
    private LocalDateTime sentAt;
    private int unreadCount;
}
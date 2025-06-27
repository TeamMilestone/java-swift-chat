package com.chat.backend.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChatRoomDTO {
    private Long id;
    private String name;
    private boolean isGroup;
    private String announcement;
    private LocalDateTime updatedAt;
    private List<UserDTO> participants;
    private MessageDTO lastMessage;
    private int unreadCount;
}
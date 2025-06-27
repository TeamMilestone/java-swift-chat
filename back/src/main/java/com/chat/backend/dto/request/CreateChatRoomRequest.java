package com.chat.backend.dto.request;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateChatRoomRequest {
    
    private String name;
    
    @NotNull(message = "Participant IDs are required")
    @NotEmpty(message = "At least one participant is required")
    private List<Long> participantIds;
}
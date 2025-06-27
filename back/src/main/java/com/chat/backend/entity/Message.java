package com.chat.backend.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "messages")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Message {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(columnDefinition = "TEXT", nullable = false)
    private String content;
    
    @ManyToOne
    @JoinColumn(name = "sender_id", nullable = false)
    private User sender;
    
    @ManyToOne
    @JoinColumn(name = "chat_room_id", nullable = false)
    private ChatRoom chatRoom;
    
    @Column(name = "sent_at")
    private LocalDateTime sentAt;
    
    @OneToMany(mappedBy = "message", cascade = CascadeType.ALL)
    private List<MessageReadStatus> readStatuses = new ArrayList<>();
    
    @PrePersist
    protected void onCreate() {
        sentAt = LocalDateTime.now();
    }
}
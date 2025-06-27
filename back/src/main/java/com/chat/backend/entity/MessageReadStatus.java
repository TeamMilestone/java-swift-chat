package com.chat.backend.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "message_read_status")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MessageReadStatus {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    @JoinColumn(name = "message_id", nullable = false)
    private Message message;
    
    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
    
    @Column(name = "read_at")
    private LocalDateTime readAt;
    
    @PrePersist
    protected void onCreate() {
        readAt = LocalDateTime.now();
    }
}
package com.chat.backend.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(unique = true, nullable = false)
    private String username;
    
    @Column(nullable = false)
    private String password;
    
    private String nickname;
    
    private String profileImagePath;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "last_seen")
    private LocalDateTime lastSeen;
    
    @OneToMany(mappedBy = "sender", cascade = CascadeType.ALL)
    private List<Message> sentMessages = new ArrayList<>();
    
    @ManyToMany(mappedBy = "participants")
    private List<ChatRoom> chatRooms = new ArrayList<>();
    
    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL)
    private List<Friend> friends = new ArrayList<>();
    
    @OneToMany(mappedBy = "friend", cascade = CascadeType.ALL)
    private List<Friend> friendOf = new ArrayList<>();
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        lastSeen = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        lastSeen = LocalDateTime.now();
    }
}
package com.chat.backend.repository;

import com.chat.backend.entity.ChatRoom;
import com.chat.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ChatRoomRepository extends JpaRepository<ChatRoom, Long> {
    
    @Query("SELECT c FROM ChatRoom c JOIN c.participants p WHERE p.id = :userId")
    List<ChatRoom> findByParticipantId(@Param("userId") Long userId);
    
    @Query("SELECT c FROM ChatRoom c WHERE c.isGroup = false AND :user1 MEMBER OF c.participants AND :user2 MEMBER OF c.participants")
    Optional<ChatRoom> findDirectChatRoom(@Param("user1") User user1, @Param("user2") User user2);
}
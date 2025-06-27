package com.chat.backend.repository;

import com.chat.backend.entity.MessageReadStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MessageReadStatusRepository extends JpaRepository<MessageReadStatus, Long> {
    boolean existsByMessageIdAndUserId(Long messageId, Long userId);
}
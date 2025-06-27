package com.chat.backend.repository;

import com.chat.backend.entity.Friend;
import com.chat.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FriendRepository extends JpaRepository<Friend, Long> {
    
    @Query("SELECT f FROM Friend f WHERE f.user = :user AND f.friend = :friend")
    Optional<Friend> findFriendship(@Param("user") User user, @Param("friend") User friend);
    
    @Query("SELECT f.friend FROM Friend f WHERE f.user.id = :userId")
    List<User> findFriendsByUserId(@Param("userId") Long userId);
    
    @Query("SELECT CASE WHEN COUNT(f) > 0 THEN true ELSE false END FROM Friend f WHERE f.user = :user AND f.friend = :friend")
    boolean existsFriendship(@Param("user") User user, @Param("friend") User friend);
}
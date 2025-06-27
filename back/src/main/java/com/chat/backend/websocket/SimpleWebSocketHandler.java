package com.chat.backend.websocket;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.*;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArraySet;

@Slf4j
@Component
@RequiredArgsConstructor
public class SimpleWebSocketHandler implements WebSocketHandler {
    
    private final ObjectMapper objectMapper = new ObjectMapper();
    
    // roomId -> Set of WebSocketSessions
    private final Map<Long, CopyOnWriteArraySet<WebSocketSession>> roomSessions = new ConcurrentHashMap<>();
    
    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        log.info("WebSocket connection established: {}", session.getId());
        session.sendMessage(new TextMessage("{\"type\":\"connected\",\"message\":\"Connected successfully\"}"));
    }
    
    @Override
    public void handleMessage(WebSocketSession session, WebSocketMessage<?> message) throws Exception {
        if (message instanceof TextMessage) {
            String payload = ((TextMessage) message).getPayload();
            log.info("Received message: {}", payload);
            
            try {
                Map<String, Object> messageData = objectMapper.readValue(payload, Map.class);
                String type = (String) messageData.get("type");
                
                if ("subscribe".equals(type)) {
                    Long roomId = ((Number) messageData.get("roomId")).longValue();
                    subscribeToRoom(session, roomId);
                } else if ("unsubscribe".equals(type)) {
                    Long roomId = ((Number) messageData.get("roomId")).longValue();
                    unsubscribeFromRoom(session, roomId);
                }
            } catch (Exception e) {
                log.error("Error handling message: {}", e.getMessage());
            }
        }
    }
    
    @Override
    public void handleTransportError(WebSocketSession session, Throwable exception) throws Exception {
        log.error("WebSocket transport error for session {}: {}", session.getId(), exception.getMessage());
    }
    
    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus closeStatus) throws Exception {
        log.info("WebSocket connection closed: {} - {}", session.getId(), closeStatus);
        // Remove session from all rooms
        roomSessions.values().forEach(sessions -> sessions.remove(session));
    }
    
    @Override
    public boolean supportsPartialMessages() {
        return false;
    }
    
    private void subscribeToRoom(WebSocketSession session, Long roomId) {
        roomSessions.computeIfAbsent(roomId, k -> new CopyOnWriteArraySet<>()).add(session);
        log.info("Session {} subscribed to room {}", session.getId(), roomId);
        
        try {
            session.sendMessage(new TextMessage(
                String.format("{\"type\":\"subscribed\",\"roomId\":%d,\"message\":\"Subscribed to room %d\"}", roomId, roomId)
            ));
        } catch (IOException e) {
            log.error("Error sending subscription confirmation: {}", e.getMessage());
        }
    }
    
    private void unsubscribeFromRoom(WebSocketSession session, Long roomId) {
        CopyOnWriteArraySet<WebSocketSession> sessions = roomSessions.get(roomId);
        if (sessions != null) {
            sessions.remove(session);
            log.info("Session {} unsubscribed from room {}", session.getId(), roomId);
        }
    }
    
    public void broadcastToRoom(Long roomId, Object message) {
        CopyOnWriteArraySet<WebSocketSession> sessions = roomSessions.get(roomId);
        if (sessions != null) {
            String messageJson;
            try {
                messageJson = objectMapper.writeValueAsString(message);
            } catch (Exception e) {
                log.error("Error serializing message: {}", e.getMessage());
                return;
            }
            
            sessions.removeIf(session -> {
                try {
                    if (session.isOpen()) {
                        session.sendMessage(new TextMessage(messageJson));
                        return false;
                    } else {
                        return true; // Remove closed sessions
                    }
                } catch (IOException e) {
                    log.error("Error sending message to session {}: {}", session.getId(), e.getMessage());
                    return true; // Remove problematic sessions
                }
            });
        }
    }
}
package com.chat.backend.controller;

import com.chat.backend.dto.request.LoginRequest;
import com.chat.backend.dto.request.RegisterRequest;
import com.chat.backend.dto.response.UserDTO;
import com.chat.backend.entity.User;
import com.chat.backend.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AuthController {
    
    private final UserService userService;
    
    @PostMapping("/register")
    public ResponseEntity<?> register(@Valid @RequestBody RegisterRequest request) {
        try {
            User user = userService.register(request);
            UserDTO userDTO = userService.toDTO(user);
            
            Map<String, Object> response = new HashMap<>();
            response.put("user", userDTO);
            response.put("token", "dummy-token-" + user.getId()); // In production, use JWT
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
    
    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequest request) {
        return userService.login(request.getUsername(), request.getPassword())
                .map(user -> {
                    UserDTO userDTO = userService.toDTO(user);
                    
                    Map<String, Object> response = new HashMap<>();
                    response.put("user", userDTO);
                    response.put("token", "dummy-token-" + user.getId()); // In production, use JWT
                    
                    return ResponseEntity.ok(response);
                })
                .orElse(ResponseEntity.badRequest().body(Map.of("error", "Invalid credentials")));
    }
}
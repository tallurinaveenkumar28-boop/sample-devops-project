package com.example.app.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;
import java.util.Map;

@RestController
public class HealthController {

    @Value("${spring.profiles.active:default}")
    private String activeProfile;

    @GetMapping("/")
    public Map<String, Object> root() {
        return Map.of(
            "service", "springboot-app",
            "status", "running",
            "profile", activeProfile,
            "timestamp", Instant.now().toString()
        );
    }

    @GetMapping("/api/info")
    public Map<String, String> info() {
        return Map.of(
            "name", "springboot-app",
            "version", "1.0.0",
            "java", System.getProperty("java.version"),
            "profile", activeProfile
        );
    }
}

package com.hobbypath.core.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        // Direct STOMP WebSocket endpoint
        registry.addEndpoint("/ws")
                .setAllowedOriginPatterns("*");

        // SockJS fallback endpoint for browsers/clients without native WS
        registry.addEndpoint("/ws")
                .setAllowedOriginPatterns("*")
                .withSockJS();
    }

    @Override
    public void configureMessageBroker(MessageBrokerRegistry registry) {
        // /topic: community & broadcast channels
        // /queue: 1-to-1 private messages
        registry.enableSimpleBroker("/topic", "/queue");

        // Prefix for incoming client messages routed to @MessageMapping handlers
        registry.setApplicationDestinationPrefixes("/app");

        // Prefix for user-targeted private messages
        registry.setUserDestinationPrefix("/user");
    }
}

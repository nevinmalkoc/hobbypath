package com.hobbypath.notification.service;

import com.hobbypath.notification.dto.NotificationResponse;
import com.hobbypath.notification.entity.Notification;
import com.hobbypath.notification.entity.NotificationType;
import com.hobbypath.notification.repository.NotificationRepository;
import com.hobbypath.user.entity.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final SimpMessagingTemplate messagingTemplate;

    @Transactional
    public NotificationResponse createNotification(
            User recipient,
            String title,
            String message,
            NotificationType type,
            Long referenceId
    ) {
        Notification notification = Notification.builder()
                .recipient(recipient)
                .title(title)
                .message(message)
                .type(type)
                .referenceId(referenceId)
                .read(false)
                .build();

        Notification saved = notificationRepository.save(notification);
        NotificationResponse response = mapToResponse(saved);

        // Send real-time push to user queue if connected: /topic/user/{username}/notifications
        try {
            messagingTemplate.convertAndSend("/topic/user/" + recipient.getUsername() + "/notifications", response);
        } catch (Exception e) {
            log.warn("Could not push live notification to user {}: {}", recipient.getUsername(), e.getMessage());
        }

        return response;
    }

    @Transactional(readOnly = true)
    public List<NotificationResponse> getUserNotifications(User user, int limit) {
        int pageSize = Math.min(Math.max(limit, 5), 50);
        List<Notification> list = notificationRepository.findByRecipientIdOrderByCreatedAtDesc(
                user.getId(),
                PageRequest.of(0, pageSize)
        );
        return list.stream().map(this::mapToResponse).toList();
    }

    @Transactional(readOnly = true)
    public long getUnreadCount(User user) {
        return notificationRepository.countByRecipientIdAndReadFalse(user.getId());
    }

    @Transactional
    public void markAsRead(User user, Long notificationId) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new IllegalArgumentException("Notification not found with id: " + notificationId));

        if (!notification.getRecipient().getId().equals(user.getId())) {
            throw new IllegalArgumentException("You can only mark your own notifications as read");
        }

        notification.setRead(true);
        notificationRepository.save(notification);
    }

    @Transactional
    public void markAllAsRead(User user) {
        notificationRepository.markAllAsRead(user.getId());
    }

    private NotificationResponse mapToResponse(Notification n) {
        return NotificationResponse.builder()
                .id(n.getId())
                .title(n.getTitle())
                .message(n.getMessage())
                .type(n.getType())
                .referenceId(n.getReferenceId())
                .read(n.isRead())
                .createdAt(n.getCreatedAt())
                .build();
    }
}

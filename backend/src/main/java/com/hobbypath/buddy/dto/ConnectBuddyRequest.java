package com.hobbypath.buddy.dto;

import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ConnectBuddyRequest {
    @Size(max = 500, message = "Message cannot exceed 500 characters")
    private String message;
}

package com.hobbypath.user.dto;

import com.hobbypath.hobby.dto.UserHobbyResponse;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserProfileResponse {

    private Long id;
    private String username;
    private String email;
    private String fullName;
    private String bio;
    private String location;
    private String avatar;
    private String role;
    private Instant createdAt;
    private List<UserHobbyResponse> hobbies;
}

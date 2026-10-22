package com.hobbypath.user.service;

import com.hobbypath.hobby.dto.AddHobbyRequest;
import com.hobbypath.hobby.dto.UserHobbyResponse;
import com.hobbypath.hobby.entity.Hobby;
import com.hobbypath.hobby.entity.UserHobby;
import com.hobbypath.hobby.repository.HobbyRepository;
import com.hobbypath.hobby.repository.UserHobbyRepository;
import com.hobbypath.user.dto.UpdateProfileRequest;
import com.hobbypath.user.dto.UserProfileResponse;
import com.hobbypath.user.entity.User;
import com.hobbypath.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final HobbyRepository hobbyRepository;
    private final UserHobbyRepository userHobbyRepository;

    @Transactional(readOnly = true)
    public UserProfileResponse getUserProfile(User currentUser) {
        User user = userRepository.findById(currentUser.getId())
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        List<UserHobbyResponse> hobbies = userHobbyRepository.findByUserId(user.getId())
                .stream()
                .map(this::mapToUserHobbyResponse)
                .toList();

        return mapToUserProfileResponse(user, hobbies);
    }

    @Transactional
    public UserProfileResponse updateProfile(User currentUser, UpdateProfileRequest request) {
        User user = userRepository.findById(currentUser.getId())
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        if (request.getFullName() != null && !request.getFullName().isBlank()) {
            user.setFullName(request.getFullName().trim());
        }
        if (request.getBio() != null) {
            user.setBio(request.getBio().trim());
        }
        if (request.getLocation() != null) {
            user.setLocation(request.getLocation().trim());
        }

        User updatedUser = userRepository.save(user);

        List<UserHobbyResponse> hobbies = userHobbyRepository.findByUserId(updatedUser.getId())
                .stream()
                .map(this::mapToUserHobbyResponse)
                .toList();

        return mapToUserProfileResponse(updatedUser, hobbies);
    }

    @Transactional
    public UserHobbyResponse addOrUpdateUserHobby(User currentUser, AddHobbyRequest request) {
        User user = userRepository.findById(currentUser.getId())
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        Hobby hobby = hobbyRepository.findById(request.getHobbyId())
                .orElseThrow(() -> new IllegalArgumentException("Hobby not found with id: " + request.getHobbyId()));

        UserHobby userHobby = userHobbyRepository.findByUserIdAndHobbyId(user.getId(), hobby.getId())
                .orElseGet(() -> UserHobby.builder()
                        .user(user)
                        .hobby(hobby)
                        .build());

        userHobby.setSkillLevel(request.getSkillLevel());
        UserHobby saved = userHobbyRepository.save(userHobby);

        return mapToUserHobbyResponse(saved);
    }

    @Transactional
    public void removeUserHobby(User currentUser, Long hobbyId) {
        if (!userHobbyRepository.existsByUserIdAndHobbyId(currentUser.getId(), hobbyId)) {
            throw new IllegalArgumentException("Hobby is not added to user profile: " + hobbyId);
        }
        userHobbyRepository.deleteByUserIdAndHobbyId(currentUser.getId(), hobbyId);
    }

    private UserHobbyResponse mapToUserHobbyResponse(UserHobby uh) {
        return UserHobbyResponse.builder()
                .id(uh.getId())
                .hobbyId(uh.getHobby().getId())
                .hobbyName(uh.getHobby().getName())
                .category(uh.getHobby().getCategory())
                .icon(uh.getHobby().getIcon())
                .skillLevel(uh.getSkillLevel())
                .build();
    }

    private UserProfileResponse mapToUserProfileResponse(User user, List<UserHobbyResponse> hobbies) {
        return UserProfileResponse.builder()
                .id(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .fullName(user.getFullName())
                .bio(user.getBio())
                .location(user.getLocation())
                .role(user.getRole().name())
                .createdAt(user.getCreatedAt())
                .hobbies(hobbies)
                .build();
    }
}

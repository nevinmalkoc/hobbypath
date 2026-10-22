package com.hobbypath.hobby.service;

import com.hobbypath.hobby.dto.HobbyResponse;
import com.hobbypath.hobby.entity.Hobby;
import com.hobbypath.hobby.repository.HobbyRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class HobbyService {

    private final HobbyRepository hobbyRepository;

    public List<HobbyResponse> getAllHobbies() {
        return hobbyRepository.findAll().stream()
                .map(this::mapToHobbyResponse)
                .toList();
    }

    public HobbyResponse getHobbyById(Long id) {
        Hobby hobby = hobbyRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Hobby not found with id: " + id));
        return mapToHobbyResponse(hobby);
    }

    private HobbyResponse mapToHobbyResponse(Hobby hobby) {
        return HobbyResponse.builder()
                .id(hobby.getId())
                .name(hobby.getName())
                .category(hobby.getCategory())
                .icon(hobby.getIcon())
                .description(hobby.getDescription())
                .build();
    }
}

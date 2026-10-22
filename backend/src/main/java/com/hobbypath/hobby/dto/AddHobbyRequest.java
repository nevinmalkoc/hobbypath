package com.hobbypath.hobby.dto;

import com.hobbypath.hobby.entity.SkillLevel;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AddHobbyRequest {

    @NotNull(message = "Hobby ID is required")
    private Long hobbyId;

    @NotNull(message = "Skill level is required (BEGINNER, INTERMEDIATE, ADVANCED)")
    private SkillLevel skillLevel;
}

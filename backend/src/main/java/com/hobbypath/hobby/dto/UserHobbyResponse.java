package com.hobbypath.hobby.dto;

import com.hobbypath.hobby.entity.SkillLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserHobbyResponse {
    private Long id;
    private Long hobbyId;
    private String hobbyName;
    private String category;
    private String icon;
    private SkillLevel skillLevel;
}

package com.hobbypath.hobby.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class HobbyResponse {
    private Long id;
    private String name;
    private String category;
    private String icon;
    private String description;
}

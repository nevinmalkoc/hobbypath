package com.hobbypath.community.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateCommunityRequest {

    @NotBlank(message = "Community name is required")
    @Size(min = 3, max = 150, message = "Community name must be between 3 and 150 characters")
    private String name;

    private String description;

    @NotNull(message = "Hobby ID is required")
    private Long hobbyId;

    private String coverImage;
}

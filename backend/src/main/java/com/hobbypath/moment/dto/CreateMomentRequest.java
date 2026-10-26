package com.hobbypath.moment.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateMomentRequest {

    @NotNull
    private Long hobbyId;

    private Long communityId;

    @NotBlank
    private String caption;

    @NotBlank
    private String imageUrl;
}

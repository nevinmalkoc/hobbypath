package com.hobbypath.buddy.dto;

import com.hobbypath.buddy.entity.BuddyIntention;
import com.hobbypath.buddy.entity.GenderPreference;
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
public class CreateBuddyRequest {

    @NotNull(message = "Hobby ID is required")
    private Long hobbyId;

    @NotBlank(message = "Title is required")
    @Size(max = 150, message = "Title cannot exceed 150 characters")
    private String title;

    @NotBlank(message = "Description is required")
    private String description;

    @NotNull(message = "Intention is required (FRIENDSHIP, ACTIVITY, DATE)")
    private BuddyIntention intention;

    @NotNull(message = "Gender preference is required")
    private GenderPreference genderPreference;

    @Size(max = 20, message = "Creator gender cannot exceed 20 characters")
    private String creatorGender;

    @Size(max = 100, message = "Location cannot exceed 100 characters")
    private String location;

    @Size(max = 100, message = "Preferred time cannot exceed 100 characters")
    private String preferredTime;
}

package com.hobbypath.gear.dto;

import com.hobbypath.gear.entity.TransferType;
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
public class CreateGearTransferRequest {

    @NotNull(message = "Hobby ID is required")
    private Long hobbyId;

    @NotBlank(message = "Title is required")
    @Size(max = 150, message = "Title cannot exceed 150 characters")
    private String title;

    @NotBlank(message = "Description is required")
    private String description;

    @NotNull(message = "Transfer type is required")
    private TransferType transferType;

    @Size(max = 60, message = "Condition cannot exceed 60 characters")
    private String itemCondition;

    @Size(max = 100, message = "Location cannot exceed 100 characters")
    private String location;

    @Size(max = 120, message = "Contact info cannot exceed 120 characters")
    private String contactInfo;

    @Size(max = 255, message = "Image URL cannot exceed 255 characters")
    private String imageUrl;
}

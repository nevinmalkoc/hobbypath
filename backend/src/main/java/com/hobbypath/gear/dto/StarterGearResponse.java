package com.hobbypath.gear.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StarterGearResponse {
    private Long id;
    private Long hobbyId;
    private String hobbyName;
    private String name;
    private String icon;
    private boolean mandatory;
    private String estimatedBudget;
    private String advice;
    private int priorityOrder;
}

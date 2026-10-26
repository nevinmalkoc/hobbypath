package com.hobbypath.gear.entity;

import com.hobbypath.hobby.entity.Hobby;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "starter_gears")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StarterGear {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "hobby_id", nullable = false)
    private Hobby hobby;

    @Column(nullable = false, length = 120)
    private String name;

    @Column(length = 20)
    private String icon;

    @Column(nullable = false)
    private boolean mandatory;

    @Column(length = 80)
    private String estimatedBudget;

    @Column(columnDefinition = "TEXT")
    private String advice;

    @Column(nullable = false)
    @Builder.Default
    private int priorityOrder = 0;
}

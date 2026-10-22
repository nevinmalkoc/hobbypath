package com.hobbypath.hobby.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "hobbies")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Hobby {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 100)
    private String name;

    @Column(nullable = false, length = 50)
    private String category;

    @Column(length = 100)
    private String icon;

    @Column(columnDefinition = "TEXT")
    private String description;
}

# HobbyPath — Veritabanı Mimarisi (Database Design) 🗄️

Bu doküman HobbyPath MVP sürümü için ilişkisel veri modelini, tablo detaylarını, veri tiplerini ve kısıtları (constraints) içerir.

---

## 1. Varlık İlişki Diyagramı (ER Diagram)

```mermaid
erDiagram
    USERS ||--o{ USER_ROLES : has
    ROLES ||--o{ USER_ROLES : assigned_to

    USERS ||--o{ USER_HOBBIES : has
    HOBBIES ||--o{ USER_HOBBIES : belongs_to

    HOBBIES ||--o{ COMMUNITIES : categorizes
    USERS ||--o{ COMMUNITIES : creates

    USERS ||--o{ COMMUNITY_MEMBERS : joins
    COMMUNITIES ||--o{ COMMUNITY_MEMBERS : includes

    COMMUNITIES ||--o{ POSTS : contains
    USERS ||--o{ POSTS : writes

    COMMUNITIES ||--o{ EVENTS : hosts
    USERS ||--o{ EVENTS : organizes
    USERS ||--o{ EVENT_PARTICIPANTS : attends
    EVENTS ||--o{ EVENT_PARTICIPANTS : has_attendees

    USERS {
        bigint id PK
        string email UK "Unique"
        string username UK "Unique"
        string password_hash
        string full_name
        string bio
        string location "City / District"
        timestamp created_at
    }

    HOBBIES {
        bigint id PK
        string name UK "Binicilik, Kitap..."
        string category "Spor, Sanat, Outdoor..."
        string icon_url
    }

    USER_HOBBIES {
        bigint id PK
        bigint user_id FK
        bigint hobby_id FK
        string skill_level "BEGINNER, INTERMEDIATE, ADVANCED"
    }

    COMMUNITIES {
        bigint id PK
        string name
        string description
        bigint hobby_id FK
        bigint creator_id FK
        integer member_count
        timestamp created_at
    }

    COMMUNITY_MEMBERS {
        bigint id PK
        bigint community_id FK
        bigint user_id FK
        string role "ADMIN, MEMBER"
        timestamp joined_at
    }

    POSTS {
        bigint id PK
        string title
        text content
        bigint author_id FK
        bigint community_id FK
        timestamp created_at
    }

    EVENTS {
        bigint id PK
        string title
        text description
        bigint community_id FK
        bigint organizer_id FK
        string location "Polonezköy Tabiat Parkı"
        timestamp event_date
        integer capacity
        string status "UPCOMING, COMPLETED, CANCELLED"
    }

    EVENT_PARTICIPANTS {
        bigint id PK
        bigint event_id FK
        bigint user_id FK
        string status "REGISTERED, CANCELLED"
        timestamp joined_at
    }
```

---

## 2. Tablo Tanımları ve Kısıtlar (Constraints)

### `users`
- `id`: BIGSERIAL / BIGINT PRIMARY KEY
- `email`: VARCHAR(255) NOT NULL UNIQUE
- `username`: VARCHAR(50) NOT NULL UNIQUE
- `password_hash`: VARCHAR(255) NOT NULL (BCrypt hash)
- `full_name`: VARCHAR(100) NOT NULL
- `bio`: TEXT NULL
- `location`: VARCHAR(100) NULL (Örn: "Kadıköy, İstanbul")
- `created_at`: TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP

### `roles` & `user_roles`
- `roles`: `id`, `name` (ROLE_USER, ROLE_ADMIN)
- `user_roles`: `user_id`, `role_id` (Composite PK veya Surrogate PK + Unique Constraint)

### `hobbies`
- `id`: BIGSERIAL PRIMARY KEY
- `name`: VARCHAR(100) NOT NULL UNIQUE (Örn: "Horse Riding", "Reading", "Ceramics")
- `category`: VARCHAR(50) NOT NULL (Örn: "Sports", "Arts", "Literature")
- `icon_url`: VARCHAR(255) NULL

### `user_hobbies`
- `id`: BIGSERIAL PRIMARY KEY
- `user_id`: BIGINT REFERENCES users(id) ON DELETE CASCADE
- `hobby_id`: BIGINT REFERENCES hobbies(id) ON DELETE CASCADE
- `skill_level`: VARCHAR(20) NOT NULL (CHECK: 'BEGINNER', 'INTERMEDIATE', 'ADVANCED')
- **Constraint:** `UNIQUE(user_id, hobby_id)` -> Bir kullanıcı aynı hobiyi iki kez ekleyemez.

### `communities`
- `id`: BIGSERIAL PRIMARY KEY
- `name`: VARCHAR(150) NOT NULL
- `description`: TEXT NULL
- `hobby_id`: BIGINT REFERENCES hobbies(id) ON DELETE RESTRICT
- `creator_id`: BIGINT REFERENCES users(id) ON DELETE SET NULL
- `member_count`: INTEGER DEFAULT 1
- `created_at`: TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP

### `community_members`
- `id`: BIGSERIAL PRIMARY KEY
- `community_id`: BIGINT REFERENCES communities(id) ON DELETE CASCADE
- `user_id`: BIGINT REFERENCES users(id) ON DELETE CASCADE
- `role`: VARCHAR(20) DEFAULT 'MEMBER' (CHECK: 'ADMIN', 'MODERATOR', 'MEMBER')
- `joined_at`: TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
- **Constraint:** `UNIQUE(community_id, user_id)`

### `posts`
- `id`: BIGSERIAL PRIMARY KEY
- `title`: VARCHAR(200) NOT NULL
- `content`: TEXT NOT NULL
- `author_id`: BIGINT REFERENCES users(id) ON DELETE CASCADE
- `community_id`: BIGINT REFERENCES communities(id) ON DELETE CASCADE
- `created_at`: TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP

### `events`
- `id`: BIGSERIAL PRIMARY KEY
- `title`: VARCHAR(200) NOT NULL
- `description`: TEXT NULL
- `community_id`: BIGINT REFERENCES communities(id) ON DELETE CASCADE
- `organizer_id`: BIGINT REFERENCES users(id) ON DELETE SET NULL
- `location`: VARCHAR(255) NOT NULL
- `event_date`: TIMESTAMP WITH TIME ZONE NOT NULL
- `capacity`: INTEGER NOT NULL CHECK (capacity > 0)
- `status`: VARCHAR(20) DEFAULT 'UPCOMING' (CHECK: 'UPCOMING', 'COMPLETED', 'CANCELLED')
- `created_at`: TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP

### `event_participants`
- `id`: BIGSERIAL PRIMARY KEY
- `event_id`: BIGINT REFERENCES events(id) ON DELETE CASCADE
- `user_id`: BIGINT REFERENCES users(id) ON DELETE CASCADE
- `status`: VARCHAR(20) DEFAULT 'REGISTERED' (CHECK: 'REGISTERED', 'CANCELLED', 'WAITLIST')
- `joined_at`: TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
- **Constraint:** `UNIQUE(event_id, user_id)`

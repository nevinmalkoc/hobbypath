class HobbyModel {
  final int id;
  final String name;
  final String category;
  final String icon;
  final String description;

  HobbyModel({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    required this.description,
  });

  factory HobbyModel.fromJson(Map<String, dynamic> json) {
    return HobbyModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      icon: json['icon'] as String? ?? '🎯',
      description: json['description'] as String? ?? '',
    );
  }
}

class UserHobbyModel {
  final int id;
  final int hobbyId;
  final String hobbyName;
  final String category;
  final String icon;
  final String skillLevel;

  UserHobbyModel({
    required this.id,
    required this.hobbyId,
    required this.hobbyName,
    required this.category,
    required this.icon,
    required this.skillLevel,
  });

  factory UserHobbyModel.fromJson(Map<String, dynamic> json) {
    return UserHobbyModel(
      id: json['id'] as int,
      hobbyId: json['hobbyId'] as int,
      hobbyName: json['hobbyName'] as String? ?? '',
      category: json['category'] as String? ?? '',
      icon: json['icon'] as String? ?? '🎯',
      skillLevel: json['skillLevel'] as String? ?? 'BEGINNER',
    );
  }
}

class UserModel {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final String bio;
  final String location;
  final String role;
  final List<UserHobbyModel> hobbies;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.bio,
    required this.location,
    required this.role,
    required this.hobbies,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final hobbyList = (json['hobbies'] as List<dynamic>?)
            ?.map((e) => UserHobbyModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return UserModel(
      id: json['id'] as int,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      location: json['location'] as String? ?? '',
      role: json['role'] as String? ?? 'ROLE_USER',
      hobbies: hobbyList,
    );
  }
}

class CommunityModel {
  final int id;
  final String name;
  final String description;
  final int hobbyId;
  final String hobbyName;
  final String hobbyIcon;
  final String creatorUsername;
  final int memberCount;
  final bool isMember;

  CommunityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.hobbyId,
    required this.hobbyName,
    required this.hobbyIcon,
    required this.creatorUsername,
    required this.memberCount,
    required this.isMember,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      hobbyId: json['hobbyId'] as int? ?? 0,
      hobbyName: json['hobbyName'] as String? ?? '',
      hobbyIcon: json['hobbyIcon'] as String? ?? '👥',
      creatorUsername: json['creatorUsername'] as String? ?? '',
      memberCount: json['memberCount'] as int? ?? 1,
      isMember: json['member'] as bool? ?? false,
    );
  }
}

class PostModel {
  final int id;
  final String title;
  final String content;
  final int authorId;
  final String authorUsername;
  final String authorFullName;
  final int communityId;
  final String communityName;
  final String createdAt;

  PostModel({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorUsername,
    required this.authorFullName,
    required this.communityId,
    required this.communityName,
    required this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      authorId: json['authorId'] as int? ?? 0,
      authorUsername: json['authorUsername'] as String? ?? '',
      authorFullName: json['authorFullName'] as String? ?? '',
      communityId: json['communityId'] as int? ?? 0,
      communityName: json['communityName'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}

class EventModel {
  final int id;
  final String title;
  final String description;
  final int communityId;
  final String communityName;
  final String hobbyName;
  final String hobbyIcon;
  final String organizerUsername;
  final String location;
  final String eventDate;
  final int capacity;
  final int currentParticipants;
  final String? userStatus;
  final String status;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.communityId,
    required this.communityName,
    required this.hobbyName,
    required this.hobbyIcon,
    required this.organizerUsername,
    required this.location,
    required this.eventDate,
    required this.capacity,
    required this.currentParticipants,
    this.userStatus,
    required this.status,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      communityId: json['communityId'] as int? ?? 0,
      communityName: json['communityName'] as String? ?? '',
      hobbyName: json['hobbyName'] as String? ?? '',
      hobbyIcon: json['hobbyIcon'] as String? ?? '📅',
      organizerUsername: json['organizerUsername'] as String? ?? '',
      location: json['location'] as String? ?? '',
      eventDate: json['eventDate'] as String? ?? '',
      capacity: json['capacity'] as int? ?? 0,
      currentParticipants: json['currentParticipants'] as int? ?? 0,
      userStatus: json['userStatus'] as String?,
      status: json['status'] as String? ?? 'UPCOMING',
    );
  }
}

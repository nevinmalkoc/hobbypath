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
  final String avatar;
  final String role;
  final List<UserHobbyModel> hobbies;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.bio,
    required this.location,
    required this.avatar,
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
      avatar: json['avatar'] as String? ?? '🏇',
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
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? district;
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
    this.latitude,
    this.longitude,
    this.city,
    this.district,
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
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      city: json['city'] as String?,
      district: json['district'] as String?,
      eventDate: json['eventDate'] as String? ?? '',
      capacity: json['capacity'] as int? ?? 0,
      currentParticipants: json['currentParticipants'] as int? ?? 0,
      userStatus: json['userStatus'] as String?,
      status: json['status'] as String? ?? 'UPCOMING',
    );
  }
}

class ChatMessageModel {
  final int id;
  final int senderId;
  final String senderUsername;
  final String senderFullName;
  final int? communityId;
  final String content;
  final String type;
  final String sentAt;

  ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.senderUsername,
    required this.senderFullName,
    this.communityId,
    required this.content,
    required this.type,
    required this.sentAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as int,
      senderId: json['senderId'] as int,
      senderUsername: json['senderUsername'] as String? ?? 'Anonim',
      senderFullName: json['senderFullName'] as String? ?? '',
      communityId: json['communityId'] as int?,
      content: json['content'] as String? ?? '',
      type: json['type'] as String? ?? 'CHAT',
      sentAt: json['sentAt'] as String? ?? '',
    );
  }
}

class EventReservationModel {
  final int eventId;
  final int userId;
  final String status;
  final int remainingSeconds;
  final String? expiresAt;
  final String message;

  EventReservationModel({
    required this.eventId,
    required this.userId,
    required this.status,
    required this.remainingSeconds,
    this.expiresAt,
    required this.message,
  });

  factory EventReservationModel.fromJson(Map<String, dynamic> json) {
    return EventReservationModel(
      eventId: json['eventId'] as int,
      userId: json['userId'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      remainingSeconds: json['remainingSeconds'] as int? ?? 0,
      expiresAt: json['expiresAt'] as String?,
      message: json['message'] as String? ?? '',
    );
  }
}

class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String type;
  final int? referenceId;
  final bool read;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.referenceId,
    required this.read,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? 'SYSTEM',
      referenceId: json['referenceId'] as int?,
      read: json['read'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}

class DailyPuzzleModel {
  final int id;
  final String puzzleDate;
  final String hobbyName;
  final String hobbyIcon;
  final String title;
  final String clue;
  final int answerLength;
  final String scrambledLetters;
  final bool alreadySolved;
  final int? myCompletionTimeSeconds;

  DailyPuzzleModel({
    required this.id,
    required this.puzzleDate,
    required this.hobbyName,
    required this.hobbyIcon,
    required this.title,
    required this.clue,
    required this.answerLength,
    required this.scrambledLetters,
    required this.alreadySolved,
    this.myCompletionTimeSeconds,
  });

  factory DailyPuzzleModel.fromJson(Map<String, dynamic> json) {
    return DailyPuzzleModel(
      id: json['id'] as int,
      puzzleDate: json['puzzleDate'] as String? ?? '',
      hobbyName: json['hobbyName'] as String? ?? 'Hobi',
      hobbyIcon: json['hobbyIcon'] as String? ?? '🧩',
      title: json['title'] as String? ?? '',
      clue: json['clue'] as String? ?? '',
      answerLength: json['answerLength'] as int? ?? 5,
      scrambledLetters: json['scrambledLetters'] as String? ?? '',
      alreadySolved: json['alreadySolved'] as bool? ?? false,
      myCompletionTimeSeconds: json['myCompletionTimeSeconds'] as int?,
    );
  }
}

class LeaderboardEntryModel {
  final int rank;
  final int userId;
  final String username;
  final String fullName;
  final int completionTimeSeconds;
  final String solvedAt;

  LeaderboardEntryModel({
    required this.rank,
    required this.userId,
    required this.username,
    required this.fullName,
    required this.completionTimeSeconds,
    required this.solvedAt,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryModel(
      rank: json['rank'] as int? ?? 1,
      userId: json['userId'] as int? ?? 0,
      username: json['username'] as String? ?? 'Kullanıcı',
      fullName: json['fullName'] as String? ?? '',
      completionTimeSeconds: json['completionTimeSeconds'] as int? ?? 0,
      solvedAt: json['solvedAt'] as String? ?? '',
    );
  }
}

class StarterGearModel {
  final int id;
  final int hobbyId;
  final String hobbyName;
  final String name;
  final String icon;
  final bool mandatory;
  final String estimatedBudget;
  final String advice;
  final int priorityOrder;

  StarterGearModel({
    required this.id,
    required this.hobbyId,
    required this.hobbyName,
    required this.name,
    required this.icon,
    required this.mandatory,
    required this.estimatedBudget,
    required this.advice,
    required this.priorityOrder,
  });

  factory StarterGearModel.fromJson(Map<String, dynamic> json) {
    return StarterGearModel(
      id: json['id'] as int,
      hobbyId: json['hobbyId'] as int? ?? 0,
      hobbyName: json['hobbyName'] as String? ?? '',
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String? ?? '🎒',
      mandatory: json['mandatory'] as bool? ?? false,
      estimatedBudget: json['estimatedBudget'] as String? ?? '',
      advice: json['advice'] as String? ?? '',
      priorityOrder: json['priorityOrder'] as int? ?? 0,
    );
  }
}

class GearTransferModel {
  final int id;
  final int ownerId;
  final String ownerUsername;
  final String ownerFullName;
  final String? ownerAvatar;
  final int hobbyId;
  final String hobbyName;
  final String hobbyIcon;
  final String title;
  final String description;
  final String transferType;
  final String itemCondition;
  final String location;
  final String contactInfo;
  final String? imageUrl;
  final String status;
  final String createdAt;

  GearTransferModel({
    required this.id,
    required this.ownerId,
    required this.ownerUsername,
    required this.ownerFullName,
    this.ownerAvatar,
    required this.hobbyId,
    required this.hobbyName,
    required this.hobbyIcon,
    required this.title,
    required this.description,
    required this.transferType,
    required this.itemCondition,
    required this.location,
    required this.contactInfo,
    this.imageUrl,
    required this.status,
    required this.createdAt,
  });

  factory GearTransferModel.fromJson(Map<String, dynamic> json) {
    return GearTransferModel(
      id: json['id'] as int,
      ownerId: json['ownerId'] as int? ?? 0,
      ownerUsername: json['ownerUsername'] as String? ?? 'Kullanıcı',
      ownerFullName: json['ownerFullName'] as String? ?? '',
      ownerAvatar: json['ownerAvatar'] as String?,
      hobbyId: json['hobbyId'] as int? ?? 0,
      hobbyName: json['hobbyName'] as String? ?? '',
      hobbyIcon: json['hobbyIcon'] as String? ?? '🎒',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      transferType: json['transferType'] as String? ?? 'GIFT',
      itemCondition: json['itemCondition'] as String? ?? 'İyi',
      location: json['location'] as String? ?? '',
      contactInfo: json['contactInfo'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      status: json['status'] as String? ?? 'AVAILABLE',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}


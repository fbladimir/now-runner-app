class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? photoURL;
  final String? role; // 'requester' or 'runner'
  final bool isAvailable; // for runners
  final double rating;
  final int completedJobs;
  final DateTime createdAt;
  final DateTime lastActive;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoURL,
    this.role,
    this.isAvailable = false,
    this.rating = 0.0,
    this.completedJobs = 0,
    required this.createdAt,
    required this.lastActive,
    this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? map['name'] ?? 'User', // Try both displayName and name, fallback to 'User'
      photoURL: map['photoURL'],
      role: map['role'],
      isAvailable: map['isAvailable'] ?? false,
      rating: (map['rating'] ?? 0.0).toDouble(),
      completedJobs: map['completedJobs'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
      lastActive: DateTime.parse(map['lastActive']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'role': role,
      'isAvailable': isAvailable,
      'rating': rating,
      'completedJobs': completedJobs,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    String? role,
    bool? isAvailable,
    double? rating,
    int? completedJobs,
    DateTime? createdAt,
    DateTime? lastActive,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      role: role ?? this.role,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      completedJobs: completedJobs ?? this.completedJobs,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 
import 'package:flutter/material.dart';

enum JobStatus {
  pending,
  accepted,
  inProgress,
  completed,
  cancelled,
}

enum JobUrgency {
  low,
  medium,
  high,
}

class JobModel {
  final String id;
  final String requesterId;
  final String? runnerId;
  final String title;
  final String description;
  final String category;
  final String location;
  final double budget;
  final double? distance;
  final JobStatus status;
  final JobUrgency urgency;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final Map<String, dynamic>? metadata;

  JobModel({
    required this.id,
    required this.requesterId,
    this.runnerId,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.budget,
    this.distance,
    this.status = JobStatus.pending,
    this.urgency = JobUrgency.medium,
    required this.createdAt,
    this.acceptedAt,
    this.completedAt,
    this.metadata,
  });

  factory JobModel.fromMap(Map<String, dynamic> map) {
    return JobModel(
      id: map['id'] ?? '',
      requesterId: map['requesterId'] ?? '',
      runnerId: map['runnerId'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      location: map['location'] ?? '',
      budget: (map['budget'] ?? 0.0).toDouble(),
      distance: map['distance'] != null ? (map['distance'] as num).toDouble() : null,
      status: JobStatus.values.firstWhere(
        (e) => e.toString() == 'JobStatus.${map['status']}',
        orElse: () => JobStatus.pending,
      ),
      urgency: JobUrgency.values.firstWhere(
        (e) => e.toString() == 'JobUrgency.${map['urgency']}',
        orElse: () => JobUrgency.medium,
      ),
      createdAt: DateTime.parse(map['createdAt']),
      acceptedAt: map['acceptedAt'] != null ? DateTime.parse(map['acceptedAt']) : null,
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null,
      metadata: map['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'requesterId': requesterId,
      'runnerId': runnerId,
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'budget': budget,
      'distance': distance,
      'status': status.toString().split('.').last,
      'urgency': urgency.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  JobModel copyWith({
    String? id,
    String? requesterId,
    String? runnerId,
    String? title,
    String? description,
    String? category,
    String? location,
    double? budget,
    double? distance,
    JobStatus? status,
    JobUrgency? urgency,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? completedAt,
    Map<String, dynamic>? metadata,
  }) {
    return JobModel(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      runnerId: runnerId ?? this.runnerId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      location: location ?? this.location,
      budget: budget ?? this.budget,
      distance: distance ?? this.distance,
      status: status ?? this.status,
      urgency: urgency ?? this.urgency,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  String get statusText {
    switch (status) {
      case JobStatus.pending:
        return 'Pending';
      case JobStatus.accepted:
        return 'Accepted';
      case JobStatus.inProgress:
        return 'In Progress';
      case JobStatus.completed:
        return 'Completed';
      case JobStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get urgencyText {
    switch (urgency) {
      case JobUrgency.low:
        return 'Low';
      case JobUrgency.medium:
        return 'Medium';
      case JobUrgency.high:
        return 'High';
    }
  }

  Color get urgencyColor {
    switch (urgency) {
      case JobUrgency.low:
        return Colors.green;
      case JobUrgency.medium:
        return Colors.orange;
      case JobUrgency.high:
        return Colors.red;
    }
  }

  Color get statusColor {
    switch (status) {
      case JobStatus.pending:
        return Colors.grey;
      case JobStatus.accepted:
        return Colors.blue;
      case JobStatus.inProgress:
        return Colors.orange;
      case JobStatus.completed:
        return Colors.green;
      case JobStatus.cancelled:
        return Colors.red;
    }
  }
} 
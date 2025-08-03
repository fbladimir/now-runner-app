import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/job_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User operations
  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  Future<UserModel?> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  Future<String?> getUserRole(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data()?['role'];
      }
      return null;
    } catch (e) {
      print('Error getting user role: $e');
      return null;
    }
  }

  Future<void> updateUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).update(user.toMap());
  }

  Future<void> updateUserRole(String userId, String role) async {
    try {
      // First, check if the user document exists
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        // Create the user document if it doesn't exist
        await _firestore.collection('users').doc(userId).set({
          'id': userId,
          'role': role,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
          'isAvailable': false,
          'rating': 0.0,
          'completedJobs': 0,
          'lastActive': DateTime.now().toIso8601String(),
        });
      } else {
        // Update existing user document
        await _firestore.collection('users').doc(userId).update({
          'role': role,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('Error updating user role: $e');
      throw Exception('Failed to save user role: $e');
    }
  }

  Future<void> switchUserRole(String userId, String newRole) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': newRole,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error switching user role: $e');
      throw Exception('Failed to switch user role: $e');
    }
  }

  Future<void> updateRequesterInfo({
    required String userId,
    required String name,
    required String zipCode,
    required String contactMethod,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'name': name,
        'zipCode': zipCode,
        'contactMethod': contactMethod,
        'onboardingCompleted': true,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error updating requester info: $e');
      throw Exception('Failed to save requester info: $e');
    }
  }

  Future<void> updateRunnerInfo({
    required String userId,
    required String name,
    required String zipCode,
    required List<String> availability,
    String? bio,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'name': name,
        'zipCode': zipCode,
        'availability': availability,
        'bio': bio ?? '',
        'onboardingCompleted': true,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error updating runner info: $e');
      throw Exception('Failed to save runner info: $e');
    }
  }

  Future<void> updateUserAvailability(String userId, bool isAvailable) async {
    await _firestore.collection('users').doc(userId).update({
      'isAvailable': isAvailable,
      'lastActive': DateTime.now().toIso8601String(),
    });
  }

  // Job operations
  Future<String> createJob(JobModel job) async {
    final docRef = await _firestore.collection('jobs').add(job.toMap());
    return docRef.id;
  }

  Future<List<JobModel>> getAvailableJobs() async {
    final querySnapshot = await _firestore
        .collection('jobs')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => JobModel.fromMap({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
        .toList();
  }

  Future<List<JobModel>> getUserJobs(String userId, {String? userType}) async {
    Query query = _firestore.collection('jobs');
    
    if (userType == 'requester') {
      query = query.where('requesterId', isEqualTo: userId);
    } else if (userType == 'runner') {
      query = query.where('runnerId', isEqualTo: userId);
    }
    
    query = query.orderBy('createdAt', descending: true);
    
    final querySnapshot = await query.get();
    
    return querySnapshot.docs
        .map((doc) => JobModel.fromMap({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
        .toList();
  }

  Future<void> updateJobStatus(String jobId, JobStatus status) async {
    final updateData = {
      'status': status.toString().split('.').last,
    };

    if (status == JobStatus.accepted) {
      updateData['acceptedAt'] = DateTime.now().toIso8601String();
    } else if (status == JobStatus.completed) {
      updateData['completedAt'] = DateTime.now().toIso8601String();
    }

    await _firestore.collection('jobs').doc(jobId).update(updateData);
  }

  Future<void> assignRunnerToJob(String jobId, String runnerId) async {
    await _firestore.collection('jobs').doc(jobId).update({
      'runnerId': runnerId,
      'status': 'accepted',
      'acceptedAt': DateTime.now().toIso8601String(),
    });
  }

  // Real-time listeners
  Stream<List<JobModel>> watchAvailableJobs() {
    return _firestore
        .collection('jobs')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => JobModel.fromMap({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
            .toList());
  }

  Stream<List<JobModel>> watchUserJobs(String userId, {String? userType}) {
    Query query = _firestore.collection('jobs');
    
    if (userType == 'requester') {
      query = query.where('requesterId', isEqualTo: userId);
    } else if (userType == 'runner') {
      query = query.where('runnerId', isEqualTo: userId);
    }
    
    query = query.orderBy('createdAt', descending: true);
    
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => JobModel.fromMap({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
        .toList());
  }

  // Search and filter operations
  Future<List<JobModel>> searchJobs({
    String? category,
    double? minBudget,
    double? maxBudget,
    JobUrgency? urgency,
  }) async {
    Query query = _firestore.collection('jobs').where('status', isEqualTo: 'pending');

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    if (minBudget != null) {
      query = query.where('budget', isGreaterThanOrEqualTo: minBudget);
    }

    if (maxBudget != null) {
      query = query.where('budget', isLessThanOrEqualTo: maxBudget);
    }

    if (urgency != null) {
      query = query.where('urgency', isEqualTo: urgency.toString().split('.').last);
    }

    query = query.orderBy('createdAt', descending: true);

    final querySnapshot = await query.get();
    
    return querySnapshot.docs
        .map((doc) => JobModel.fromMap({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
        .toList();
  }

  // Analytics and statistics
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    final jobsQuery = await _firestore
        .collection('jobs')
        .where('requesterId', isEqualTo: userId)
        .get();

    final completedJobs = jobsQuery.docs
        .where((doc) => doc.data()['status'] == 'completed')
        .length;

    final totalSpent = jobsQuery.docs
        .where((doc) => doc.data()['status'] == 'completed')
        .fold<double>(0, (sum, doc) => sum + (doc.data()['budget'] ?? 0));

    return {
      'completedJobs': completedJobs,
      'totalSpent': totalSpent,
      'totalJobs': jobsQuery.docs.length,
    };
  }

  Future<Map<String, dynamic>> getRunnerStats(String runnerId) async {
    final jobsQuery = await _firestore
        .collection('jobs')
        .where('runnerId', isEqualTo: runnerId)
        .get();

    final completedJobs = jobsQuery.docs
        .where((doc) => doc.data()['status'] == 'completed')
        .length;

    final totalEarned = jobsQuery.docs
        .where((doc) => doc.data()['status'] == 'completed')
        .fold<double>(0, (sum, doc) => sum + (doc.data()['budget'] ?? 0));

    return {
      'completedJobs': completedJobs,
      'totalEarned': totalEarned,
      'totalJobs': jobsQuery.docs.length,
    };
  }
} 
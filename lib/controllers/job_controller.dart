import 'package:flutter/foundation.dart';
import '../models/job_model.dart';
import '../services/firestore_service.dart';

class JobController extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<JobModel> _availableJobs = [];
  List<JobModel> _userJobs = [];
  bool _isLoading = false;
  String? _error;

  List<JobModel> get availableJobs => _availableJobs;
  List<JobModel> get userJobs => _userJobs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAvailableJobs() async {
    _setLoading(true);
    try {
      _availableJobs = await _firestoreService.getAvailableJobs();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadUserJobs(String userId, {String? userType}) async {
    _setLoading(true);
    try {
      _userJobs = await _firestoreService.getUserJobs(userId, userType: userType);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createJob(JobModel job) async {
    _setLoading(true);
    try {
      await _firestoreService.createJob(job);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> acceptJob(String jobId, String runnerId) async {
    _setLoading(true);
    try {
      await _firestoreService.assignRunnerToJob(jobId, runnerId);
      await loadAvailableJobs(); // Refresh the list
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateJobStatus(String jobId, JobStatus status) async {
    _setLoading(true);
    try {
      await _firestoreService.updateJobStatus(jobId, status);
      await loadAvailableJobs(); // Refresh the list
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<List<JobModel>> searchJobs({
    String? category,
    double? minBudget,
    double? maxBudget,
    JobUrgency? urgency,
  }) async {
    try {
      return await _firestoreService.searchJobs(
        category: category,
        minBudget: minBudget,
        maxBudget: maxBudget,
        urgency: urgency,
      );
    } catch (e) {
      _error = e.toString();
      return [];
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearJobs() {
    _availableJobs.clear();
    _userJobs.clear();
    notifyListeners();
  }
} 
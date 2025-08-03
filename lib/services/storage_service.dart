import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Upload profile image
  Future<String> uploadProfileImage(String userId, File imageFile) async {
    final ref = _storage.ref().child('profile_images/$userId.jpg');
    final uploadTask = ref.putFile(imageFile);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // Upload profile image from bytes
  Future<String> uploadProfileImageFromBytes(String userId, Uint8List imageBytes) async {
    final ref = _storage.ref().child('profile_images/$userId.jpg');
    final uploadTask = ref.putData(imageBytes);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // Upload job-related images
  Future<String> uploadJobImage(String jobId, File imageFile, {String? imageType}) async {
    final fileName = imageType != null ? '${imageType}_$jobId.jpg' : 'job_$jobId.jpg';
    final ref = _storage.ref().child('job_images/$fileName');
    final uploadTask = ref.putFile(imageFile);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // Upload job image from bytes
  Future<String> uploadJobImageFromBytes(String jobId, Uint8List imageBytes, {String? imageType}) async {
    final fileName = imageType != null ? '${imageType}_$jobId.jpg' : 'job_$jobId.jpg';
    final ref = _storage.ref().child('job_images/$fileName');
    final uploadTask = ref.putData(imageBytes);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // Upload multiple job images
  Future<List<String>> uploadJobImages(String jobId, List<File> imageFiles) async {
    final List<String> urls = [];
    
    for (int i = 0; i < imageFiles.length; i++) {
      final fileName = 'job_${jobId}_$i.jpg';
      final ref = _storage.ref().child('job_images/$fileName');
      final uploadTask = ref.putFile(imageFiles[i]);
      final snapshot = await uploadTask;
      final url = await snapshot.ref.getDownloadURL();
      urls.add(url);
    }
    
    return urls;
  }

  // Upload document
  Future<String> uploadDocument(String userId, File documentFile, String documentType) async {
    final fileName = '${documentType}_$userId.pdf';
    final ref = _storage.ref().child('documents/$fileName');
    final uploadTask = ref.putFile(documentFile);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    
    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  // Pick image from camera
  Future<File?> pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    
    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  // Pick multiple images
  Future<List<File>> pickMultipleImages() async {
    final List<XFile> images = await _picker.pickMultiImage(
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    
    return images.map((image) => File(image.path)).toList();
  }

  // Delete file
  Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      // File might not exist or other error
      print('Error deleting file: $e');
    }
  }

  // Get file metadata
  Future<Map<String, dynamic>?> getFileMetadata(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      final metadata = await ref.getMetadata();
      return {
        'name': metadata.name,
        'size': metadata.size,
        'contentType': metadata.contentType,
        'timeCreated': metadata.timeCreated,
        'updated': metadata.updated,
      };
    } catch (e) {
      print('Error getting file metadata: $e');
      return null;
    }
  }

  // Download file
  Future<Uint8List?> downloadFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      final data = await ref.getData();
      return data;
    } catch (e) {
      print('Error downloading file: $e');
      return null;
    }
  }

  // Get download URL
  Future<String?> getDownloadURL(String filePath) async {
    try {
      final ref = _storage.ref().child(filePath);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error getting download URL: $e');
      return null;
    }
  }

  // List files in a folder
  Future<List<String>> listFiles(String folderPath) async {
    try {
      final ref = _storage.ref().child(folderPath);
      final result = await ref.listAll();
      final urls = <String>[];
      
      for (final item in result.items) {
        final url = await item.getDownloadURL();
        urls.add(url);
      }
      
      return urls;
    } catch (e) {
      print('Error listing files: $e');
      return [];
    }
  }

  // Upload with progress tracking
  Future<String> uploadWithProgress(
    String path,
    File file, {
    Function(double)? onProgress,
  }) async {
    final ref = _storage.ref().child(path);
    final uploadTask = ref.putFile(file);
    
    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      final progress = snapshot.bytesTransferred / snapshot.totalBytes;
      onProgress?.call(progress);
    });
    
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // Upload data with progress tracking
  Future<String> uploadDataWithProgress(
    String path,
    Uint8List data, {
    Function(double)? onProgress,
  }) async {
    final ref = _storage.ref().child(path);
    final uploadTask = ref.putData(data);
    
    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      final progress = snapshot.bytesTransferred / snapshot.totalBytes;
      onProgress?.call(progress);
    });
    
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
} 
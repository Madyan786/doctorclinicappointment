import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;

class CloudinaryService extends GetxService {
  late CloudinaryPublic _cloudinary;
  
  // Cloudinary credentials
  static const String _cloudName = 'dz0ug5gey';
  static const String _uploadPreset = 'doctor_clinic_preset';

  @override
  void onInit() {
    super.onInit();
    _initCloudinary();
  }

  void _initCloudinary() {
    try {
      _cloudinary = CloudinaryPublic(_cloudName, _uploadPreset, cache: false);
      developer.log('✅ Cloudinary initialized', name: 'CloudinaryService');
    } catch (e) {
      developer.log('❌ Cloudinary init failed: $e', name: 'CloudinaryService');
    }
  }

  /// Upload image to Cloudinary
  /// Returns the secure URL of the uploaded image
  Future<String> uploadImage(
    File imageFile, {
    required String folder,
    String? publicId,
  }) async {
    try {
      developer.log('📤 Uploading image to Cloudinary...', name: 'CloudinaryService');
      
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: folder,
          publicId: publicId,
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      final url = response.secureUrl;
      developer.log('✅ Image uploaded: $url', name: 'CloudinaryService');
      return url;
    } catch (e) {
      developer.log('❌ Upload failed: $e', name: 'CloudinaryService');
      Get.snackbar(
        'Upload Error',
        'Failed to upload image: $e',
        snackPosition: SnackPosition.TOP,
      );
      rethrow;
    }
  }

  /// Upload multiple images
  Future<List<String>> uploadMultipleImages(
    List<File> imageFiles, {
    required String folder,
  }) async {
    List<String> urls = [];
    
    for (int i = 0; i < imageFiles.length; i++) {
      try {
        final url = await uploadImage(
          imageFiles[i],
          folder: folder,
          publicId: '${DateTime.now().millisecondsSinceEpoch}_$i',
        );
        urls.add(url);
      } catch (e) {
        developer.log('❌ Failed to upload image $i: $e', name: 'CloudinaryService');
        // Continue with other images even if one fails
      }
    }
    
    return urls;
  }

  /// Delete image from Cloudinary by public ID
  /// Note: cloudinary_public package doesn't support deletion
  /// To delete images, use Cloudinary Dashboard or Admin API
  Future<void> deleteImage(String publicId) async {
    developer.log('⚠️ Image deletion not supported in cloudinary_public package', name: 'CloudinaryService');
    developer.log('ℹ️ Delete manually from: https://console.cloudinary.com/console/media_library', name: 'CloudinaryService');
  }

  /// Extract public ID from Cloudinary URL
  String? getPublicIdFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      
      // Find the upload index
      final uploadIndex = pathSegments.indexOf('upload');
      if (uploadIndex == -1 || uploadIndex >= pathSegments.length - 1) {
        return null;
      }
      
      // Get everything after version (v1234567890)
      final relevantParts = pathSegments.sublist(uploadIndex + 2);
      final publicId = relevantParts.join('/').split('.').first;
      
      return publicId;
    } catch (e) {
      developer.log('❌ Failed to extract public ID: $e', name: 'CloudinaryService');
      return null;
    }
  }
}

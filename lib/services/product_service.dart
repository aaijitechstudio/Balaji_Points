import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../core/logger.dart';
import 'session_service.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final SessionService _sessionService = SessionService();

  /// Upload product image to Firebase Storage
  Future<String?> uploadProductImage(File imageFile) async {
    try {
      final productImageId = _firestore.collection('products').doc().id;
      final ref = _storage.ref().child('product_images/$productImageId.jpg');

      AppLogger.info('Uploading product image: product_images/$productImageId.jpg');

      final uploadTask = await ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'productImageId': productImageId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final imageUrl = await uploadTask.ref.getDownloadURL();
      AppLogger.info('Product image uploaded: $imageUrl');
      return imageUrl;
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Firebase Storage error (product image)',
        'Code: ${e.code}, Message: ${e.message}',
      );
      if (e.code == 'storage/unauthorized') {
        throw Exception(
          'Storage access denied. Please check Firebase Storage rules.',
        );
      } else if (e.code == 'storage/canceled') {
        throw Exception('Upload was cancelled');
      } else if (e.code == 'storage/unknown') {
        throw Exception(
          'Firebase Storage is not configured. Please enable Storage in Firebase Console.',
        );
      }
      throw Exception('Failed to upload product image: ${e.message}');
    } catch (e) {
      AppLogger.error('Error uploading product image', e);
      throw Exception('Failed to upload product image: $e');
    }
  }

  Future<void> _deleteImageIfExists(String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) return;

    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      AppLogger.info('Deleted product image: $imageUrl');
    } catch (e) {
      AppLogger.error('Error deleting product image', e);
      // Don't throw - image deletion is not critical
    }
  }

  /// Create a new product
  Future<bool> createProduct({
    required String name,
    required String mainCategory,
    String? subCategory,
    required double price,
    String? description,
    String? size,
    String? thickness,
    String? quality,
    String? imageUrl,
    List<String>? imageUrls,
    bool isActive = true,
  }) async {
    try {
      AppLogger.info(
        'Creating product: $name in category: $mainCategory / $subCategory',
      );

      final productRef = _firestore.collection('products').doc();
      final productId = productRef.id;

      final adminPhone = await _sessionService.getPhoneNumber() ?? 'admin';
      final adminUserId = await _sessionService.getUserId() ?? 'admin';

      final allImageUrls = <String>[
        if (imageUrls != null) ...imageUrls,
        if (imageUrl != null && imageUrl.isNotEmpty) imageUrl,
      ];

      await productRef.set({
        'productId': productId,
        'name': name,
        // Backwards compatible: keep old "category" = mainCategory
        'category': mainCategory,
        'mainCategory': mainCategory,
        'subCategory': subCategory ?? '',
        'price': price,
        'description': description ?? '',
        'size': size ?? '',
        'thickness': thickness ?? '',
        'quality': quality ?? '',
        'imageUrl':
            (allImageUrls.isNotEmpty ? allImageUrls.first : (imageUrl ?? '')),
        'imageUrls': allImageUrls,
        'isActive': isActive,
        'createdBy': adminUserId,
        'createdByPhone': adminPhone,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      AppLogger.info('Product created successfully: $productId');
      return true;
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Firebase error creating product',
        'Code: ${e.code}, Message: ${e.message}',
      );
      return false;
    } catch (e) {
      AppLogger.error('Error creating product', e.toString());
      return false;
    }
  }

  /// Update an existing product
  Future<bool> updateProduct({
    required String productId,
    required String name,
    required String mainCategory,
    String? subCategory,
    double? price,
    String? description,
    String? size,
    String? thickness,
    String? quality,
    String? imageUrl,
    List<String>? imageUrls,
    bool? isActive,
    String? oldImageUrl,
  }) async {
    try {
      AppLogger.info(
        'Updating product: $productId to $mainCategory / $subCategory',
      );

      if (imageUrl != null &&
          oldImageUrl != null &&
          imageUrl.isNotEmpty &&
          imageUrl != oldImageUrl) {
        await _deleteImageIfExists(oldImageUrl);
      }

      final productRef = _firestore.collection('products').doc(productId);

      final adminPhone = await _sessionService.getPhoneNumber() ?? 'admin';
      final adminUserId = await _sessionService.getUserId() ?? 'admin';

      final updateData = <String, dynamic>{
        'name': name,
        'category': mainCategory,
        'mainCategory': mainCategory,
        'subCategory': subCategory ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': adminUserId,
        'updatedByPhone': adminPhone,
      };

      updateData['size'] = size ?? '';
      updateData['thickness'] = thickness ?? '';
      updateData['quality'] = quality ?? '';
      if (price != null) {
        updateData['price'] = price;
      }
      if (description != null) {
        updateData['description'] = description;
      }

      if (imageUrl != null) {
        updateData['imageUrl'] = imageUrl;
      }
      if (imageUrls != null) {
        updateData['imageUrls'] = imageUrls;
        if (imageUrls.isNotEmpty) {
          updateData['imageUrl'] = imageUrls.first;
        }
      }
      if (isActive != null) {
        updateData['isActive'] = isActive;
      }

      await productRef.update(updateData);

      AppLogger.info('Product updated successfully: $productId');
      return true;
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Firebase error updating product',
        'Code: ${e.code}, Message: ${e.message}',
      );
      return false;
    } catch (e) {
      AppLogger.error('Error updating product', e.toString());
      return false;
    }
  }

  /// Delete a product
  Future<bool> deleteProduct(String productId, String? imageUrl) async {
    try {
      AppLogger.info('Deleting product: $productId');

      await _deleteImageIfExists(imageUrl);
      await _firestore.collection('products').doc(productId).delete();

      AppLogger.info('Product deleted successfully: $productId');
      return true;
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Firebase error deleting product',
        'Code: ${e.code}, Message: ${e.message}',
      );
      return false;
    } catch (e) {
      AppLogger.error('Error deleting product', e.toString());
      return false;
    }
  }
}


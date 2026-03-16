import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:kuwentobuddy/models/user_model.dart';

/// Service for managing user data in Firestore
class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  /// Get or create user
  Future<UserModel> getOrCreateUser({
    required String uid,
    String? email,
    String? displayName,
    String? photoUrl,
  }) async {
    final doc = await _firestore.collection(_collection).doc(uid).get();

    if (doc.exists) {
      return UserModel.fromJson({...doc.data()!, 'id': uid});
    }

    final newUser = UserModel(
      id: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      isGuest: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _firestore.collection(_collection).doc(uid).set(newUser.toJson());
    return newUser;
  }

  /// Get user by ID
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      if (doc.exists) {
        return UserModel.fromJson({...doc.data()!, 'id': uid});
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }

  /// Update user
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection(_collection).doc(user.id).set({
        ...user.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating user: $e');
      rethrow;
    }
  }

  /// Update story progress
  Future<void> updateStoryProgress(
      String userId, StoryProgress progress) async {
    try {
      await _firestore.collection(_collection).doc(userId).set({
        'storyProgress.${progress.storyId}': progress.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating story progress: $e');
      rethrow;
    }
  }

  /// Add stars to user
  Future<void> addStars(String userId, int stars) async {
    try {
      await _firestore.collection(_collection).doc(userId).set({
        'totalStars': FieldValue.increment(stars),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error adding stars: $e');
      rethrow;
    }
  }

  /// Increment stories completed
  Future<void> incrementStoriesCompleted(String userId) async {
    try {
      await _firestore.collection(_collection).doc(userId).set({
        'storiesCompleted': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error incrementing stories completed: $e');
      rethrow;
    }
  }

  /// Toggle favorite story
  Future<void> toggleFavorite(
      String userId, String storyId, bool isFavorite) async {
    try {
      await _firestore.collection(_collection).doc(userId).set({
        'favoriteStoryIds': isFavorite
            ? FieldValue.arrayUnion([storyId])
            : FieldValue.arrayRemove([storyId]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      rethrow;
    }
  }

  /// Update user preferences
  Future<void> updatePreferences(
      String userId, UserPreferences preferences) async {
    try {
      await _firestore.collection(_collection).doc(userId).set({
        'preferences': preferences.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating preferences: $e');
      rethrow;
    }
  }

  /// Merge guest progress to authenticated user
  Future<void> mergeProgress({
    required String userId,
    required Map<String, StoryProgress> guestProgress,
    required int guestStars,
    required int guestStoriesCompleted,
    required List<String> guestFavorites,
  }) async {
    try {
      final userRef = _firestore.collection(_collection).doc(userId);
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Update each story progress
      for (final entry in guestProgress.entries) {
        updates['storyProgress.${entry.key}'] = entry.value.toJson();
      }

      // Add stars and completed stories
      if (guestStars > 0) {
        updates['totalStars'] = FieldValue.increment(guestStars);
      }
      if (guestStoriesCompleted > 0) {
        updates['storiesCompleted'] =
            FieldValue.increment(guestStoriesCompleted);
      }
      if (guestFavorites.isNotEmpty) {
        updates['favoriteStoryIds'] = FieldValue.arrayUnion(guestFavorites);
      }

      await userRef.set(updates, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error merging progress: $e');
      rethrow;
    }
  }
}

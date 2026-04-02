import 'package:flutter/foundation.dart';
import 'package:kuwentobuddy/models/child_profile_model.dart';
import 'package:kuwentobuddy/models/user_model.dart';
import 'package:kuwentobuddy/services/auth_service.dart';
import 'package:kuwentobuddy/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileController extends ChangeNotifier {
  final UserService _userService;

  ChildProfileModel? _currentProfile;
  List<ChildProfileModel> _profiles = [];
  bool _isLoading = false;
  String? _lastErrorMessage;

  ProfileController() : _userService = UserService();

  ChildProfileModel? get currentProfile => _currentProfile;
  List<ChildProfileModel> get profiles => _profiles;
  bool get isLoading => _isLoading;
  String? get lastErrorMessage => _lastErrorMessage;

  String _normalizeName(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
  }

  bool isDuplicateName(String displayName, {String? excludingProfileId}) {
    final normalized = _normalizeName(displayName);
    if (normalized.isEmpty) return false;

    return _profiles.any((profile) {
      if (excludingProfileId != null && profile.id == excludingProfileId) {
        return false;
      }
      return _normalizeName(profile.displayName) == normalized;
    });
  }

  String? validateProfileName(
    String displayName, {
    String? excludingProfileId,
  }) {
    final normalized = _normalizeName(displayName);
    if (normalized.isEmpty) {
      return 'Please enter a profile name.';
    }
    if (isDuplicateName(displayName, excludingProfileId: excludingProfileId)) {
      return 'That profile name is already in use.';
    }
    return null;
  }

  Future<void> loadProfiles(String parentUid) async {
    _isLoading = true;
    _lastErrorMessage = null;
    notifyListeners();

    try {
      _profiles = await _userService.getChildProfiles(parentUid);

      // Auto-select if there's a cached active profile
      final prefs = await SharedPreferences.getInstance();
      final lastProfileId = prefs.getString('active_profile_$parentUid');

      if (lastProfileId != null) {
        try {
          _currentProfile = _profiles.firstWhere((p) => p.id == lastProfileId);
          _userService.setActiveProfileId(_currentProfile!.id);
        } catch (_) {
          _currentProfile = null;
        }
      }
    } catch (e) {
      debugPrint('Error loading profiles: $e');
      _lastErrorMessage = 'We could not load profiles. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectProfile(
    String parentUid,
    ChildProfileModel profile,
    AuthService auth,
  ) async {
    _currentProfile = profile;
    _userService.setActiveProfileId(profile.id);

    // Inject profile into AuthService's user view so features naturally use profile stats
    final proxyUser = UserModel(
      id: parentUid, // Keep parent UUID for Firebase rule passes
      email: auth.currentUser?.email,
      displayName: profile.displayName,
      photoUrl: profile.avatarAsset,
      totalStars: profile.totalStars,
      storiesCompleted: profile.storiesCompleted,
      favoriteStoryIds: profile.favoriteStoryIds,
      storyProgress: profile.storyProgress,
      preferences: profile.preferences,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
      isGuest: false,
    );
    auth.switchToProfileView(proxyUser);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_profile_$parentUid', profile.id);
    notifyListeners();
  }

  Future<ChildProfileModel> createProfile(
    String parentUid,
    String name,
    String avatar,
    AuthService auth,
  ) async {
    _isLoading = true;
    _lastErrorMessage = null;
    notifyListeners();

    try {
      final newProfile = await _userService.createChildProfile(
        parentUid,
        name,
        avatar,
      );
      _profiles.add(newProfile);
      await selectProfile(parentUid, newProfile, auth);
      return newProfile;
    } catch (e) {
      debugPrint('Error creating profile: $e');
      _lastErrorMessage = e.toString().replaceFirst('StateError: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ChildProfileModel> updateProfile(
    String parentUid,
    ChildProfileModel profile,
    String name,
    String avatar,
    AuthService auth,
  ) async {
    _isLoading = true;
    _lastErrorMessage = null;
    notifyListeners();

    try {
      final updatedProfile = await _userService.updateChildProfile(
        parentUid,
        profile,
        name,
        avatar,
      );

      final index = _profiles.indexWhere((item) => item.id == profile.id);
      if (index >= 0) {
        _profiles[index] = updatedProfile;
      }

      if (_currentProfile?.id == updatedProfile.id) {
        await selectProfile(parentUid, updatedProfile, auth);
      }

      return updatedProfile;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      _lastErrorMessage = e.toString().replaceFirst('StateError: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProfile(
    String parentUid,
    ChildProfileModel profile,
    AuthService auth,
  ) async {
    _isLoading = true;
    _lastErrorMessage = null;
    notifyListeners();

    try {
      await _userService.deleteChildProfile(parentUid, profile.id);
      _profiles.removeWhere((item) => item.id == profile.id);

      if (_currentProfile?.id == profile.id) {
        await clearActiveProfile();
        auth.switchToParentView();
      }
    } catch (e) {
      debugPrint('Error deleting profile: $e');
      _lastErrorMessage = 'We could not delete that profile right now.';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearActiveProfile() async {
    _currentProfile = null;
    _userService.setActiveProfileId(null);
    notifyListeners();
  }
}

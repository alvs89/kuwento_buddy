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

  ProfileController() : _userService = UserService();

  ChildProfileModel? get currentProfile => _currentProfile;
  List<ChildProfileModel> get profiles => _profiles;
  bool get isLoading => _isLoading;

  Future<void> loadProfiles(String parentUid) async {
    _isLoading = true;
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
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectProfile(
      String parentUid, ChildProfileModel profile, AuthService auth) async {
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

  Future<void> createAndSelectProfile(
      String parentUid, String name, String avatar, AuthService auth) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newProfile =
          await _userService.createChildProfile(parentUid, name, avatar);
      _profiles.add(newProfile);
      await selectProfile(parentUid, newProfile, auth);
    } catch (e) {
      debugPrint('Error creating profile: $e');
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

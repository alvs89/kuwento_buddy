import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kuwentobuddy/models/user_model.dart';
import 'package:kuwentobuddy/services/user_service.dart';

/// Authentication status
enum AuthStatus { unknown, authenticated, guest, unauthenticated }

/// User intent when opening auth flow.
enum AuthIntent { signIn, signUp }

/// Backend auth result with metadata for UX decisions.
class GoogleAuthResult {
  final UserModel? user;
  final bool isNewUser;
  final bool wasCancelled;
  final String? errorMessage;

  const GoogleAuthResult({
    this.user,
    this.isNewUser = false,
    this.wasCancelled = false,
    this.errorMessage,
  });
}

/// Authentication service handling Firebase auth and guest mode
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: const ['email', 'profile'],
  );
  final UserService _userService = UserService();
  static const String _guestUserKey = 'guest_user';
  static const String _authUserCachePrefix = 'auth_user_';

  AuthStatus _status = AuthStatus.unknown;
  UserModel? _currentUser;
  bool _isLoading = true;

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isGuest => _status == AuthStatus.guest;

  /// Initialize auth state
  Future<void> initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Check for existing Firebase user
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        await _loadOrCreateUser(firebaseUser);
        _status = AuthStatus.authenticated;
        await _syncAuthenticatedStateWithCloud(firebaseUser.uid);
      } else {
        // Check for guest session
        final prefs = await SharedPreferences.getInstance();
        final guestData = prefs.getString(_guestUserKey);
        if (guestData != null) {
          try {
            _currentUser = UserModel.fromJson(jsonDecode(guestData));
            _status = AuthStatus.guest;
          } catch (e) {
            debugPrint('Failed to load guest data: $e');
            _status = AuthStatus.unauthenticated;
          }
        } else {
          _status = AuthStatus.unauthenticated;
        }
      }
    } catch (e) {
      debugPrint('Auth initialization error: $e');
      _status = AuthStatus.unauthenticated;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    final result = await authenticateWithGoogle(intent: AuthIntent.signIn);
    return result.user;
  }

  /// Authenticate with Google using explicit user intent (sign in vs sign up).
  Future<GoogleAuthResult> authenticateWithGoogle({
    required AuthIntent intent,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');

      UserCredential userCredential;

      if (kIsWeb) {
        // Web uses the Firebase popup provider flow.
        userCredential = await _auth
            .signInWithPopup(googleProvider)
            .timeout(const Duration(seconds: 45));
      } else {
        // Mobile uses GoogleSignIn, then exchanges tokens with Firebase.
        final googleUser =
            await _googleSignIn.signIn().timeout(const Duration(seconds: 45));
        if (googleUser == null) {
          // User cancelled the Google account picker.
          return const GoogleAuthResult(wasCancelled: true);
        }

        final googleAuth = await googleUser.authentication
            .timeout(const Duration(seconds: 30));
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await _auth
            .signInWithCredential(credential)
            .timeout(const Duration(seconds: 45));
      }

      if (userCredential.user != null) {
        final firebaseUser = userCredential.user!;
        final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

        try {
          await _loadOrCreateUser(firebaseUser)
              .timeout(const Duration(seconds: 30));
          await _mergeGuestProgress().timeout(const Duration(seconds: 20));
          await _syncAuthenticatedStateWithCloud(firebaseUser.uid)
              .timeout(const Duration(seconds: 20));
        } catch (e) {
          // Do not fail sign-in if profile sync has transient backend issues.
          // Create a minimal local profile so the user can proceed.
          debugPrint('Post-auth profile sync failed, using local fallback: $e');
          _currentUser ??= UserModel(
            id: firebaseUser.uid,
            email: firebaseUser.email,
            displayName: firebaseUser.displayName,
            photoUrl: firebaseUser.photoURL,
            isGuest: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }

        _currentUser ??= UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email,
          displayName: firebaseUser.displayName,
          photoUrl: firebaseUser.photoURL,
          isGuest: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        try {
          await _cacheAuthenticatedUser(_currentUser!);
        } catch (e) {
          debugPrint('Failed to cache authenticated user after sign-in: $e');
        }

        _status = AuthStatus.authenticated;
        notifyListeners();

        debugPrint(
          'Google auth completed. intent=$intent, isNewUser=$isNewUser',
        );

        return GoogleAuthResult(
          user: _currentUser,
          isNewUser: isNewUser,
        );
      }
      return const GoogleAuthResult();
    } on TimeoutException {
      return const GoogleAuthResult(
        errorMessage:
            'Authentication timed out. Check internet, then try again.',
      );
    } on FirebaseAuthException catch (e) {
      debugPrint(
          'Google sign in FirebaseAuthException: ${e.code} ${e.message}');
      return GoogleAuthResult(errorMessage: _mapFirebaseAuthError(e));
    } catch (e) {
      debugPrint('Google sign in error: $e');
      return const GoogleAuthResult(
        errorMessage: 'Authentication failed. Please try again.',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'network-request-failed':
        return 'Network error during sign in. Check your connection.';
      case 'invalid-credential':
      case 'account-exists-with-different-credential':
      case 'invalid-oauth-client-id':
        return 'Google Sign-In configuration issue. Verify package name and SHA in Firebase.';
      case 'operation-not-allowed':
        return 'Google Sign-In is not enabled in Firebase Authentication.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }

  /// Continue as guest
  Future<UserModel> continueAsGuest() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check for existing guest data
      final prefs = await SharedPreferences.getInstance();
      final existingGuestData = prefs.getString(_guestUserKey);

      if (existingGuestData != null) {
        try {
          _currentUser = UserModel.fromJson(jsonDecode(existingGuestData));
        } catch (e) {
          _currentUser = UserModel.guest();
        }
      } else {
        _currentUser = UserModel.guest();
      }

      await prefs.setString(_guestUserKey, jsonEncode(_currentUser!.toJson()));
      _status = AuthStatus.guest;
      notifyListeners();
      return _currentUser!;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_status == AuthStatus.authenticated) {
        await _auth.signOut();
        await _googleSignIn.signOut();
      }

      // Clear guest data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_guestUserKey);

      _currentUser = null;
      _status = AuthStatus.unauthenticated;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load or create user from Firebase user
  Future<void> _loadOrCreateUser(User firebaseUser) async {
    try {
      _currentUser = await _userService.getOrCreateUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email,
        displayName: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
      );
      if (_currentUser != null) {
        await _cacheAuthenticatedUser(_currentUser!);
      }
    } catch (e) {
      debugPrint('Failed to load user from Firestore: $e');
      final cached = await _loadCachedAuthenticatedUser(firebaseUser.uid);
      if (cached != null) {
        _currentUser = cached;
      } else {
        rethrow;
      }
    }
  }

  /// Merge guest progress to authenticated user
  Future<void> _mergeGuestProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final guestData = prefs.getString(_guestUserKey);

      if (guestData != null && _currentUser != null) {
        final guestUser = UserModel.fromJson(jsonDecode(guestData));

        // Merge progress
        final hasGuestDataToMerge = guestUser.storyProgress.isNotEmpty ||
            guestUser.favoriteStoryIds.isNotEmpty ||
            guestUser.totalStars > 0 ||
            guestUser.storiesCompleted > 0;

        if (hasGuestDataToMerge) {
          await _userService.mergeProgress(
            userId: _currentUser!.id,
            guestProgress: guestUser.storyProgress,
            guestStars: guestUser.totalStars,
            guestStoriesCompleted: guestUser.storiesCompleted,
            guestFavorites: guestUser.favoriteStoryIds,
          );

          // Reload user data
          _currentUser = await _userService.getUser(_currentUser!.id);
          if (_currentUser != null) {
            await _cacheAuthenticatedUser(_currentUser!);
          }
        }

        // Clear guest data after merge
        await prefs.remove(_guestUserKey);
      }
    } catch (e) {
      debugPrint('Failed to merge guest progress: $e');
    }
  }

  /// Update current user
  Future<void> updateUser(UserModel user) async {
    // Optimistic local update so UI reacts immediately (e.g., heart fill).
    _currentUser = user;
    notifyListeners();

    try {
      if (_status == AuthStatus.guest) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_guestUserKey, jsonEncode(user.toJson()));
      } else if (_status == AuthStatus.authenticated) {
        await _userService.updateUser(user);
        await _cacheAuthenticatedUser(user);
      }
    } catch (e) {
      debugPrint('Failed to persist user update: $e');
      if (_status == AuthStatus.authenticated) {
        await _cacheAuthenticatedUser(user);
      }
    }
  }

  /// Toggle a story favorite and persist it safely without overwriting other fields.
  /// Returns true when the story is now favorited, false when removed.
  Future<bool> toggleFavoriteStory(String storyId) async {
    final user = _currentUser;
    if (user == null) return false;

    final normalizedTarget = storyId.trim().toLowerCase();
    final updatedFavorites = List<String>.from(user.favoriteStoryIds);
    final existingIndex = updatedFavorites.indexWhere(
      (id) => id.trim().toLowerCase() == normalizedTarget,
    );

    final isNowFavorite = existingIndex == -1;
    if (isNowFavorite) {
      updatedFavorites.add(storyId);
    } else {
      updatedFavorites.removeAt(existingIndex);
    }

    final updatedUser = user.copyWith(
      favoriteStoryIds: updatedFavorites,
      updatedAt: DateTime.now(),
    );

    // Optimistic local update for immediate UI feedback.
    _currentUser = updatedUser;
    notifyListeners();

    try {
      if (_status == AuthStatus.guest) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_guestUserKey, jsonEncode(updatedUser.toJson()));
      } else if (_status == AuthStatus.authenticated) {
        await _userService.toggleFavorite(
            _currentUser!.id, storyId, isNowFavorite);
        await _cacheAuthenticatedUser(updatedUser);
      }
    } catch (e) {
      debugPrint('Failed to persist favorite toggle: $e');
      if (_status == AuthStatus.authenticated) {
        await _cacheAuthenticatedUser(updatedUser);
      }
    }

    return isNowFavorite;
  }

  String _authUserCacheKey(String uid) => '$_authUserCachePrefix$uid';

  Future<void> _cacheAuthenticatedUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _authUserCacheKey(user.id), jsonEncode(user.toJson()));
  }

  Future<UserModel?> _loadCachedAuthenticatedUser(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_authUserCacheKey(uid));
    if (raw == null) return null;

    try {
      return UserModel.fromJson(jsonDecode(raw));
    } catch (e) {
      debugPrint('Failed to decode cached authenticated user: $e');
      return null;
    }
  }

  Future<void> _syncAuthenticatedStateWithCloud(String uid) async {
    if (_status != AuthStatus.authenticated) return;

    try {
      final cached = await _loadCachedAuthenticatedUser(uid);
      final current = _currentUser;

      if (cached == null || current == null) {
        final fresh = await _userService.getUser(uid);
        if (fresh != null) {
          _currentUser = fresh;
          await _cacheAuthenticatedUser(fresh);
          notifyListeners();
        }
        return;
      }

      final mergedStoryProgress = Map<String, StoryProgress>.from(
        current.storyProgress,
      );
      for (final entry in cached.storyProgress.entries) {
        final existing = mergedStoryProgress[entry.key];
        if (existing == null ||
            entry.value.updatedAt.isAfter(existing.updatedAt)) {
          mergedStoryProgress[entry.key] = entry.value;
        }
      }

      final mergedFavorites = <String>{
        ...current.favoriteStoryIds,
        ...cached.favoriteStoryIds,
      }.toList();

      final merged = current.copyWith(
        totalStars: current.totalStars >= cached.totalStars
            ? current.totalStars
            : cached.totalStars,
        storiesCompleted: current.storiesCompleted >= cached.storiesCompleted
            ? current.storiesCompleted
            : cached.storiesCompleted,
        favoriteStoryIds: mergedFavorites,
        storyProgress: mergedStoryProgress,
        createdAt: current.createdAt.isBefore(cached.createdAt)
            ? current.createdAt
            : cached.createdAt,
        updatedAt: DateTime.now(),
      );

      await _userService.updateUser(merged);

      final refreshed = await _userService.getUser(uid);
      _currentUser = refreshed ?? merged;
      await _cacheAuthenticatedUser(_currentUser!);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to sync authenticated user state with cloud: $e');
    }
  }
}

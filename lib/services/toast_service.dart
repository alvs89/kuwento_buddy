import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kuwentobuddy/theme.dart';

/// Toast notification types
enum ToastType { success, error, info, warning }

/// Toast service for system feedback
class ToastService {
  static final ToastService _instance = ToastService._internal();
  factory ToastService() => _instance;
  ToastService._internal();

  /// Show a toast notification
  void show({
    required String message,
    ToastType type = ToastType.info,
    Toast length = Toast.LENGTH_SHORT,
  }) {
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (type) {
      case ToastType.success:
        backgroundColor = KuwentoColors.buddyHappy;
        break;
      case ToastType.error:
        backgroundColor = KuwentoColors.softCoral;
        break;
      case ToastType.warning:
        backgroundColor = KuwentoColors.buddyThinking;
        textColor = Colors.black87;
        break;
      case ToastType.info:
        backgroundColor = KuwentoColors.pastelBlue;
        break;
    }

    Fluttertoast.showToast(
      msg: message,
      toastLength: length,
      // Pin to top-right; webPosition controls horizontal alignment on web.
      gravity: ToastGravity.TOP,
      webPosition: 'right',
      timeInSecForIosWeb: length == Toast.LENGTH_SHORT ? 2 : 4,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: 14.0,
    );
  }

  /// Show success toast
  void showSuccess(String message) {
    show(message: message, type: ToastType.success);
  }

  /// Show error toast
  void showError(String message) {
    show(message: message, type: ToastType.error, length: Toast.LENGTH_LONG);
  }

  /// Show info toast
  void showInfo(String message) {
    show(message: message, type: ToastType.info);
  }

  /// Show warning toast
  void showWarning(String message) {
    show(message: message, type: ToastType.warning);
  }

  /// Show welcome toast with buddy
  void showWelcome(String userName) {
    show(
      message: 'Welcome back, $userName! 📚',
      type: ToastType.success,
      length: Toast.LENGTH_LONG,
    );
  }

  /// Show guest prompt toast
  void showGuestPrompt() {
    show(
      message: 'Magaling! To save your stories forever, create an account! 🌟',
      type: ToastType.info,
      length: Toast.LENGTH_LONG,
    );
  }

  /// Show story completion toast
  void showStoryCompleted(int stars) {
    final normalizedStars = stars.clamp(0, 3);
    final starLabel = normalizedStars == 1 ? 'star' : 'stars';
    final message = normalizedStars == 0
        ? 'You earned 0 stars! Keep going! ⭐'
        : 'Amazing! You earned $normalizedStars $starLabel! ⭐';

    show(
      message: message,
      type: ToastType.success,
      length: Toast.LENGTH_LONG,
    );
  }

  /// Show correct answer toast
  void showCorrectAnswer() {
    show(
      message: 'Magaling! That\'s correct! 🎉',
      type: ToastType.success,
    );
  }

  /// Show hint toast
  void showHint(String hint) {
    show(
      message: '💡 Hint: $hint',
      type: ToastType.info,
      length: Toast.LENGTH_LONG,
    );
  }

  /// Show progress saved toast
  void showProgressSaved() {
    show(
      message: 'Progress saved! ✓',
      type: ToastType.success,
    );
  }

  /// Show error with retry suggestion
  void showErrorWithRetry(String action) {
    show(
      message: 'Oops! Let\'s try $action again. 🤔',
      type: ToastType.error,
      length: Toast.LENGTH_LONG,
    );
  }
}

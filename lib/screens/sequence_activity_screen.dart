import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:kuwentobuddy/models/story_model.dart';
import 'package:kuwentobuddy/models/user_model.dart';
import 'package:kuwentobuddy/services/auth_service.dart';
import 'package:kuwentobuddy/services/story_service.dart';
import 'package:kuwentobuddy/services/toast_service.dart';
import 'package:kuwentobuddy/theme.dart';
import 'package:kuwentobuddy/widgets/buddy_companion.dart';

/// Sequence the story activity - Post-reading comprehension check
/// Users arrange story events in the correct chronological order
class SequenceActivityScreen extends StatefulWidget {
  final String storyId;

  const SequenceActivityScreen({super.key, required this.storyId});

  @override
  State<SequenceActivityScreen> createState() => _SequenceActivityScreenState();
}

class _SequenceActivityScreenState extends State<SequenceActivityScreen> {
  final StoryService _storyService = StoryService();
  final ToastService _toastService = ToastService();

  StoryModel? _story;
  List<_SequenceEvent> _events = [];
  final List<int> _selectedOrder = [];
  bool _isCompleted = false;
  bool _isCorrect = false;
  BuddyState _buddyState = BuddyState.idle;
  String? _buddyMessage;

  @override
  void initState() {
    super.initState();
    _loadStory();
  }

  void _loadStory() {
    final story = _storyService.getStoryById(widget.storyId);
    if (story != null) {
      setState(() {
        _story = story;
        _events = _generateEvents(story);
        _buddyMessage =
            'Put the story events in the right order! Tap each one to arrange them.';
      });
    }
  }

  List<_SequenceEvent> _generateEvents(StoryModel story) {
    // Extract key events from each segment
    final events = <_SequenceEvent>[];

    for (int i = 0; i < story.segments.length; i++) {
      final segment = story.segments[i];
      final content = segment.content;

      // Get the first meaningful sentence as the event summary
      final sentences = content.split(RegExp(r'[.!?]\s+'));
      String eventText = '';

      for (final sentence in sentences) {
        final trimmed = sentence.trim();
        if (trimmed.length > 20 && trimmed.length < 100) {
          eventText = trimmed;
          break;
        }
      }

      if (eventText.isEmpty && sentences.isNotEmpty) {
        eventText = sentences.first.trim();
        if (eventText.length > 80) {
          eventText = '${eventText.substring(0, 77)}...';
        }
      }

      if (eventText.isNotEmpty) {
        events.add(_SequenceEvent(
          id: i,
          text: eventText,
          correctOrder: i,
        ));
      }
    }

    // Shuffle the events
    final shuffled = List<_SequenceEvent>.from(events);
    shuffled.shuffle(Random());

    return shuffled;
  }

  void _selectEvent(int eventId) {
    if (_isCompleted) return;

    HapticFeedback.selectionClick();

    setState(() {
      if (_selectedOrder.contains(eventId)) {
        _selectedOrder.remove(eventId);
      } else {
        _selectedOrder.add(eventId);
      }

      _buddyState = BuddyState.thinking;
      _buddyMessage =
          '${_selectedOrder.length}/${_events.length} events selected';
    });

    // Check if all events are selected
    if (_selectedOrder.length == _events.length) {
      _checkAnswer();
    }
  }

  void _checkAnswer() {
    // Check if the order is correct
    bool isCorrect = true;
    for (int i = 0; i < _selectedOrder.length; i++) {
      final event = _events.firstWhere((e) => e.id == _selectedOrder[i]);
      if (event.correctOrder != i) {
        isCorrect = false;
        break;
      }
    }

    setState(() {
      _isCompleted = true;
      _isCorrect = isCorrect;

      if (isCorrect) {
        _buddyState = BuddyState.happy;
        _buddyMessage = 'Magaling! You got the story order correct! 🎉';
        _toastService.showSuccess('Perfect sequence!');
        _markStoryCompletedAfterSequence();
      } else {
        _buddyState = BuddyState.sympathetic;
        _buddyMessage =
            'Almost! Let\'s try again. Think about what happened first in the story.';
      }
    });
  }

  Future<void> _markStoryCompletedAfterSequence() async {
    final authService = context.read<AuthService>();
    final userSnapshot = authService.currentUser;
    final story = _story;
    if (userSnapshot == null || story == null) return;

    final existingProgress = userSnapshot.storyProgress[story.id];
    final now = DateTime.now();
    final completedProgress = (existingProgress ??
            StoryProgress(
              storyId: story.id,
              storyTitle: story.title,
              totalSegments: story.totalSegments,
              startedAt: now,
              updatedAt: now,
            ))
        .copyWith(
      storyTitle: existingProgress?.storyTitle ?? story.title,
      currentSegmentIndex:
          story.totalSegments > 0 ? story.totalSegments - 1 : 0,
      totalSegments: story.totalSegments,
      isCompleted: true,
      completedAt: now,
      updatedAt: now,
    );

    final wasAlreadyCompleted = existingProgress?.isCompleted == true;

    await authService.saveStoryProgress(
      completedProgress,
      completedIncrement: !wasAlreadyCompleted,
    );
  }

  void _resetActivity() {
    setState(() {
      _selectedOrder.clear();
      _isCompleted = false;
      _isCorrect = false;
      _events.shuffle(Random());
      _buddyState = BuddyState.idle;
      _buddyMessage = 'Let\'s try again! Put the events in order.';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_story == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: KuwentoColors.pastelBlue,
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: isDark ? Colors.white : KuwentoColors.textPrimary,
          ),
          onPressed: () async {
            final action = await showDialog<String>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Leave activity?'),
                content: const Text(
                    'Do you want to exit this activity and return to the Home screen?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(null),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop('exit_home'),
                    child: const Text('Go to Home'),
                  ),
                ],
              ),
            );

            if (!context.mounted || action == null) return;
            if (action == 'exit_home') {
              GoRouter.of(context).go('/');
              return;
            }
            context.pop({'action': action});
          },
        ),
        title: Text(
          'Put It in Order',
          style: TextStyle(
            color: isDark ? Colors.white : KuwentoColors.textPrimary,
          ),
        ),
        actions: [
          if (_isCompleted && !_isCorrect)
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: KuwentoColors.pastelBlue,
              ),
              onPressed: _resetActivity,
            ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Instructions
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
                child: Text(
                  'Tap events in the order they happened in the story',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? Colors.white70
                            : KuwentoColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Events list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    final event = _events[index];
                    final selectionIndex = _selectedOrder.indexOf(event.id);
                    final isSelected = selectionIndex != -1;

                    Color backgroundColor;
                    Color borderColor;

                    if (_isCompleted) {
                      // Show correct/incorrect after completion
                      final correctIndex = _selectedOrder.indexOf(event.id);
                      if (correctIndex != -1) {
                        final isInCorrectPosition =
                            event.correctOrder == correctIndex;
                        backgroundColor = isInCorrectPosition
                            ? KuwentoColors.buddyHappy.withValues(alpha: 0.2)
                            : KuwentoColors.softCoral.withValues(alpha: 0.2);
                        borderColor = isInCorrectPosition
                            ? KuwentoColors.buddyHappy
                            : KuwentoColors.softCoral;
                      } else {
                        backgroundColor = Colors.transparent;
                        borderColor =
                            isDark ? Colors.white24 : KuwentoColors.creamDark;
                      }
                    } else if (isSelected) {
                      backgroundColor =
                          KuwentoColors.pastelBlue.withValues(alpha: 0.2);
                      borderColor = KuwentoColors.pastelBlue;
                    } else {
                      backgroundColor =
                          isDark ? KuwentoColors.cardDark : Colors.white;
                      borderColor =
                          isDark ? Colors.white24 : KuwentoColors.creamDark;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: GestureDetector(
                        onTap: () => _selectEvent(event.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: borderColor, width: 2),
                          ),
                          child: Row(
                            children: [
                              // Number badge
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? KuwentoColors.pastelBlue
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? KuwentoColors.pastelBlue
                                        : borderColor,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: isSelected
                                      ? Text(
                                          '${selectionIndex + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        )
                                      : Icon(
                                          Icons.touch_app,
                                          size: 16,
                                          color: isDark
                                              ? Colors.white54
                                              : KuwentoColors.textMuted,
                                        ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  event.text,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: isDark
                                            ? Colors.white
                                            : KuwentoColors.textPrimary,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bottom action area
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark ? KuwentoColors.cardDark : Colors.white,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.xl)),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: _isCompleted && _isCorrect
                            ? ElevatedButton(
                                onPressed: () => context.go('/'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: KuwentoColors.buddyHappy,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text(
                                  'Back to Home',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : OutlinedButton(
                                onPressed: _resetActivity,
                                child: Text(
                                  _isCompleted ? 'Try Again' : 'Reset',
                                  style: TextStyle(
                                      color: KuwentoColors.pastelBlue),
                                ),
                              ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => context.pop({'action': 'restart'}),
                          child: const Text('Read Again'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom-right floating buddy with interactive hint bubble
          Positioned(
            right: 20,
            bottom: 120 + AppSpacing.lg,
            child: SafeArea(
              child: BuddyCompanion(
                state: _buddyState,
                message: _buddyMessage,
                tapMessage: _buddyMessage,
                enableTapSpeechBubble: true,
                showSpeechBubble: true,
                size: 60, // single enlarged floating buddy in thumb zone
                onTap: () {
                  setState(() {
                    _buddyMessage = _buddyMessage ??
                        'Put the story events in the right order!';
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SequenceEvent {
  final int id;
  final String text;
  final int correctOrder;

  const _SequenceEvent({
    required this.id,
    required this.text,
    required this.correctOrder,
  });
}

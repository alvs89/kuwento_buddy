import 'package:flutter/material.dart';
import 'package:kuwentobuddy/theme.dart';

class ProfileAvatar extends StatelessWidget {
  final String? source;
  final String label;
  final double size;
  final Color accentColor;
  final bool showBorder;

  const ProfileAvatar({
    super.key,
    required this.label,
    this.source,
    this.size = 72,
    this.accentColor = KuwentoColors.pastelBlue,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final avatarSource = source?.trim();
    final initials = _initialsForLabel(label);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.95),
            KuwentoColors.skyBlue.withValues(alpha: 0.95),
          ],
        ),
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: Colors.white.withValues(alpha: 0.85),
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipOval(
        child: _buildAvatarContent(avatarSource, initials),
      ),
    );
  }

  Widget _buildAvatarContent(String? avatarSource, String initials) {
    if (avatarSource == null || avatarSource.isEmpty) {
      return _InitialsAvatar(initials: initials);
    }

    if (avatarSource.startsWith('http://') ||
        avatarSource.startsWith('https://')) {
      return Image.network(
        avatarSource,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _InitialsAvatar(initials: initials),
      );
    }

    if (avatarSource.startsWith('assets/')) {
      return Image.asset(
        avatarSource,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _InitialsAvatar(initials: initials),
      );
    }

    return _InitialsAvatar(initials: initials);
  }

  String _initialsForLabel(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '?';

    final words =
        trimmed.split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return '${words.first.substring(0, 1)}${words.last.substring(0, 1)}'
        .toUpperCase();
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String initials;

  const _InitialsAvatar({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:kuwentobuddy/controllers/profile_controller.dart';
import 'package:kuwentobuddy/models/child_profile_model.dart';
import 'package:kuwentobuddy/services/auth_service.dart';
import 'package:kuwentobuddy/theme.dart';

class ProfileSelectionScreen extends StatefulWidget {
  const ProfileSelectionScreen({super.key});

  @override
  State<ProfileSelectionScreen> createState() => _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState extends State<ProfileSelectionScreen> {
  static const List<Color> _accentPalette = [
    KuwentoColors.pastelBlue,
    KuwentoColors.softCoral,
    KuwentoColors.buddyThinking,
    KuwentoColors.buddyHappy,
    KuwentoColors.buddyEncouraging,
    KuwentoColors.deepTeal,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthService>();
      final controller = context.read<ProfileController>();
      auth.switchToParentView();
      controller.clearActiveProfile();

      final parentUid = auth.parentUid ?? auth.currentUser?.id;
      if (parentUid != null && parentUid.isNotEmpty) {
        controller.loadProfiles(parentUid);
      }
    });
  }

  String _normalizedName(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
  }

  Color _accentForName(String value) {
    final index = _normalizedName(value).hashCode.abs() % _accentPalette.length;
    return _accentPalette[index];
  }

  Color _accentForProfile(ChildProfileModel profile) {
    return _accentForName(profile.displayName);
  }

  Future<void> _refreshProfiles() async {
    final auth = context.read<AuthService>();
    final parentUid = auth.parentUid ?? auth.currentUser?.id;
    if (parentUid == null || parentUid.isEmpty) return;
    await context.read<ProfileController>().loadProfiles(parentUid);
  }

  Future<void> _selectProfile(ChildProfileModel profile) async {
    final auth = context.read<AuthService>();
    final parentUid = auth.parentUid ?? auth.currentUser?.id ?? '';
    if (parentUid.isEmpty) return;

    await context.read<ProfileController>().selectProfile(
          parentUid,
          profile,
          auth,
        );

    if (!mounted) return;
    context.go('/');
  }

  Future<void> _openEditOptions() async {
    final controller = context.read<ProfileController>();
    final profiles = List<ChildProfileModel>.from(controller.profiles);

    final action = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          title: const Text('Edit profiles'),
          content: SizedBox(
            width: double.maxFinite,
            child: profiles.isEmpty
                ? const Text('Create a profile first to edit it later.')
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: profiles.length,
                    separatorBuilder: (_, __) => const Divider(height: 16),
                    itemBuilder: (context, index) {
                      final profile = profiles[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: _accentForProfile(
                            profile,
                          ).withValues(alpha: 0.2),
                          child: Text(
                            profile.firstName.isNotEmpty
                                ? profile.firstName
                                    .substring(0, 1)
                                    .toUpperCase()
                                : '?',
                          ),
                        ),
                        title: Text(profile.displayName),
                        subtitle: Text(
                          profile.id == controller.currentProfile?.id
                              ? 'Currently selected'
                              : 'Tap to edit this profile',
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => Navigator.pop(dialogContext, profile.id),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, 'create'),
              child: const Text('Create profile'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );

    if (!mounted || action == null) return;

    if (action == 'create') {
      await _showProfileForm();
      return;
    }

    final selectedProfile = profiles.where((profile) => profile.id == action);
    if (selectedProfile.isEmpty) return;

    await _showProfileForm(profile: selectedProfile.first);
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          title: const Text('Sign out?'),
          content: const Text(
            'You will be signed out of this account and sent back to the login screen.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: KuwentoColors.softCoral,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sign out'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;

    final auth = context.read<AuthService>();
    await auth.signOut();
    if (!mounted) return;
    context.go('/login');
  }

  Future<void> _showProfileActions(ChildProfileModel profile) async {
    final action = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          title: const Text('Profile actions'),
          content: Text(profile.firstName),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, 'rename'),
              child: const Text('Edit Profile'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, 'delete'),
              child: const Text('Delete profile'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, 'cancel'),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (!mounted || action == null || action == 'cancel') return;
    if (action == 'rename') {
      await _showProfileForm(profile: profile);
    } else if (action == 'delete') {
      await _deleteProfile(profile);
    }
  }

  Future<void> _deleteProfile(ChildProfileModel profile) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          title: const Text('Delete profile?'),
          content: Text(
            'This will remove ${profile.firstName} and all of their saved progress from this account.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: KuwentoColors.softCoral,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;

    final auth = context.read<AuthService>();
    final parentUid = auth.parentUid ?? auth.currentUser?.id ?? '';
    if (parentUid.isEmpty) return;

    try {
      await context.read<ProfileController>().deleteProfile(
            parentUid,
            profile,
            auth,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${profile.firstName} deleted.')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<ProfileController>().lastErrorMessage ??
                'We could not delete that profile.',
          ),
        ),
      );
    }
  }

  Future<void> _showProfileForm({ChildProfileModel? profile}) async {
    final auth = context.read<AuthService>();
    final parentUid = auth.parentUid ?? auth.currentUser?.id ?? '';
    if (parentUid.isEmpty) return;

    final controller = context.read<ProfileController>();
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (dialogContext) {
        return _ProfileFormDialog(
          parentUid: parentUid,
          profile: profile,
          auth: auth,
          controller: controller,
          accentColor: profile == null
              ? _accentForName('Reader')
              : _accentForProfile(profile),
        );
      },
    );

    if (!mounted || result == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result == 'created' ? 'Profile created.' : 'Profile updated.',
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [KuwentoColors.backgroundDark, const Color(0xFF0B1016)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -90,
              left: -70,
              child: _GlowOrb(
                size: 220,
                color: KuwentoColors.pastelBlue.withValues(alpha: 0.14),
              ),
            ),
            Positioned(
              top: 140,
              right: -70,
              child: _GlowOrb(
                size: 180,
                color: KuwentoColors.softCoral.withValues(alpha: 0.11),
              ),
            ),
            Positioned(
              bottom: -80,
              left: 30,
              child: _GlowOrb(
                size: 240,
                color: KuwentoColors.deepTeal.withValues(alpha: 0.09),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 380;
          final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: compact ? 2 : 4,
                fontSize: compact ? 18 : null,
                color: KuwentoColors.softCoral,
              );

          return Row(
            children: [
              Expanded(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'KUWENTO BUDDY',
                      maxLines: 1,
                      style: titleStyle,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _openEditOptions,
                    iconSize: compact ? 20 : 24,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 40,
                      height: 40,
                    ),
                    icon: Icon(
                      Icons.edit_outlined,
                      color: isDark ? Colors.white70 : Colors.white,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.06),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: _signOut,
                    iconSize: compact ? 20 : 24,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 40,
                      height: 40,
                    ),
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: KuwentoColors.softCoral,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.06),
                      foregroundColor: KuwentoColors.softCoral,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          Text(
            'Who\'s Reading?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Tap a profile to continue. Long-press a profile to rename or delete it.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  height: 1.35,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ProfileController controller) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: KuwentoColors.pastelBlue.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.person_add_alt_1_rounded,
                size: 40,
                color: KuwentoColors.skyBlue,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No profiles yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              controller.lastErrorMessage ??
                  'Create a reader profile to keep each child\'s progress separate.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                    height: 1.4,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _showProfileForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: KuwentoColors.softCoral,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded),
            SizedBox(width: 8),
            Text('Create New Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: KuwentoColors.softCoral.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: KuwentoColors.softCoral.withValues(alpha: 0.28),
        ),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildProfileCard(ChildProfileModel profile, bool isSelected) {
    final accentColor = _accentForProfile(profile);

    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = constraints.maxWidth;
        final avatarSize = tileWidth.clamp(92.0, 112.0).toDouble();
        final actionSize = tileWidth < 180 ? 18.0 : 20.0;

        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.96, end: 1.0),
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          builder: (context, scale, child) =>
              Transform.scale(scale: scale, child: child),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _selectProfile(profile),
            onLongPress: () => _showProfileActions(profile),
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: avatarSize,
                    height: avatarSize,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _ProfileSquareAvatar(
                          label: profile.displayName,
                          source: profile.avatarAsset.isNotEmpty
                              ? profile.avatarAsset
                              : null,
                          accentColor: accentColor,
                          size: avatarSize,
                          isSelected: isSelected,
                        ),
                        if (isSelected)
                          Positioned(
                            top: 6,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: KuwentoColors.softCoral,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  width: 0.8,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.18),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                'ACTIVE',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.6,
                                    ),
                              ),
                            ),
                          ),
                        Positioned(
                          top: 3,
                          right: 3,
                          child: _ProfileActionButton(
                            size: actionSize,
                            onPressed: () => _showProfileActions(profile),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    profile.displayName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileController = context.watch<ProfileController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasProfiles = profileController.profiles.isNotEmpty;
    final crossAxisCount = MediaQuery.of(context).size.width >= 700 ? 3 : 2;

    return Scaffold(
      backgroundColor: KuwentoColors.backgroundDark,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: RefreshIndicator(
              color: KuwentoColors.softCoral,
              onRefresh: _refreshProfiles,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.xl,
                ),
                child: Column(
                  children: [
                    _buildHeader(isDark),
                    const SizedBox(height: 40),
                    if (hasProfiles) ...[
                      _buildSectionTitle(),
                      const SizedBox(height: 20),
                    ],
                    if (profileController.isLoading && !hasProfiles)
                      const Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(
                            KuwentoColors.softCoral,
                          ),
                        ),
                      )
                    else if (!hasProfiles)
                      _buildEmptyState(profileController)
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: profileController.profiles.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 0,
                          mainAxisSpacing: 0,
                          childAspectRatio: crossAxisCount == 2 ? 0.88 : 0.94,
                        ),
                        itemBuilder: (context, index) {
                          final profile = profileController.profiles[index];
                          final isSelected =
                              profileController.currentProfile?.id ==
                                  profile.id;
                          return _buildProfileCard(profile, isSelected);
                        },
                      ),
                    const SizedBox(height: AppSpacing.xl),
                    _buildCreateButton(),
                    if (profileController.lastErrorMessage != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      _buildErrorBanner(profileController.lastErrorMessage!),
                    ],
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double size;

  const _ProfileActionButton({required this.onPressed, this.size = 24});

  @override
  Widget build(BuildContext context) {
    final iconSize = size < 22 ? 14.0 : 16.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(
          Icons.more_horiz_rounded,
          size: iconSize,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _ProfileSquareAvatar extends StatelessWidget {
  final String label;
  final String? source;
  final Color accentColor;
  final double size;
  final bool isSelected;

  const _ProfileSquareAvatar({
    required this.label,
    required this.source,
    required this.accentColor,
    this.size = 96,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final initials = _initialsForLabel(label);
    return SizedBox.square(
      dimension: size,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accentColor,
              KuwentoColors.skyBlue.withValues(alpha: 0.85),
            ],
          ),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.22),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: _buildContent(initials),
        ),
      ),
    );
  }

  Widget _buildContent(String initials) {
    final sourceValue = source?.trim();
    if (sourceValue == null || sourceValue.isEmpty) {
      return _InitialsContent(initials: initials);
    }

    if (sourceValue.startsWith('http://') ||
        sourceValue.startsWith('https://')) {
      return Image.network(
        sourceValue,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _InitialsContent(initials: initials),
      );
    }

    if (sourceValue.startsWith('assets/')) {
      return Image.asset(
        sourceValue,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _InitialsContent(initials: initials),
      );
    }

    return _InitialsContent(initials: initials);
  }

  String _initialsForLabel(String value) {
    final words = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return '${words.first.substring(0, 1)}${words.last.substring(0, 1)}'
        .toUpperCase();
  }
}

class _InitialsContent extends StatelessWidget {
  final String initials;

  const _InitialsContent({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            initials,
            maxLines: 1,
            softWrap: false,
            style: TextStyle(
              color: Colors.white,
              fontSize: initials.length > 1 ? 26 : 28,
              fontWeight: FontWeight.w800,
              letterSpacing: initials.length > 1 ? 0.2 : 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileFormDialog extends StatefulWidget {
  final String parentUid;
  final ChildProfileModel? profile;
  final AuthService auth;
  final ProfileController controller;
  final Color accentColor;

  const _ProfileFormDialog({
    required this.parentUid,
    required this.profile,
    required this.auth,
    required this.controller,
    required this.accentColor,
  });

  @override
  State<_ProfileFormDialog> createState() => _ProfileFormDialogState();
}

class _ProfileFormDialogState extends State<_ProfileFormDialog> {
  late final TextEditingController _nameController;
  late String? _selectedAvatarSource;
  String? _errorText;
  bool _saving = false;

  static const List<_AvatarOption> _avatarOptions = [
    _AvatarOption(
      source: 'assets/images/Theodore.jpg',
      label: 'Theodore',
    ),
    _AvatarOption(source: 'assets/images/Baymax.jpg', label: 'Baymax'),
    _AvatarOption(
      source: 'assets/images/Symon.jpg',
      label: 'Symon',
    ),
    _AvatarOption(
      source: 'assets/images/Alvin.jpg',
      label: 'Alvin',
    ),
    _AvatarOption(
      source: 'assets/images/Brittany.jpg',
      label: 'Brittany',
    ),
    _AvatarOption(source: null, label: 'Initials', useInitials: true),
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.profile?.displayName ?? '',
    );
    _selectedAvatarSource = _avatarSourceForProfile(
      widget.profile?.avatarAsset,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final validationError = widget.controller.validateProfileName(
      _nameController.text,
      excludingProfileId: widget.profile?.id,
    );

    if (validationError != null) {
      setState(() => _errorText = validationError);
      return;
    }

    setState(() {
      _saving = true;
      _errorText = null;
    });

    try {
      final avatarAsset = _selectedAvatarSource?.trim() ?? '';

      if (widget.profile == null) {
        await widget.controller.createProfile(
          widget.parentUid,
          _nameController.text,
          avatarAsset,
          widget.auth,
        );
      } else {
        await widget.controller.updateProfile(
          widget.parentUid,
          widget.profile!,
          _nameController.text,
          avatarAsset,
          widget.auth,
        );
      }

      if (!mounted) return;
      Navigator.of(
        context,
        rootNavigator: true,
      ).pop(widget.profile == null ? 'created' : 'updated');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorText = widget.controller.lastErrorMessage ??
            e.toString().replaceFirst('StateError: ', '');
        _saving = false;
      });
    }
  }

  String? _avatarSourceForProfile(String? avatarAsset) {
    final normalized = avatarAsset?.trim() ?? '';
    if (normalized.isEmpty) {
      return null;
    }

    return normalized;
  }

  @override
  Widget build(BuildContext context) {
    final previewName = _nameController.text.trim().isEmpty
        ? 'Reader'
        : _nameController.text.trim();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: MediaQuery.of(context).size.height * 0.82,
        ),
        child: SingleChildScrollView(
          primary: false,
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.profile == null ? 'Add new profile' : 'Edit Profile',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        color: KuwentoColors.softCoral,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 340;
                    final preview = _ProfileSquareAvatar(
                      label: previewName,
                      source: _selectedAvatarSource,
                      accentColor: widget.accentColor,
                      size: 72,
                    );

                    final description = Text(
                      'Enter a name and pick one of the five story avatars.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                            height: 1.45,
                            fontWeight: FontWeight.w400,
                          ),
                    );

                    if (compact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(child: preview),
                          const SizedBox(height: AppSpacing.sm),
                          description,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        preview,
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: description),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Change an Avatar',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: KuwentoColors.deepTeal,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Tap one image below, or choose initials only.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white60,
                        height: 1.4,
                        fontWeight: FontWeight.w400,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 340;
                    final tileSize = compact ? 52.0 : 58.0;
                    final tileWidth = compact ? 68.0 : 76.0;
                    final gap = compact ? 8.0 : 10.0;

                    return Wrap(
                      alignment: WrapAlignment.center,
                      spacing: gap,
                      runSpacing: gap,
                      children: _avatarOptions.map((option) {
                        final isSelected = option.useInitials
                            ? _selectedAvatarSource == null ||
                                _selectedAvatarSource!.isEmpty
                            : _selectedAvatarSource == option.source;
                        final avatarLabel =
                            option.useInitials ? previewName : option.label;

                        return SizedBox(
                          width: tileWidth,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _saving
                                ? null
                                : () {
                                    setState(() {
                                      _selectedAvatarSource = option.source;
                                    });
                                  },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    _ProfileSquareAvatar(
                                      label: avatarLabel,
                                      source: option.useInitials
                                          ? null
                                          : option.source,
                                      accentColor: widget.accentColor,
                                      size: tileSize,
                                      isSelected: isSelected,
                                    ),
                                    if (isSelected)
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: Container(
                                          width: 18,
                                          height: 18,
                                          decoration: BoxDecoration(
                                            color: KuwentoColors.buddyHappy,
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.check_rounded,
                                            size: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  option.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: isSelected
                                            ? KuwentoColors.buddyHappy
                                            : KuwentoColors.textSecondary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: _nameController,
                  autofocus: widget.profile == null,
                  textCapitalization: TextCapitalization.words,
                  maxLength: 24,
                  onChanged: (_) {
                    if (_errorText != null) {
                      setState(() => _errorText = null);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Profile name',
                    helperText: 'Names must be unique.',
                    helperMaxLines: 2,
                    errorText: _errorText,
                    errorMaxLines: 3,
                    counterText: '',
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 320;

                    final cancelButton = OutlinedButton(
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    );

                    final saveButton = ElevatedButton(
                      onPressed: _saving ? null : _submit,
                      child: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(widget.profile == null ? 'Create' : 'Save'),
                    );

                    if (compact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          cancelButton,
                          const SizedBox(height: AppSpacing.sm),
                          saveButton,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: cancelButton),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(child: saveButton),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarOption {
  final String? source;
  final String label;
  final bool useInitials;

  const _AvatarOption({
    this.source,
    required this.label,
    this.useInitials = false,
  });
}

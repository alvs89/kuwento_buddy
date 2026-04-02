import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwentobuddy/controllers/profile_controller.dart';
import 'package:kuwentobuddy/services/auth_service.dart';
import 'package:kuwentobuddy/theme.dart';
import 'package:kuwentobuddy/widgets/parental_gate.dart';

class ProfileSelectionScreen extends StatefulWidget {
  const ProfileSelectionScreen({super.key});

  @override
  State<ProfileSelectionScreen> createState() => _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState extends State<ProfileSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthService>();
      auth.switchToParentView(); // Ensure we are out of child mode
      final parentUid = auth.parentUid;
      if (parentUid != null) {
        context.read<ProfileController>().loadProfiles(parentUid);
      }
    });

  }

  void _onAddProfile(BuildContext context) async {
    final parentId = context.read<AuthService>().parentUid ?? '';
    final passed = await ParentalGate.show(context);
    if (!context.mounted) return;
    
    if (passed == true) {
      // Show form to add profile (mocked here)
      final nameController = TextEditingController();
      showDialog(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Add New Reader'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Child\'s Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  context.read<ProfileController>().createAndSelectProfile(
                      parentId,
                      nameController.text,
                      'assets/icons/tarsier_avatar.png',
                      context.read<AuthService>());
                }
                Navigator.pop(c);
              },
              child: const Text('Create'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileController = context.watch<ProfileController>();
    final parentId = context.read<AuthService>().currentUser?.id ?? '';

    return Scaffold(
      backgroundColor: KuwentoColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: KuwentoColors.textSecondary),
            onPressed: () async {
              final passed = await ParentalGate.show(context);
              if (passed == true && context.mounted) {
                context.push('/settings');
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: KuwentoColors.softCoral),
            onPressed: () async {
              final authService = context.read<AuthService>();
              await authService.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40.0),
              child: Text(
                'Who is reading today?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: KuwentoColors.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: profileController.isLoading
                  ? const Center(child: CircularProgressBinding())
                  : GridView.builder(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: profileController.profiles.length + 1,
                      itemBuilder: (context, index) {
                        if (index == profileController.profiles.length) {
                          // "Add Profile" button
                          return GestureDetector(
                            onTap: () => _onAddProfile(context),
                            child: Container(
                              decoration: BoxDecoration(
                                color: KuwentoColors.surfaceLight,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: KuwentoColors.textMuted, width: 2),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add,
                                      size: 48,
                                      color: KuwentoColors.pastelBlue),
                                  SizedBox(height: 8),
                                  Text(
                                    'Add Profile',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: KuwentoColors.pastelBlue,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        }

                        // Profile Card
                        final profile = profileController.profiles[index];
                        return GestureDetector(
                          onTap: () async {
                            // Select & navigate
                            await context
                                .read<ProfileController>()
                                .selectProfile(parentId, profile,
                                    context.read<AuthService>());
                            if (context.mounted) {
                              context.go('/'); // Assumes main shell route
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: KuwentoColors.surfaceLight,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Mock avatar widget
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: KuwentoColors.skyBlue.withValues(alpha: 0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/icons/kuwentobuddy_icon.png',
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                        Center(
                                          child: Text(
                                            profile.firstName.isNotEmpty ? profile.firstName[0].toUpperCase() : '?',
                                            style: const TextStyle(
                                                fontSize: 32,
                                                fontWeight: FontWeight.bold,
                                                color: KuwentoColors.textPrimary),
                                          ),
                                        ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  profile.firstName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: KuwentoColors.textPrimary,
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class CircularProgressBinding extends StatelessWidget {
  const CircularProgressBinding({super.key});

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator();
  }
}

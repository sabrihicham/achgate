/// Usage guide for the new Profile Demo Screen
///
/// This file contains examples and best practices for using the redesigned profile screen

import 'package:flutter/material.dart';
import '../view/profile_demo_screen.dart';
import '../models/user_profile.dart';
import '../utils/responsive_helper.dart';

/// Example of how to navigate to the profile screen
class ProfileNavigationExample {
  /// Navigate to profile screen from any widget
  static void navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileDemoScreen()),
    );
  }

  /// Navigate with slide animation
  static void navigateToProfileWithAnimation(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ProfileDemoScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  /// Navigate and replace current screen
  static void navigateToProfileReplacement(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ProfileDemoScreen()),
    );
  }
}

/// Example of responsive design usage
class ResponsiveUsageExample extends StatelessWidget {
  const ResponsiveUsageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: context.contentWidth,
        padding: context.screenPadding,
        child: Column(
          children: [
            // Use responsive grid columns
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: context.gridColumns,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      context.cardBorderRadius,
                    ),
                  ),
                  child: Center(child: Text('Item $index')),
                );
              },
            ),

            // Responsive spacing
            SizedBox(height: context.isDesktop ? 32 : 16),

            // Conditional content based on screen size
            if (context.isDesktop)
              const Text('Desktop-specific content')
            else if (context.isTablet)
              const Text('Tablet-specific content')
            else
              const Text('Mobile-specific content'),
          ],
        ),
      ),
    );
  }
}

/// Example of custom user profile usage
class CustomProfileExample extends StatefulWidget {
  const CustomProfileExample({super.key});

  @override
  State<CustomProfileExample> createState() => _CustomProfileExampleState();
}

class _CustomProfileExampleState extends State<CustomProfileExample> {
  UserProfile userProfile = UserProfile.sampleUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Profile'),
        actions: [
          IconButton(onPressed: _updateProfile, icon: const Icon(Icons.save)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Display user info
            ListTile(
              title: Text(userProfile.fullName),
              subtitle: Text(userProfile.email),
              leading: CircleAvatar(child: Text(userProfile.fullName[0])),
            ),

            // Edit user info
            TextField(
              decoration: const InputDecoration(labelText: 'Full Name'),
              onChanged: (value) {
                setState(() {
                  userProfile = userProfile.copyWith(fullName: value);
                });
              },
            ),

            const SizedBox(height: 16),

            TextField(
              decoration: const InputDecoration(labelText: 'Job Title'),
              onChanged: (value) {
                setState(() {
                  userProfile = userProfile.copyWith(jobTitle: value);
                });
              },
            ),

            const SizedBox(height: 32),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _exportData,
                    child: const Text('Export Data'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetProfile,
                    child: const Text('Reset'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updateProfile() {
    // Save profile logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  }

  void _exportData() {
    // Export data logic here
    final jsonData = userProfile.toJson();
    print('Exported data: $jsonData');

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Data exported successfully')));
  }

  void _resetProfile() {
    setState(() {
      userProfile = UserProfile.sampleUser;
    });
  }
}

/// Best practices for profile screen integration
class ProfileBestPractices {
  /// 1. Always check user authentication before showing profile
  static bool checkUserAuthentication() {
    // Add your authentication logic here
    return true; // Simplified for example
  }

  /// 2. Handle errors gracefully
  static void handleProfileError(String error) {
    // Log error and show user-friendly message
    print('Profile error: $error');
  }

  /// 3. Validate input data
  static bool validateEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool validatePhoneNumber(String phone) {
    return RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(phone);
  }

  /// 4. Format display data
  static String formatLastLogin(DateTime lastLogin) {
    final now = DateTime.now();
    final difference = now.difference(lastLogin);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inMinutes} minutes ago';
    }
  }

  /// 5. Handle offline state
  static Widget buildOfflineIndicator() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.orange,
      child: const Row(
        children: [
          Icon(Icons.offline_bolt, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'You are offline. Some features may not work.',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

/// Integration with app theme
class ProfileThemeIntegration {
  /// Customize profile colors based on app theme
  static ThemeData getProfileTheme(BuildContext context) {
    final baseTheme = Theme.of(context);

    return baseTheme.copyWith(
      cardTheme: const CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: baseTheme.primaryColor, width: 2),
        ),
      ),
    );
  }

  /// Apply profile theme to the entire screen
  static Widget wrapWithProfileTheme(BuildContext context, Widget child) {
    return Theme(data: getProfileTheme(context), child: child);
  }
}

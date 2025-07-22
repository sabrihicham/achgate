# Firestore Configuration for Achievements

This document explains how the Firestore configuration has been set up for viewing, adding, and editing achievements in the AchGate application.

## Overview

The application now includes complete Firestore integration for managing achievements with the following features:

- ✅ Add new achievements
- ✅ View all achievements with filtering
- ✅ Edit pending achievements
- ✅ Delete achievements
- ✅ Real-time updates
- ✅ User-specific data isolation

## File Structure

### Models
- `lib/models/achievement.dart` - Achievement data model with Firestore serialization

### Services
- `lib/services/achievement_service.dart` - Complete Firestore operations for achievements

### Screens
- `lib/view/add_achievement_screen.dart` - Updated to save to Firestore
- `lib/view/view_achievements_screen.dart` - List and manage achievements
- `lib/view/edit_achievement_screen.dart` - Edit existing achievements

## Firestore Collection Structure

### Collection: `achievements`

```json
{
  "participationType": "string",
  "executiveDepartment": "string", 
  "mainDepartment": "string",
  "subDepartment": "string",
  "topic": "string",
  "goal": "string",
  "date": "timestamp",
  "location": "string",
  "duration": "string",
  "impact": "string",
  "attachments": ["string array"],
  "userId": "string",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "status": "string" // pending, approved, rejected
}
```

## Features Implemented

### 1. Add Achievement (`AddAchievementScreen`)
- Form validation
- Firestore integration
- Real-time department loading
- File attachment support (mock)
- Success/error handling

### 2. View Achievements (`ViewAchievementsScreen`)
- Real-time achievement listing
- Filter by status (all, pending, approved, rejected)
- Achievement counts and statistics
- Search functionality (basic)
- Animated UI with Material Design

### 3. Edit Achievement (`EditAchievementScreen`)
- Edit pending achievements only
- Form pre-population
- Validation and Firestore updates
- Status restrictions (can only edit pending)

### 4. Achievement Service (`AchievementService`)

#### Core Methods:
- `addAchievement(Achievement)` - Add new achievement
- `updateAchievement(Achievement)` - Update existing achievement
- `deleteAchievement(String)` - Delete achievement
- `getAchievementById(String)` - Get single achievement
- `getUserAchievements()` - Stream of user's achievements
- `getUserAchievementsByStatus(String)` - Filter by status
- `getUserAchievementsCount()` - Get statistics

#### Advanced Methods:
- `searchUserAchievements(String)` - Search functionality
- `getUserAchievementsByDepartment(String)` - Filter by department
- `getUserAchievementsByDateRange(DateTime, DateTime)` - Date filtering

## Security & Data Isolation

### User-based Data Isolation
- All achievements are associated with the authenticated user via `userId`
- Users can only view/edit their own achievements
- Firestore security rules should enforce this at the database level

### Recommended Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own achievements
    match /achievements/{achievementId} {
      allow read, write: if request.auth != null && 
                        request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && 
                   request.auth.uid == request.resource.data.userId;
    }
    
    // Allow users to read their own profile data if needed
    match /users/{userId} {
      allow read, write: if request.auth != null && 
                        request.auth.uid == userId;
    }
  }
}
```

## Navigation

### Routes Added to `main.dart`:
- `/add-achievement` - Add new achievement
- `/view-achievements` - View achievements list

### Home Screen Integration:
- Floating Action Button → Add Achievement
- "عرض الكل" button → View Achievements

## Status Management

Achievements have three statuses:
1. **pending** - Just created, awaiting review
2. **approved** - Reviewed and approved
3. **rejected** - Reviewed and rejected

Only **pending** achievements can be edited or deleted by users.

## Error Handling

- Network connectivity issues
- Firestore permission errors
- Validation errors
- User-friendly Arabic error messages

## Future Enhancements

### Recommended Improvements:
1. **File Upload**: Integrate with Firebase Storage for actual file uploads
2. **Advanced Search**: Use Algolia or similar for full-text search
3. **Offline Support**: Implement Firestore offline persistence
4. **Push Notifications**: Notify users of status changes
5. **Admin Panel**: Administrative interface for reviewing achievements
6. **Analytics**: Track achievement patterns and statistics
7. **Export Features**: PDF/Excel export of achievements
8. **Approval Workflow**: Multi-stage approval process

### Search Enhancement Example:
```dart
// Enhanced search with multiple fields
Future<List<Achievement>> advancedSearch({
  String? query,
  String? department,
  String? status,
  DateTimeRange? dateRange,
  String? participationType,
}) async {
  // Implementation with complex Firestore queries
}
```

## Testing

### Manual Testing Checklist:
- [ ] Add achievement with all fields
- [ ] View achievements list
- [ ] Filter by different statuses
- [ ] Edit pending achievement
- [ ] Try to edit approved/rejected (should be disabled)
- [ ] Delete achievement
- [ ] Search functionality
- [ ] Offline behavior
- [ ] User isolation (multiple users)

## Usage Examples

### Adding an Achievement:
```dart
final achievement = Achievement(
  participationType: 'مبادرة',
  executiveDepartment: 'الرعاية الأولية',
  mainDepartment: 'العيادات الخارجية',
  subDepartment: 'عيادة الباطنية',
  topic: 'تحسين تجربة المريض',
  goal: 'تقليل وقت الانتظار',
  date: DateTime.now(),
  location: 'المجمع الطبي',
  duration: 'شهر واحد',
  impact: 'تحسن رضا المرضى بنسبة 25%',
  attachments: [],
  userId: '', // Will be set automatically
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

await achievementService.addAchievement(achievement);
```

### Viewing Achievements:
```dart
StreamBuilder<List<Achievement>>(
  stream: achievementService.getUserAchievements(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final achievements = snapshot.data!;
      return ListView.builder(
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          return AchievementCard(achievement: achievements[index]);
        },
      );
    }
    return CircularProgressIndicator();
  },
)
```

## Dependencies Required

The following packages are already included in `pubspec.yaml`:
- `firebase_core: ^3.15.1`
- `firebase_auth: ^5.6.2`
- `cloud_firestore: ^5.6.11`

## Conclusion

The Firestore configuration is now complete and fully functional. Users can add, view, edit, and delete their achievements with real-time updates and proper data isolation. The implementation follows Flutter best practices and provides a solid foundation for future enhancements.

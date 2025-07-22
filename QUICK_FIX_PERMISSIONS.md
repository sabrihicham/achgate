# Firestore Permission Denied - Quick Fix Guide

This guide provides step-by-step solutions to fix Firestore permission denied errors in the AchGate Flutter application.

## Common Causes and Solutions

### 1. Firestore Security Rules Issues

**Problem**: Rules are too restrictive or have syntax errors.

**Solution**: Deploy the updated rules that have been fixed in `firestore.rules`.

Run these commands in order:

```bash
# Navigate to project directory
cd c:\Users\HICHAM\Github\achgate

# Deploy updated Firestore rules and indexes
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes

# Or deploy both at once
firebase deploy --only firestore
```

### 2. Missing Firestore Indexes

**Problem**: Compound queries require composite indexes that don't exist.

**Solution**: The `firestore.indexes.json` file has been updated with required indexes. Deploy them using the command above.

**Required Indexes**:
- `userId` + `createdAt` (descending)
- `userId` + `status` + `createdAt` (descending)  
- `userId` + `executiveDepartment` + `createdAt` (descending)
- `userId` + `date` (ascending/descending)

### 3. Authentication Issues

**Problem**: User is not properly authenticated or auth state is not checked.

**Quick Check**:
1. Verify user is logged in: `FirebaseAuth.instance.currentUser != null`
2. Check user email is verified: `user.emailVerified`
3. Ensure auth persistence is working

**Solution**: Add this debug code to check auth status:

```dart
import '../services/debug_service.dart';

// In your widget or service
final debugService = DebugService();
await debugService.printDebugInfo();
```

### 4. Data Structure Issues

**Problem**: Documents don't have required fields or have wrong data types.

**Required Fields for Achievements**:
- `userId` (string) - Must match authenticated user ID
- `participationType` (string)
- `topic` (string)
- `goal` (string)
- `date` (timestamp)
- `status` (string)
- `createdAt` (timestamp)
- `updatedAt` (timestamp)

### 5. Network/Firebase Project Issues

**Problem**: Wrong Firebase project, network issues, or Firebase services down.

**Checks**:
1. Verify project ID in `firebase_options.dart` matches your Firebase console
2. Check internet connection
3. Verify Firebase project exists and Firestore is enabled

## Step-by-Step Fix Process

### Step 1: Deploy Updated Rules
```bash
firebase deploy --only firestore
```

### Step 2: Check Authentication
Add this to your app temporarily to debug:

```dart
// Add to your main screen's initState or a button
void checkAuthAndPermissions() async {
  final user = FirebaseAuth.instance.currentUser;
  print('User: ${user?.uid}');
  print('Email: ${user?.email}');
  print('Verified: ${user?.emailVerified}');
  
  if (user != null) {
    try {
      final testDoc = await FirebaseFirestore.instance
          .collection('achievements')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();
      print('Firestore test successful: ${testDoc.docs.length} docs');
    } catch (e) {
      print('Firestore test failed: $e');
    }
  }
}
```

### Step 3: Clear App Data (if needed)
If you're still getting errors, try:
1. Stop the app
2. Clear app data/cache
3. Restart the app
4. Login again

### Step 4: Check Firebase Console
1. Go to Firebase Console → Firestore → Rules
2. Verify rules are deployed correctly
3. Check that indexes are being built (may take a few minutes)

## Updated Security Rules Summary

The new rules include:
- ✅ Proper authentication checks
- ✅ User ownership validation
- ✅ Required field validation
- ✅ Secure read/write operations
- ✅ Helper functions for cleaner rules

## Test Commands

Run these to test if everything is working:

```bash
# Run the app
flutter run

# Check logs for any permission errors
flutter logs
```

## Emergency Temporary Fix

If you need immediate access, you can temporarily use permissive rules (⚠️ NOT for production):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**Remember to revert to secure rules after testing!**

## Getting Help

If issues persist:
1. Check the browser console for detailed error messages
2. Look at Flutter console output for specific error codes
3. Verify your Firebase project settings
4. Ensure you're using the correct Firebase project

The fixes in this update should resolve most permission issues. Deploy the updated rules and indexes, then test the application.

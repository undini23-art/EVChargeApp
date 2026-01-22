import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../main.dart';

/// Simple auth user model mapping Google/Apple data into the existing UserProfile.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  // Provide client IDs when needed (especially on iOS/macOS). Replace placeholders.
  // For iOS/macOS, use the reversed client ID (from Google Cloud OAuth client).
  static const String? kGoogleClientId = null; // e.g., 'YOUR_IOS_CLIENT_ID.apps.googleusercontent.com'

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kGoogleClientId,
    scopes: <String>[
      'email',
      'profile',
    ],
  );

  /// Signs in with Google.
  /// Returns the created/loaded UserProfile or throws on failure.
  /// 
  /// NOTE: If Google OAuth is not configured (no client ID / URL scheme),
  /// this will create a demo Google user so the app doesn't hang.
  Future<UserProfile> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn().timeout(
        const Duration(seconds: 10),
        onTimeout: () => null,
      );
      
      if (account == null) {
        // OAuth not configured or user canceled – create demo user
        return _createDemoUser('Google');
      }

      final displayName = account.displayName ?? 'Google User';
      final email = account.email;
      final initials = _initialsFromName(displayName);

      // Find existing local profile or create a new one.
      final existingIndex = availableProfiles.indexWhere((p) => p.email == email);
      UserProfile profile;
      if (existingIndex >= 0) {
        profile = availableProfiles[existingIndex];
      } else {
        profile = UserProfile(
          name: displayName,
          email: email,
          password: '', // passwordless for OAuth
          initials: initials,
          walletBalance: 0.0,
          vehicle: 'No vehicle added',
          licensePlate: '',
        );
        availableProfiles.add(profile);
        await saveUserProfiles();
      }

      // Set current user and restore session.
      currentUser.value = profile;
      await loadCurrentChargingSessionForUser(profile.email);

      return profile;
    } catch (e) {
      // If OAuth fails (not configured), fallback to demo user
      return _createDemoUser('Google');
    }
  }

  /// Signs in with Apple (iOS 13+/macOS only). On Android, this will throw.
  /// 
  /// NOTE: If Apple Sign-In is not configured or unavailable,
  /// this will create a demo Apple user so the app doesn't hang.
  Future<UserProfile> signInWithApple() async {
    try {
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        // Not available on this platform – create demo user
        return _createDemoUser('Apple');
      }

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw StateError('Apple sign-in timed out'),
      );

      final email = credential.email ?? _emailFromAppleUserId(credential.userIdentifier);
      final displayName = _composeAppleDisplayName(credential);
      final initials = _initialsFromName(displayName);

      // Find existing local profile or create a new one.
      final existingIndex = availableProfiles.indexWhere((p) => p.email == email);
      UserProfile profile;
      if (existingIndex >= 0) {
        profile = availableProfiles[existingIndex];
      } else {
        profile = UserProfile(
          name: displayName,
          email: email,
          password: '',
          initials: initials,
          walletBalance: 0.0,
          vehicle: 'No vehicle added',
          licensePlate: '',
        );
        availableProfiles.add(profile);
        await saveUserProfiles();
      }

      currentUser.value = profile;
      await loadCurrentChargingSessionForUser(profile.email);

      return profile;
    } catch (e) {
      // If Apple sign-in fails (not configured), fallback to demo user
      return _createDemoUser('Apple');
    }
  }

  /// Creates a demo user when OAuth is not configured.
  Future<UserProfile> _createDemoUser(String provider) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final email = '${provider.toLowerCase()}_demo_$timestamp@evcharge.demo';
    final name = '$provider User';
    final initials = _initialsFromName(name);

    final profile = UserProfile(
      name: name,
      email: email,
      password: '',
      initials: initials,
      walletBalance: 500.0, // Give demo user some balance
      vehicle: 'Tesla Model 3',
      licensePlate: 'DEMO-EV',
    );

    availableProfiles.add(profile);
    await saveUserProfiles();

    currentUser.value = profile;
    return profile;
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    // Clear current user only; data stays persisted.
    currentUser.value = null;
  }

  String _initialsFromName(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    String initials = parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '';
    if (parts.length > 1 && parts[1].isNotEmpty) {
      initials += parts[1][0].toUpperCase();
    }
    return initials;
  }

  String _composeAppleDisplayName(AuthorizationCredentialAppleID cred) {
    final given = cred.givenName?.trim();
    final family = cred.familyName?.trim();
    if ((given?.isNotEmpty ?? false) || (family?.isNotEmpty ?? false)) {
      return [given, family].whereType<String>().where((e) => e.isNotEmpty).join(' ');
    }
    // If name is not provided (Apple may only provide it the first time), fallback.
    return 'Apple User';
  }

  String _emailFromAppleUserId(String? userId) {
    if (userId == null || userId.isEmpty) {
      // Fallback anonymous email.
      return 'apple_user_${DateTime.now().millisecondsSinceEpoch}@example.com';
    }
    // Create a stable pseudo-email when Apple does not provide email again.
    return 'apple_$userId@priv.apple.local';
  }
}

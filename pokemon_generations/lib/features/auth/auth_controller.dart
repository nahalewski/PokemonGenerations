import 'dart:convert';
import 'package:image_picker/image_picker.dart';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/user_profile.dart';
import '../../core/settings/app_settings_controller.dart';
import '../../data/services/api_client.dart';
import '../roster/roster_provider.dart';
import '../roster/teams_provider.dart';
import '../inventory/inventory_provider.dart';
import '../social/social_controller.dart';
import '../../data/providers.dart';

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  static const _profileStorageKey = 'auth.user_profile';
  static const _authenticatedStorageKey = 'auth.is_authenticated';

  SharedPreferences? _prefs;

  @override
  AuthState build() {
    _load();
    return const AuthState(isInitialized: false);
  }

  Future<void> _load() async {
    _prefs ??= await SharedPreferences.getInstance();
    final encodedProfile = _prefs!.getString(_profileStorageKey);
    final isAuthenticated = _prefs!.getBool(_authenticatedStorageKey) ?? false;

    state = AuthState(
      isInitialized: true,
      profile: encodedProfile == null
          ? null
          : UserProfile.decode(encodedProfile),
      isAuthenticated: encodedProfile == null ? false : isAuthenticated,
    );

    // If already authenticated, trigger a background sync for the roster
    if (state.isAuthenticated && state.profile != null) {
      ref
          .read(rosterRepositoryProvider)
          .syncWithCloud(username: state.profile!.username)
          .then((_) {
            ref.invalidate(rosterProvider);
          })
          .catchError((e) {
            // ignore: avoid_print
            print('[AUTH] Initial load sync failed: $e');
            return null;
          });
    }
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String username,
    required String passcode,
  }) async {
    _prefs ??= await SharedPreferences.getInstance();

    final normalizedUsername = username.trim().toLowerCase();
    final profile = UserProfile(
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      username: normalizedUsername,
      passcodeHash: _hashPasscode(normalizedUsername, passcode),
    );

    // 1. Save to Server
    final baseUrl = ref.read(backendBaseUrlProvider);
    final remoteProfile = await ref
        .read(apiClientProvider.notifier)
        .registerRemote(baseUrl, profile);

    // 2. Save Locally (Remote profile might have server-side corrections/IDs if implemented)
    final profileToSave = remoteProfile ?? profile;
    await _prefs!.setString(_profileStorageKey, profileToSave.encode());
    await _prefs!.setBool(_authenticatedStorageKey, true);

    state = AuthState(
      isInitialized: true,
      profile: profileToSave,
      isAuthenticated: true,
    );
  }

  Future<bool> login({
    required String username,
    required String passcode,
  }) async {
    final normalizedUsername = username.trim().toLowerCase();
    final passcodeHash = _hashPasscode(normalizedUsername, passcode);

    // 1. Check Local Profile First
    var profile = state.profile;

    if (profile == null || profile.username != normalizedUsername) {
      // 1. Attempt Remote Recovery if local is missing or different
      final baseUrl = ref.read(backendBaseUrlProvider);
      profile = await ref
          .read(apiClientProvider.notifier)
          .loginRemote(baseUrl, normalizedUsername, passcodeHash);

      if (profile == null) return false;

      // Persist the recovered profile locally
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs!.setString(_profileStorageKey, profile.encode());

      // We recovered a profile, trigger a full data re-fetch
      ref.invalidate(rosterProvider);
    } else {
      // Local check
      final isValid =
          normalizedUsername == profile.username &&
          passcodeHash == profile.passcodeHash;

      if (!isValid) {
        // Fallback: If local check fails, try remote just in case the server logic or user's passcode changed
        final baseUrl = ref.read(backendBaseUrlProvider);
        final remoteProfile = await ref
            .read(apiClientProvider.notifier)
            .loginRemote(baseUrl, normalizedUsername, passcodeHash);
        
        if (remoteProfile == null) return false;
        
        profile = remoteProfile;
        // Update local storage with fresh data from server
        _prefs ??= await SharedPreferences.getInstance();
        await _prefs!.setString(_profileStorageKey, profile.encode());
      }
    }


    await _prefs!.setBool(_authenticatedStorageKey, true);
    
    final mustChange = profile.forcePasscodeChange;
    state = state.copyWith(
      profile: profile, 
      isAuthenticated: !mustChange, // Don't fully authenticate if reset required
      mustChangePasscode: mustChange,
    );

    // Perform sync in background so login feels immediate
    _syncInBackground(profile.username);

    return true;
  }

  Future<void> _syncInBackground(String username) async {
    try {
      await ref.read(rosterRepositoryProvider).syncWithCloud(username: username);
      ref.invalidate(rosterProvider);
      ref.invalidate(teamsNotifierProvider);
    } catch (e) {
      print('[AUTH] Background sync failed: $e');
    }
  }

  Future<void> signOut() async {
    _prefs ??= await SharedPreferences.getInstance();

    // 1. Clear Local Storage
    await _prefs!.setBool(_authenticatedStorageKey, false);
    await _prefs!.remove(_profileStorageKey);

    // 2. Clear State
    state = state.copyWith(
      isAuthenticated: false,
      profile: null,
      keepProfile: false,
    );

    // 3. Invalidate Shared Data
    ref.invalidate(rosterProvider);
    ref.invalidate(inventoryProvider);
    ref.invalidate(socialControllerProvider);
  }

  void updateProfile(UserProfile profile) {
    state = state.copyWith(profile: profile);
    _prefs?.setString(_profileStorageKey, profile.encode());
  }

  Future<bool> resetPasscode(String newPasscode) async {
    if (state.profile == null) return false;
    
    final profile = state.profile!;
    final normalizedUsername = profile.username;
    final newHash = _hashPasscode(normalizedUsername, newPasscode);
    
    final updatedProfile = profile.copyWith(
      passcodeHash: newHash,
      forcePasscodeChange: false,
    );

    // 1. Update Server
    final baseUrl = ref.read(backendBaseUrlProvider);
    final success = await ref.read(apiClientProvider.notifier).updateOnlineStatus(
      baseUrl,
      username: normalizedUsername,
      displayName: profile.displayName,
      forcePasscodeChange: false,
    );

    if (success) {
      // 2. Update Local
      updateProfile(updatedProfile);
      state = state.copyWith(
        isAuthenticated: true,
        mustChangePasscode: false,
      );
      return true;
    }
    return false;
  }

  Future<void> updateProfilePhoto(XFile imageFile) async {
    if (state.profile == null) return;

    final baseUrl = ref.read(backendBaseUrlProvider);
    final imageUrl = await ref
        .read(apiClientProvider.notifier)
        .uploadProfilePicture(baseUrl, state.profile!.username, imageFile);

    if (imageUrl != null) {
      final updatedProfile = state.profile!.copyWith(profileImageUrl: imageUrl);
      updateProfile(updatedProfile);
      
      // Also notify SocialController to refresh current user photo in social list
      ref.read(socialControllerProvider.notifier).syncAll();
    }
  }

  String _hashPasscode(String username, String passcode) {
    final payload = '$username::$passcode::rosteriq';
    return sha256.convert(utf8.encode(payload)).toString();
  }
}

class AuthState {
  const AuthState({
    required this.isInitialized,
    this.profile,
    this.isAuthenticated = false,
    this.mustChangePasscode = false,
  });

  final bool isInitialized;
  final UserProfile? profile;
  final bool isAuthenticated;
  final bool mustChangePasscode;

  bool get hasProfile => profile != null;

  AuthState copyWith({
    bool? isInitialized,
    UserProfile? profile,
    bool? isAuthenticated,
    bool? mustChangePasscode,
    bool keepProfile = true,
  }) {
    return AuthState(
      isInitialized: isInitialized ?? this.isInitialized,
      profile: keepProfile ? (profile ?? this.profile) : profile,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      mustChangePasscode: mustChangePasscode ?? this.mustChangePasscode,
    );
  }
}

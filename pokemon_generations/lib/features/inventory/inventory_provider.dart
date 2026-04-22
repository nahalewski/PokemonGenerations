import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../auth/auth_controller.dart';
import '../social/social_controller.dart';
import '../../domain/models/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'inventory_provider.g.dart';

@riverpod
class Inventory extends _$Inventory {
  static const _profileStorageKey = 'auth.user_profile';

  @override
  Map<String, int> build() {
    final authState = ref.watch(authControllerProvider);
    return authState.profile?.inventory ?? const {'potion': 5, 'revive': 3};
  }

  Future<void> useItem(String itemId) async {
    final currentCount = state[itemId] ?? 0;
    if (currentCount <= 0) return;

    final newState = {
      ...state,
      itemId: currentCount - 1,
    };
    
    state = newState;
    await _persist(newState);
  }

  Future<void> addItem(String itemId, int count) async {
    final currentCount = state[itemId] ?? 0;
    final newState = {
      ...state,
      itemId: currentCount + count,
    };
    
    state = newState;
    await _persist(newState);
  }

  Future<void> _persist(Map<String, int> inventory) async {
    final authController = ref.read(authControllerProvider.notifier);
    final currentProfile = ref.read(authControllerProvider).profile;
    
    if (currentProfile == null) return;

    final updatedProfile = currentProfile.copyWith(inventory: inventory);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileStorageKey, updatedProfile.encode());
    
    authController.updateProfile(updatedProfile);
    
    // Trigger remote sync back to the new individual user.json
    ref.read(socialControllerProvider.notifier).updateStatus();
  }
}

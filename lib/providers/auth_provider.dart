import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authProvider = StreamProvider<User?>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange.map(
    (event) => event.session?.user,
  );
});

final userRoleProvider = FutureProvider<String>((ref) async {
  final user = ref.watch(authProvider).value;
  if (user == null) {
    // Check if we're in test admin mode (no user but navigating from admin test button)
    // For now, we'll use a simple approach - check navigation history or use a flag
    return 'eleitor';
  }

  // For testing purposes, check if we're in test mode
  if (user.email == 'admin@ipsantarem.pt') {
    return 'administrador';
  }

  try {
    final response =
        await Supabase.instance.client
            .from('perfis')
            .select('cargo_id')
            .eq('id', user.id)
            .single();

    if (response['cargo_id'] != null) {
      final cargoResponse =
          await Supabase.instance.client
              .from('cargo')
              .select('nome')
              .eq('id', response['cargo_id'])
              .single();

      return cargoResponse['nome'] as String;
    }
  } catch (e) {
    // If database query fails, default to eleitor
    return 'eleitor';
  }

  return 'eleitor';
});

// Test admin provider for when no user is logged in but we want admin features
// Note: StateProvider is from flutter_riverpod, but we're using riverpod directly
// This is a simple boolean flag for testing

final effectiveUserRoleProvider = FutureProvider<String>((ref) async {
  // For test admin mode, we can check if we're in the test admin screen
  // For now, return 'eleitor' as default, but the test admin screen handles admin features directly
  return ref.watch(userRoleProvider).value ?? 'eleitor';
});

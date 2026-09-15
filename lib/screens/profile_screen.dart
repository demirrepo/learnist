import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red, // Matching your mockup vibe
          ),
          onPressed: () async {
            await Supabase.instance.client.auth.signOut();
            if (context.mounted) {
              context.go('/auth'); // Force route back to auth
            }
          },
          child: const Text('Sign out', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class GroupPhoto {
  final SupabaseClient _client = Supabase.instance.client;

  Future<String?> getSignedGroupPhotoUrl(String path) async {
    try {
      final response = await _client.storage
          .from('group-photo')
          .createSignedUrl(path, 60 * 60); 
      return response; 
    } catch (e) {
      debugPrint('Error getting signed URL for group photo: $e');
      return null;
    }
  }
}

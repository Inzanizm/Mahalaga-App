import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class MessMedia{
  final supabase = Supabase.instance.client;

  Future<String?> getMessMedia(String path) async {
    try {
      final supabase = Supabase.instance.client; // <- This line is important
      final response = await supabase.storage
          .from('message-medias')
          .createSignedUrl(path, 60 * 60); // 1 hour

      return response;
    } catch (e) {
      debugPrint('Error getting signed URL: $e');
      return null;
    }
  }
}
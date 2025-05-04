import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class PfpImage {
  final supabase = Supabase.instance.client;

  Future<String?> getSignedPfpUrl(String path) async {
    try {
      final response = await supabase.storage
          .from('pfp-images')
          .createSignedUrl(path, 60 * 60); // 1 hour
      return response;
    } catch (e) {
      debugPrint('Error getting signed PFP URL: $e');
      return null;
    }
  }
}



import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';


class SupabaseStorageService {
  final supabase = Supabase.instance.client;

  Future<String?> getSignedImageUrl(String path) async {
  try {
    final supabase = Supabase.instance.client; // <- This line is important
    final response = await supabase.storage
        .from('place-cover-images')
        .createSignedUrl(path, 60 * 60); // 1 hour

    return response;
  } catch (e) {
    debugPrint('Error getting signed URL: $e');
    return null;
  }
}

}





//to use: import 'package:mahalaga_pcapp_map/utils/cover_images_supabase.dart';
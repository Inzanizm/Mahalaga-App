import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class PetService {
  static final _supabase = Supabase.instance.client;

  static Future<List<Map<String, dynamic>>> fetchAdoptablePets() async {
    try {
      final response = await _supabase
          .from('adoptable_pets')
          .select()
          .order('name', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching adoptable pets: $e');
      return [];
    }
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/staff_model.dart';

class StaffService {
  StaffService._();
  static final instance = StaffService._();

  final _client = Supabase.instance.client;

  Future<List<Staff>> getStaff() async {
    final response = await _client.from('doctors').select().order('created_at');
    return (response as List).map((e) => Staff.fromJson(e)).toList();
  }

  Future<Staff> createStaff(Staff staff) async {
    final response = await _client
        .from('doctors')
        .insert(staff.toJson())
        .select()
        .single();
    return Staff.fromJson(response);
  }

  Future<Staff> updateStaff(Staff staff) async {
    final response = await _client
        .from('doctors')
        .update(staff.toJson())
        .eq('id', staff.id)
        .select()
        .single();
    return Staff.fromJson(response);
  }

  Future<void> deleteStaff(String id) async {
    await _client.from('doctors').delete().eq('id', id);
  }
}

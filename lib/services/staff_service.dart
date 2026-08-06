import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/staff_model.dart';

class StaffService {
  StaffService._();
  static final instance = StaffService._();

  final _client = Supabase.instance.client;

  /// Active staff only. Deactivated rows are kept so their visit and
  /// appointment history keeps resolving, but they must not show up in
  /// Manage Staff or in doctor pickers.
  Future<List<Staff>> getStaff() async {
    final response = await _client
        .from('doctors')
        .select()
        .eq('is_active', true)
        .order('created_at');
    return (response as List).map((e) => Staff.fromJson(e)).toList();
  }

  Future<Staff> createStaff(Staff staff) async {
    // Set explicitly rather than relying on a column default — getStaff()
    // filters on is_active, so a null here would hide the new member the
    // moment they are created.
    final response = await _client
        .from('doctors')
        .insert({...staff.toJson(), 'is_active': true})
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

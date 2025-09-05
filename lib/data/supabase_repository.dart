import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase_client.dart';
import '../models/group.dart';
import '../models/player.dart';
import '../models/training_session.dart';
import '../models/attendance.dart';
import 'dart:typed_data';

class SupabaseRepository {
  final SupabaseClient _client;
  SupabaseRepository() : _client = SupabaseManager.client;

  Future<List<Group>> getGroups() async {
    final data = await _client.from('groups').select('*').order('name');
    return (data as List)
        .map((e) => Group.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Group> createGroup({
    required String name,
    String? description,
    String color = '#3B82F6',
  }) async {
    final data = await _client
        .from('groups')
        .insert({'name': name, 'description': description, 'color': color})
        .select()
        .single();
    return Group.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> updateGroup({
    required String id,
    String? name,
    String? description,
    String? color,
  }) async {
    final payload = <String, dynamic>{};
    if (name != null) payload['name'] = name;
    if (description != null) payload['description'] = description;
    if (color != null) payload['color'] = color;
    if (payload.isEmpty) return;
    await _client.from('groups').update(payload).eq('id', id);
  }

  Future<void> deleteGroup(String id) async {
    await _client.from('groups').delete().eq('id', id);
  }

  Future<List<Player>> getPlayers({String? groupId}) async {
    dynamic data;
    if (groupId != null) {
      data = await _client
          .from('players')
          .select('*')
          .eq('group_id', groupId)
          .order('total_points', ascending: false);
    } else {
      data = await _client
          .from('players')
          .select('*')
          .order('total_points', ascending: false);
    }
    return (data as List)
        .map((e) => Player.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<TrainingSession>> getTrainingsInRange(
    DateTime start,
    DateTime end,
  ) async {
    final startStr = _formatDate(start);
    final endStr = _formatDate(end);
    final data = await _client
        .from('training_sessions')
        .select('*')
        .gte('date', startStr)
        .lte('date', endStr)
        .order('date');
    return (data as List)
        .map((e) => TrainingSession.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<Attendance>> getAttendanceForSessions(
    List<String> sessionIds,
  ) async {
    if (sessionIds.isEmpty) return [];
    final data = await _client
        .from('attendance')
        .select('*')
        .inFilter('session_id', sessionIds);
    return (data as List)
        .map((e) => Attendance.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<Attendance>> getAttendanceForSession(String sessionId) async {
    final data = await _client
        .from('attendance')
        .select('*')
        .eq('session_id', sessionId);
    return (data as List)
        .map((e) => Attendance.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<TrainingSession> createTrainingSession({
    required DateTime date,
    required String title,
  }) async {
    final dateStr = _formatDate(date);
    final data = await _client
        .from('training_sessions')
        .insert({'date': dateStr, 'title': title})
        .select()
        .single();
    return TrainingSession.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> insertAttendanceBatch({
    required String sessionId,
    required List<Map<String, dynamic>> records,
  }) async {
    if (records.isEmpty) return;
    final payload = records
        .map(
          (r) => {
            'player_id': r['player_id'],
            'session_id': sessionId,
            'attended': r['attended'] ?? false,
            'points': r['points'] ?? 0,
          },
        )
        .toList();
    await _client.from('attendance').insert(payload);
  }

  Future<void> updateAttendancePoints({
    required String sessionId,
    required String playerId,
    required int points,
  }) async {
    await _client
        .from('attendance')
        .update({'points': points, 'attended': points > 0})
        .eq('session_id', sessionId)
        .eq('player_id', playerId);
  }

  Future<void> updateTrainingDate({
    required String sessionId,
    required DateTime date,
  }) async {
    await _client
        .from('training_sessions')
        .update({'date': _formatDate(date)})
        .eq('id', sessionId);
  }

  Future<void> deleteTrainingSession(String sessionId) async {
    // First delete attendance, then session (safety even with CASCADE)
    await _client.from('attendance').delete().eq('session_id', sessionId);
    await _client.from('training_sessions').delete().eq('id', sessionId);
  }

  Future<Player> addPlayer({
    required String name,
    String? birthDate,
    required String login,
    required String password,
    String? groupId,
  }) async {
    final data = await _client
        .from('players')
        .insert({
          'name': name,
          'birth_date': birthDate,
          'login': login,
          'password': password,
          'group_id': groupId,
        })
        .select()
        .single();
    return Player.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> updatePlayer({
    required String id,
    String? name,
    String? birthDate,
    String? login,
    String? password,
    String? avatarUrl,
    String? groupId,
  }) async {
    final payload = <String, dynamic>{};
    if (name != null) payload['name'] = name;
    if (birthDate != null) payload['birth_date'] = birthDate;
    if (login != null) payload['login'] = login;
    if (password != null) payload['password'] = password;
    if (avatarUrl != null) payload['avatar_url'] = avatarUrl;
    if (groupId != null) payload['group_id'] = groupId;
    if (payload.isEmpty) return;
    await _client.from('players').update(payload).eq('id', id);
  }

  Future<void> removePlayerFromGroup(String playerId) async {
    await _client.from('players').update({'group_id': null}).eq('id', playerId);
  }

  Future<String> uploadAvatar({
    required String playerId,
    required Uint8List bytes,
    required String contentType,
  }) async {
    final path = 'avatars/${playerId}_${DateTime.now().millisecondsSinceEpoch}';
    await _client.storage
        .from('avatars')
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType),
        );
    final res = _client.storage.from('avatars').getPublicUrl(path);
    return res;
  }

  String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

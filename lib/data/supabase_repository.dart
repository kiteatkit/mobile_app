import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase_client.dart';
import '../models/group.dart';
import '../models/player.dart';
import '../models/training_session.dart';
import '../models/attendance.dart';
import '../models/training_schedule.dart';
import '../models/scheduled_training.dart';
import 'dart:typed_data';

class SupabaseRepository {
  final SupabaseClient _client;
  SupabaseRepository() : _client = SupabaseManager.client;

  // Кэш для часто запрашиваемых данных
  List<Player>? _cachedPlayers;
  List<Group>? _cachedGroups;
  DateTime? _lastCacheUpdate;
  static const Duration _cacheTimeout = Duration(minutes: 5);

  Future<List<Group>> getGroups() async {
    if (_cachedGroups != null &&
        _lastCacheUpdate != null &&
        DateTime.now().difference(_lastCacheUpdate!) < _cacheTimeout) {
      return _cachedGroups!;
    }

    final data = await _client.from('groups').select('*').order('name');
    final groups = (data as List)
        .map((e) => Group.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    _cachedGroups = groups;
    _lastCacheUpdate = DateTime.now();
    return groups;
  }

  Future<Group> createGroup({
    required String name,
    required String color,
  }) async {
    try {
      // Проверяем подключение к интернету
      await _checkInternetConnection();

      final group = await _retryOperation(() async {
        final data = await _client
            .from('groups')
            .insert({'name': name, 'color': color})
            .select()
            .single();
        return Group.fromJson(Map<String, dynamic>.from(data));
      });

      _invalidateCache();
      return group;
    } catch (e) {
      await _logError('создание команды', e);
      throw Exception('Ошибка создания команды: $e');
    }
  }

  Future<void> updateGroup({
    required String id,
    String? name,
    String? color,
  }) async {
    final payload = <String, dynamic>{};
    if (name != null) payload['name'] = name;
    if (color != null) payload['color'] = color;
    if (payload.isEmpty) return;
    await _client.from('groups').update(payload).eq('id', id);
  }

  Future<void> deleteGroup(String id) async {
    try {
      // Сначала удаляем всех игроков из группы (устанавливаем group_id в null)
      await _client
          .from('players')
          .update({'group_id': null})
          .eq('group_id', id);

      // Затем удаляем саму группу
      await _client.from('groups').delete().eq('id', id);

      // Очищаем кэш
      _invalidateCache();
    } catch (e) {
      throw Exception('Не удалось удалить группу: ${e.toString()}');
    }
  }

  Future<List<Player>> getPlayers({String? groupId}) async {
    // Если запрашиваем всех игроков, используем кэш
    if (groupId == null) {
      if (_cachedPlayers != null &&
          _lastCacheUpdate != null &&
          DateTime.now().difference(_lastCacheUpdate!) < _cacheTimeout) {
        return _cachedPlayers!;
      }
    }

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

    final players = (data as List)
        .map((e) => Player.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    // Кэшируем только если запрашиваем всех игроков
    if (groupId == null) {
      _cachedPlayers = players;
      _lastCacheUpdate = DateTime.now();
    }

    return players;
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
    String? groupId,
    String? address,
  }) async {
    try {
      await _checkInternetConnection();

      final dateStr = _formatDate(date);
      final title =
          address ??
          '${date.day}.${date.month}.${date.year}'; // Используем адрес или дату как название
      final data = await _client
          .from('training_sessions')
          .insert({'date': dateStr, 'title': title})
          .select()
          .single();

      final trainingSession = TrainingSession.fromJson(
        Map<String, dynamic>.from(data),
      );

      // Автоматически создаем записи посещения для всех игроков с 0 баллами
      final players = groupId != null
          ? await getPlayers(groupId: groupId)
          : await getPlayers();
      if (players.isNotEmpty) {
        final attendanceRecords = players
            .map(
              (player) => {
                'session_id': trainingSession.id,
                'player_id': player.id,
                'points': 0,
                'attended': false,
              },
            )
            .toList();

        await insertAttendanceBatch(
          sessionId: trainingSession.id,
          records: attendanceRecords,
        );
      }

      _invalidateCache();
      return trainingSession;
    } catch (e) {
      print('Ошибка при создании тренировки: $e');
      rethrow;
    }
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
    try {
      await _checkInternetConnection();

      // Сначала проверяем, существует ли запись
      final existing = await _client
          .from('attendance')
          .select('id')
          .eq('session_id', sessionId)
          .eq('player_id', playerId)
          .maybeSingle();

      if (existing != null) {
        // Обновляем существующую запись
        await _client
            .from('attendance')
            .update({'points': points, 'attended': points > 0})
            .eq('session_id', sessionId)
            .eq('player_id', playerId);
      } else {
        // Создаем новую запись
        await _client.from('attendance').insert({
          'session_id': sessionId,
          'player_id': playerId,
          'points': points,
          'attended': points > 0,
        });
      }

      _invalidateCache();
    } catch (e) {
      print('Ошибка при обновлении баллов: $e');
      rethrow;
    }
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
    try {
      // Проверяем подключение к интернету
      await _checkInternetConnection();

      final player = await _retryOperation(() async {
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
      });

      _invalidateCache();
      return player;
    } catch (e) {
      await _logError('создание игрока', e);
      throw Exception('Ошибка создания игрока: $e');
    }
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
    try {
      final payload = <String, dynamic>{};
      if (name != null) payload['name'] = name;
      if (birthDate != null) payload['birth_date'] = birthDate;
      if (login != null) payload['login'] = login;
      if (password != null) payload['password'] = password;
      if (avatarUrl != null) payload['avatar_url'] = avatarUrl;
      // Всегда обновляем group_id, даже если он null (для удаления из группы)
      payload['group_id'] = groupId;
      if (payload.isEmpty) return;
      await _client.from('players').update(payload).eq('id', id);
      _invalidateCache();
    } catch (e) {
      throw Exception('Ошибка обновления игрока: $e');
    }
  }

  Future<void> removePlayerFromGroup(String playerId) async {
    await _client.from('players').update({'group_id': null}).eq('id', playerId);
  }

  Future<void> deletePlayer(String playerId) async {
    try {
      // Удаляем связанные записи в правильном порядке
      // Сначала удаляем записи посещаемости
      await _client.from('attendance').delete().eq('player_id', playerId);

      // Затем удаляем самого игрока
      await _client.from('players').delete().eq('id', playerId);

      // Очищаем кэш игроков
      _cachedPlayers = null;
      _lastCacheUpdate = null;
    } catch (e) {
      // Перебрасываем ошибку с более понятным сообщением
      throw Exception('Не удалось удалить игрока: ${e.toString()}');
    }
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

  // Методы для работы с расписанием тренировок
  Future<List<TrainingSchedule>> getTrainingSchedules({String? groupId}) async {
    dynamic data;
    if (groupId != null) {
      data = await _client
          .from('training_schedules')
          .select('*')
          .eq('group_id', groupId)
          .order('created_at', ascending: false);
    } else {
      data = await _client
          .from('training_schedules')
          .select('*')
          .order('created_at', ascending: false);
    }
    return (data as List)
        .map((e) => TrainingSchedule.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> createTrainingSchedule({
    required String groupId,
    required String title,
    required List<int> weekdays,
    required String startTime,
    required String endTime,
  }) async {
    // Сначала создаем расписание
    await _client.from('training_schedules').insert({
      'group_id': groupId,
      'title': title,
      'weekdays': weekdays,
      'start_time': startTime,
      'end_time': endTime,
    });

    // Создаем запланированные тренировки на ближайшие 4 недели
    final now = DateTime.now();
    final endDate = now.add(const Duration(days: 28)); // 4 недели вперед

    for (int week = 0; week < 4; week++) {
      for (final weekday in weekdays) {
        // Вычисляем дату для конкретного дня недели
        final daysUntilWeekday = (weekday - now.weekday) % 7;
        final targetDate = now.add(
          Duration(days: daysUntilWeekday + (week * 7)),
        );

        // Проверяем, что дата не в прошлом и не превышает 4 недели
        if (targetDate.isAfter(now.subtract(const Duration(days: 1))) &&
            targetDate.isBefore(endDate)) {
          // Проверяем, не существует ли уже тренировка или запланированная тренировка на этот день
          final existingSessions = await getTrainingsInRange(
            DateTime(targetDate.year, targetDate.month, targetDate.day),
            DateTime(targetDate.year, targetDate.month, targetDate.day, 23, 59),
          );

          final hasExistingSession = existingSessions.any((session) {
            final sessionDate = DateTime.parse(session.date);
            return sessionDate.year == targetDate.year &&
                sessionDate.month == targetDate.month &&
                sessionDate.day == targetDate.day;
          });

          if (!hasExistingSession) {
            // Создаем обычную тренировку с нулевыми баллами для всех игроков
            await createTrainingSession(
              date: targetDate,
              groupId: groupId,
              address: title,
            );
          }
        }
      }
    }

    _invalidateCache();
  }

  Future<void> updateTrainingSchedule({
    required String id,
    String? title,
    List<int>? weekdays,
    String? startTime,
    String? endTime,
  }) async {
    final payload = <String, dynamic>{};
    if (title != null) payload['title'] = title;
    if (weekdays != null) payload['weekdays'] = weekdays;
    if (startTime != null) payload['start_time'] = startTime;
    if (endTime != null) payload['end_time'] = endTime;
    if (payload.isEmpty) return;

    await _client.from('training_schedules').update(payload).eq('id', id);
    _invalidateCache();
  }

  Future<void> deleteTrainingSchedule(String id) async {
    await _client.from('training_schedules').delete().eq('id', id);
    _invalidateCache();
  }

  // Методы для работы с запланированными тренировками
  Future<List<ScheduledTraining>> getScheduledTrainings({
    String? groupId,
  }) async {
    dynamic data;
    if (groupId != null) {
      data = await _client
          .from('scheduled_trainings')
          .select('*')
          .eq('group_id', groupId)
          .order('date', ascending: true);
    } else {
      data = await _client
          .from('scheduled_trainings')
          .select('*')
          .order('date', ascending: true);
    }
    return (data as List)
        .map((e) => ScheduledTraining.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<ScheduledTraining> createScheduledTraining({
    required String groupId,
    required DateTime date,
    required String title,
    required String startTime,
    required String endTime,
    required String scheduleId,
  }) async {
    final data = await _client
        .from('scheduled_trainings')
        .insert({
          'group_id': groupId,
          'date': _formatDate(date),
          'title': title,
          'start_time': startTime,
          'end_time': endTime,
          'schedule_id': scheduleId,
        })
        .select()
        .single();

    return ScheduledTraining.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> deleteScheduledTraining(String id) async {
    await _client.from('scheduled_trainings').delete().eq('id', id);
    _invalidateCache();
  }

  Future<void> updateScheduledTrainingDate({
    required String id,
    required DateTime newDate,
  }) async {
    await _client
        .from('scheduled_trainings')
        .update({'date': _formatDate(newDate)})
        .eq('id', id);
    _invalidateCache();
  }

  // Создание тренировки из запланированной
  Future<TrainingSession> createTrainingFromScheduled({
    required ScheduledTraining scheduledTraining,
  }) async {
    try {
      await _checkInternetConnection();

      final data = await _client
          .from('training_sessions')
          .insert({
            'date': scheduledTraining.date,
            'title': scheduledTraining.title,
            'group_id': scheduledTraining.group_id,
          })
          .select()
          .single();

      final trainingSession = TrainingSession.fromJson(
        Map<String, dynamic>.from(data),
      );

      // Автоматически создаем записи посещения для всех игроков группы с 1 баллом
      final players = await getPlayers(groupId: scheduledTraining.group_id);
      if (players.isNotEmpty) {
        final attendanceRecords = players
            .map(
              (player) => {
                'session_id': trainingSession.id,
                'player_id': player.id,
                'points': 1,
                'attended': true,
              },
            )
            .toList();

        await insertAttendanceBatch(
          sessionId: trainingSession.id,
          records: attendanceRecords,
        );
      }

      // Удаляем запланированную тренировку после создания реальной
      await deleteScheduledTraining(scheduledTraining.id);

      _invalidateCache();
      return trainingSession;
    } catch (e) {
      print('Ошибка при создании тренировки из запланированной: $e');
      rethrow;
    }
  }

  // Создание тренировки на конкретную дату на основе расписания
  Future<TrainingSession> createTrainingFromSchedule({
    required String groupId,
    required DateTime date,
  }) async {
    try {
      await _checkInternetConnection();

      // Получаем расписание для группы
      final schedules = await getTrainingSchedules(groupId: groupId);

      if (schedules.isEmpty) {
        throw Exception('Нет расписания для группы');
      }

      // Находим подходящее расписание для дня недели
      final weekday = date.weekday;
      final suitableSchedule = schedules.firstWhere(
        (schedule) => schedule.weekdays.contains(weekday),
        orElse: () =>
            schedules.first, // Если нет точного совпадения, берем первое
      );

      final dateStr = _formatDate(date);
      final title =
          '${suitableSchedule.title} - ${date.day}.${date.month}.${date.year}';

      final data = await _client
          .from('training_sessions')
          .insert({'date': dateStr, 'title': title, 'group_id': groupId})
          .select()
          .single();

      final trainingSession = TrainingSession.fromJson(
        Map<String, dynamic>.from(data),
      );

      // Автоматически создаем записи посещения для всех игроков группы с 1 баллом
      final players = await getPlayers(groupId: groupId);
      if (players.isNotEmpty) {
        final attendanceRecords = players
            .map(
              (player) => {
                'session_id': trainingSession.id,
                'player_id': player.id,
                'points': 1,
                'attended': true,
              },
            )
            .toList();

        await insertAttendanceBatch(
          sessionId: trainingSession.id,
          records: attendanceRecords,
        );
      }

      _invalidateCache();
      return trainingSession;
    } catch (e) {
      print('Ошибка при создании тренировки из расписания: $e');
      rethrow;
    }
  }

  // Автоматическое создание тренировок на основе расписания
  Future<void> generateTrainingSessionsFromSchedule({
    required String groupId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final schedules = await getTrainingSchedules(groupId: groupId);

    for (final schedule in schedules) {
      DateTime currentDate = startDate;

      while (currentDate.isBefore(endDate) ||
          currentDate.isAtSameMomentAs(endDate)) {
        // Проверяем, является ли текущий день днем недели для тренировки
        if (schedule.weekdays.contains(currentDate.weekday)) {
          // Проверяем, не существует ли уже тренировка на этот день
          final existingSessions = await getTrainingsInRange(
            DateTime(currentDate.year, currentDate.month, currentDate.day),
            DateTime(
              currentDate.year,
              currentDate.month,
              currentDate.day,
              23,
              59,
            ),
          );

          final hasExistingSession = existingSessions.any((session) {
            final sessionDate = DateTime.parse(session.date);
            return sessionDate.year == currentDate.year &&
                sessionDate.month == currentDate.month &&
                sessionDate.day == currentDate.day;
          });

          if (!hasExistingSession) {
            // Создаем тренировку
            await createTrainingSession(date: currentDate);
          }
        }

        currentDate = currentDate.add(const Duration(days: 1));
      }
    }
  }

  void _invalidateCache() {
    _cachedPlayers = null;
    _cachedGroups = null;
    _lastCacheUpdate = null;
  }

  Future<bool> _checkInternetConnection() async {
    // Упрощённая проверка - просто возвращаем true
    // Supabase сам обработает ошибки сети
    return true;
  }

  Future<void> _logError(String operation, dynamic error) async {
    print('Ошибка в $operation: $error');
    if (error.toString().contains('Failed host lookup')) {
      print('Проблема с DNS - проверьте подключение к интернету');
    } else if (error.toString().contains('SocketException')) {
      print('Проблема с сокетом - проверьте сеть');
    }
  }

  Future<T> _retryOperation<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
  }) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        return await operation();
      } catch (e) {
        if (i == maxRetries - 1) {
          rethrow;
        }
        print('Попытка ${i + 1} неудачна, повторяем через 1 секунду...');
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    throw Exception('Все попытки исчерпаны');
  }
}

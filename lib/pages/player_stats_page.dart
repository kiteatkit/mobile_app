import 'package:flutter/material.dart';

import '../models/player.dart';
import '../models/attendance.dart';
import '../supabase_client.dart';

class PlayerStatsPage extends StatefulWidget {
  const PlayerStatsPage({super.key, required this.player});

  final Player player;

  @override
  State<PlayerStatsPage> createState() => _PlayerStatsPageState();
}

class _PlayerStatsPageState extends State<PlayerStatsPage> {
  bool loading = true;
  Player? player;
  List<Attendance> history = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    // Load player
    final p = await SupabaseManager.client
        .from('players')
        .select('*')
        .eq('id', widget.player.id)
        .single();
    // Load attendance with session details
    final a = await SupabaseManager.client
        .from('attendance')
        .select('*, training_sessions(*)')
        .eq('player_id', widget.player.id)
        .order('created_at', ascending: false)
        .limit(20);
    setState(() {
      player = Player.fromJson(Map<String, dynamic>.from(p));
      history = (a as List)
          .map((e) => Attendance.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      loading = false;
    });
  }

  int _attendanceRate() {
    if (history.isEmpty) return 0;
    final attended = history.where((e) => e.attended).length;
    return ((attended / history.length) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Статистика игрока')),
      body: loading || player == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: player!.avatar_url != null
                            ? NetworkImage(player!.avatar_url!)
                            : null,
                        child: player!.avatar_url == null
                            ? Text(player!.name[0])
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              player!.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '@${player!.login}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Очки',
                          value: '${player!.total_points}',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Тренировки',
                          value: '${player!.attendance_count}',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Посещаемость',
                          value: '${_attendanceRate()}%',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'История посещений',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: history.isEmpty
                        ? const Center(child: Text('Нет данных'))
                        : ListView.separated(
                            itemCount: history.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, i) {
                              final h = history[i];
                              final ts = h.training_sessions;
                              return ListTile(
                                leading: Icon(
                                  h.attended
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: h.attended ? Colors.green : Colors.red,
                                ),
                                title: Text(ts?.title ?? 'Тренировка'),
                                subtitle: Text(ts != null ? ts.date : ''),
                                trailing: h.attended
                                    ? Text('+${h.points}')
                                    : null,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value});
  final String title;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

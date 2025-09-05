import 'package:flutter/material.dart';
import '../ui/ui_constants.dart';

import '../data/supabase_repository.dart';
import '../models/group.dart';
import '../models/player.dart';
import '../models/training_session.dart';
import '../models/attendance.dart';
import '../widgets/back_button.dart';

class GroupViewPage extends StatefulWidget {
  const GroupViewPage({super.key, required this.group});

  final Group group;

  @override
  State<GroupViewPage> createState() => _GroupViewPageState();
}

class _GroupViewPageState extends State<GroupViewPage>
    with AutomaticKeepAliveClientMixin {
  final repo = SupabaseRepository();
  bool loading = true;
  DateTime selectedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );
  List<Player> players = [];
  List<TrainingSession> trainings = [];
  Map<String, Attendance> attendanceMap = {};

  late final ScrollController _hScroll;
  late final ScrollController _vScroll;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _hScroll = ScrollController();
    _vScroll = ScrollController();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final start = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final end = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);
    final p = await repo.getPlayers(groupId: widget.group.id);
    final ts = await repo.getTrainingsInRange(start, end);
    final a = await repo.getAttendanceForSessions(ts.map((t) => t.id).toList());
    setState(() {
      players = p;
      trainings = ts;
      attendanceMap = {for (final r in a) '${r.session_id}_${r.player_id}': r};
      _updateLeader();
      loading = false;
    });
  }

  int _pointsFor(String playerId, String trainingId) {
    final rec = attendanceMap['${trainingId}_$playerId'];
    if (rec == null || !rec.attended) return 0;
    return rec.points;
  }

  int _monthlyTotal(String playerId) {
    return trainings.fold(0, (sum, t) => sum + _pointsFor(playerId, t.id));
  }

  Player? _leader;
  void _updateLeader() {
    if (players.isEmpty) {
      _leader = null;
      return;
    }
    final copy = [...players];
    copy.sort((a, b) => _monthlyTotal(b.id).compareTo(_monthlyTotal(a.id)));
    _leader = copy.first;
  }

  String _formatMonth(DateTime d) {
    const monthsRu = [
      'январь',
      'февраль',
      'март',
      'апрель',
      'май',
      'июнь',
      'июль',
      'август',
      'сентябрь',
      'октябрь',
      'ноябрь',
      'декабрь',
    ];
    return '${monthsRu[d.month - 1]} ${d.year} г.';
  }

  @override
  void dispose() {
    _hScroll.dispose();
    _vScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: UI.background,
      body: loading
          ? const Center(child: CircularProgressIndicator(color: UI.primary))
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Заголовок с зеленой точкой и кнопкой закрыть
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${widget.group.name} - Игроки команды',
                            style: const TextStyle(
                              color: UI.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const CustomBackButton(),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Карточки статистики
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.emoji_events,
                            value:
                                '${players.fold<int>(0, (s, p) => s + _monthlyTotal(p.id))}',
                            label: 'Очки за месяц',
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (players.isNotEmpty)
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.military_tech,
                              value: _leader?.name ?? '-',
                              label: _leader == null
                                  ? 'Лидер команды'
                                  : 'Лидер команды • ${_monthlyTotal(_leader!.id)} очков за месяц',
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Секция игроков команды
                    Row(
                      children: [
                        const Text(
                          'Игроки команды',
                          style: TextStyle(
                            color: UI.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        const Text('Месяц:', style: TextStyle(color: UI.white)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: UI.card,
                            borderRadius: BorderRadius.circular(UI.radiusLg),
                            border: Border.all(color: UI.border),
                          ),
                          child: DropdownButton<DateTime>(
                            dropdownColor: UI.card,
                            value: selectedMonth,
                            underline: const SizedBox(),
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: UI.white,
                              size: 16,
                            ),
                            items: List.generate(12, (i) {
                              final d = DateTime(
                                DateTime.now().year,
                                DateTime.now().month - i,
                                1,
                              );
                              return DropdownMenuItem(
                                value: d,
                                child: Text(
                                  _formatMonth(d),
                                  style: const TextStyle(color: UI.white),
                                ),
                              );
                            }),
                            onChanged: (v) {
                              if (v == null) return;
                              setState(() => selectedMonth = v);
                              _load();
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Таблица игроков
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: UI.card,
                          borderRadius: BorderRadius.circular(UI.radiusLg),
                          border: Border.all(color: UI.border),
                        ),
                        child: Column(
                          children: [
                            // Заголовок таблицы
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: UI.border),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Игрок',
                                      style: TextStyle(
                                        color: UI.muted,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (trainings.isNotEmpty)
                                    Expanded(
                                      child: Column(
                                        children: [
                                          const Icon(
                                            Icons.calendar_today,
                                            color: UI.muted,
                                            size: 16,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            trainings.first.title,
                                            style: TextStyle(
                                              color: UI.muted,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        const Icon(
                                          Icons.emoji_events,
                                          color: UI.muted,
                                          size: 16,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Итого',
                                          style: TextStyle(
                                            color: UI.muted,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Строки игроков
                            Expanded(
                              child: ListView.builder(
                                itemCount: players.length,
                                itemBuilder: (context, index) {
                                  final player = players[index];
                                  final isLeader = player.id == _leader?.id;
                                  final monthlyTotal = _monthlyTotal(player.id);
                                  final trainingPoints = trainings.isNotEmpty
                                      ? _pointsFor(
                                          player.id,
                                          trainings.first.id,
                                        )
                                      : 0;

                                  return _PlayerRow(
                                    player: player,
                                    isLeader: isLeader,
                                    monthlyTotal: monthlyTotal,
                                    trainingPoints: trainingPoints,
                                    trainings: trainings,
                                    isLast: index == players.length - 1,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UI.card,
        borderRadius: BorderRadius.circular(UI.radiusLg),
        border: Border.all(color: UI.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: UI.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: UI.primary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: UI.white, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({
    required this.player,
    required this.isLeader,
    required this.monthlyTotal,
    required this.trainingPoints,
    required this.trainings,
    required this.isLast,
  });

  final Player player;
  final bool isLeader;
  final int monthlyTotal;
  final int trainingPoints;
  final List<TrainingSession> trainings;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLeader ? UI.border.withOpacity(0.3) : Colors.transparent,
        border: !isLast
            ? const Border(bottom: BorderSide(color: UI.border))
            : null,
      ),
      child: Row(
        children: [
          // Аватар игрока
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: UI.primary, width: 1),
            ),
            child: ClipOval(
              child: player.avatar_url != null && player.avatar_url!.isNotEmpty
                  ? Image.network(
                      player.avatar_url!,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlayerFallbackAvatar(player),
                    )
                  : _buildPlayerFallbackAvatar(player),
            ),
          ),
          const SizedBox(width: 12),
          // Информация об игроке
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      player.name,
                      style: const TextStyle(
                        color: UI.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isLeader) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.military_tech,
                        color: UI.primary,
                        size: 16,
                      ),
                    ],
                  ],
                ),
                Text(
                  '@${player.login}',
                  style: const TextStyle(color: UI.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          // Очки за тренировку
          if (trainings.isNotEmpty)
            Expanded(
              child: Text(
                trainingPoints.toString(),
                style: const TextStyle(
                  color: UI.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          // Итого очков
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: UI.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                monthlyTotal.toString(),
                style: const TextStyle(
                  color: UI.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerFallbackAvatar(Player player) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: UI.primary, shape: BoxShape.circle),
      child: Center(
        child: Text(
          player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: UI.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

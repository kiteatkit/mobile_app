import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../ui/ui_constants.dart';
import '../data/supabase_repository.dart';
import '../models/group.dart';
import '../models/player.dart';
import '../models/training_session.dart';
import '../models/attendance.dart';
import '../widgets/training_schedule_dialog.dart';

class GroupViewPage extends StatefulWidget {
  const GroupViewPage({
    super.key,
    required this.group,
    this.isPlayerMode = false,
  });

  final Group group;
  final bool isPlayerMode;

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

  // Контроллеры для синхронизации прокрутки
  late final ScrollController _horizontalScrollController;
  late final ScrollController _verticalScrollController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _horizontalScrollController = ScrollController();
    _verticalScrollController = ScrollController();
    _load();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => loading = true);
    final start = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final end = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);
    final p = await repo.getPlayers(groupId: widget.group.id);
    final ts = await repo.getTrainingsInRange(start, end);
    final a = await repo.getAttendanceForSessions(ts.map((t) => t.id).toList());

    if (!mounted) return;
    setState(() {
      players = p;
      trainings = ts
        ..sort(
          (a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)),
        );
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

  double _monthlyAverage(String playerId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final pastTrainings = trainings
        .where(
          (t) => DateTime.parse(
            t.date,
          ).isBefore(today.add(const Duration(days: 1))),
        )
        .toList();
    final attendedTrainings = pastTrainings
        .where((t) => _pointsFor(playerId, t.id) > 0)
        .length;
    if (attendedTrainings == 0) return 0.0;
    return pastTrainings.fold(0, (sum, t) => sum + _pointsFor(playerId, t.id)) /
        attendedTrainings;
  }

  List<Player> _topPlayers = [];

  void _updateLeader() {
    if (players.isEmpty) {
      _topPlayers = [];
      return;
    }
    final copy = [...players];
    copy.sort((a, b) => _monthlyAverage(b.id).compareTo(_monthlyAverage(a.id)));
    _topPlayers = copy.take(3).toList();
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

  String _formatTrainingDateFull(String dateStr) {
    final date = DateTime.parse(dateStr);
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (loading) {
      return Scaffold(
        backgroundColor: UI.background,
        body: const SafeArea(
          child: Center(child: CircularProgressIndicator(color: UI.primary)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: UI.background,
      body: SafeArea(
        child: Column(
          children: [
            // Верхняя часть - статистика и фильтры
            _buildHeader(context),

            // Таблица с фиксированными заголовками и левой колонкой
            Expanded(child: _buildFixedTable(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: UI.getScreenPadding(context),
      child: Column(
        children: [
          // Заголовок с кнопкой назад
          Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(UI.radiusLg),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: UI.isSmallScreen(context) ? 8 : 12,
                      vertical: UI.isSmallScreen(context) ? 6 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: UI.card,
                      borderRadius: BorderRadius.circular(UI.radiusLg),
                      border: Border.all(color: UI.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back_ios,
                          color: UI.white,
                          size: UI.isSmallScreen(context) ? 14 : 16,
                        ),
                        SizedBox(width: UI.isSmallScreen(context) ? 2 : 4),
                        Text(
                          'Назад',
                          style: TextStyle(
                            color: UI.white,
                            fontSize: UI.isSmallScreen(context) ? 12 : 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
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
                  style: TextStyle(
                    color: UI.white,
                    fontSize: UI.getSubtitleFontSize(context),
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Статистика
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context: context,
                  icon: Icons.emoji_events,
                  value: players.isEmpty
                      ? '0.0'
                      : (players.fold<double>(
                                  0,
                                  (s, p) => s + _monthlyAverage(p.id),
                                ) /
                                players.length)
                            .toStringAsFixed(1),
                  label: 'Средний балл команды',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _buildTopPlayersCard(context)),
            ],
          ),

          const SizedBox(height: 16),

          // Выбор месяца
          Row(
            children: [
              const Spacer(),
              const Text('Месяц:', style: TextStyle(color: UI.white)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                    size: 12,
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

          // Кнопки управления
          if (!widget.isPlayerMode)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _openAddTrainingDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UI.primary,
                      foregroundColor: UI.white,
                    ),
                    icon: const Icon(Icons.add, size: 14),
                    label: const Text(
                      'Тренировка',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _openTrainingScheduleDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UI.primary,
                      foregroundColor: UI.white,
                    ),
                    icon: const Icon(Icons.schedule, size: 14),
                    label: const Text(
                      'Расписание',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFixedTable(BuildContext context) {
    final isSmallScreen = UI.isSmallScreen(context);
    final playerColumnWidth = isSmallScreen ? 160.0 : 250.0;
    final trainingColumnWidth = isSmallScreen ? 120.0 : 160.0;
    final totalColumnWidth = isSmallScreen ? 60.0 : 100.0;
    final rowHeight = isSmallScreen ? 60.0 : 80.0;

    return Container(
      margin: UI.getScreenPadding(context),
      decoration: BoxDecoration(
        color: UI.card,
        borderRadius: BorderRadius.circular(UI.radiusLg),
        border: Border.all(color: UI.border),
      ),
      child: Column(
        children: [
          // ФИКСИРОВАННАЯ СТРОКА ЗАГОЛОВКОВ
          Container(
            height: 72,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: UI.border)),
            ),
            child: Row(
              children: [
                // Заголовок колонки игроков (фиксированный)
                Container(
                  width: playerColumnWidth,
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    border: Border(right: BorderSide(color: UI.border)),
                  ),
                  child: Center(
                    child: Text(
                      'Игрок',
                      style: TextStyle(
                        color: UI.muted,
                        fontSize: isSmallScreen ? 13 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // ПРОКРУЧИВАЕМЫЕ ЗАГОЛОВКИ ТРЕНИРОВОК
                Expanded(
                  child: SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Заголовки тренировок
                        ...trainings.map(
                          (training) => Container(
                            width: trainingColumnWidth,
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _formatTrainingDateFull(training.date),
                                  style: TextStyle(
                                    color: UI.muted,
                                    fontSize: isSmallScreen ? 11 : 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (training.title.isNotEmpty &&
                                    training.title !=
                                        _formatTrainingDateFull(
                                          training.date,
                                        )) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    training.title,
                                    style: TextStyle(
                                      color: UI.muted.withValues(alpha: 0.7),
                                      fontSize: isSmallScreen ? 9 : 10,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        // Заголовок колонки "Средний балл"
                        Container(
                          width: totalColumnWidth,
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.emoji_events,
                                color: UI.muted,
                                size: isSmallScreen ? 12 : 16,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Средний балл',
                                style: TextStyle(
                                  color: UI.muted,
                                  fontSize: isSmallScreen ? 8 : 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ОБЛАСТЬ ДАННЫХ
          Expanded(
            child: Row(
              children: [
                // ФИКСИРОВАННАЯ КОЛОНКА С ИГРОКАМИ
                Container(
                  width: playerColumnWidth,
                  decoration: const BoxDecoration(
                    border: Border(right: BorderSide(color: UI.border)),
                  ),
                  child: ListView.builder(
                    controller: _verticalScrollController,
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      final player = players[index];
                      final isTopPlayer = _topPlayers.any(
                        (p) => p.id == player.id,
                      );

                      return Container(
                        height: rowHeight,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: index < players.length - 1
                              ? const Border(
                                  bottom: BorderSide(
                                    color: UI.border,
                                    width: 0.5,
                                  ),
                                )
                              : null,
                        ),
                        child: Row(
                          children: [
                            if (isTopPlayer) ...[
                              Icon(
                                Icons.emoji_events,
                                color: UI.primary,
                                size: isSmallScreen ? 12 : 16,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              child: Text(
                                player.name,
                                style: TextStyle(
                                  color: UI.white,
                                  fontSize: isSmallScreen ? 12 : 14,
                                  fontWeight: isTopPlayer
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // ПРОКРУЧИВАЕМАЯ ОБЛАСТЬ С ДАННЫМИ
                Expanded(
                  child: SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width:
                          (trainings.length * trainingColumnWidth) +
                          totalColumnWidth,
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (scrollNotification) {
                          // Синхронизируем вертикальную прокрутку с левой колонкой
                          if (scrollNotification is ScrollUpdateNotification) {
                            _verticalScrollController.jumpTo(
                              scrollNotification.metrics.pixels,
                            );
                          }
                          return false;
                        },
                        child: ListView.builder(
                          itemCount: players.length,
                          itemBuilder: (context, index) {
                            final player = players[index];

                            return Container(
                              height: rowHeight,
                              decoration: BoxDecoration(
                                border: index < players.length - 1
                                    ? const Border(
                                        bottom: BorderSide(
                                          color: UI.border,
                                          width: 0.5,
                                        ),
                                      )
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  // Баллы по тренировкам
                                  ...trainings.map((training) {
                                    final points = _pointsFor(
                                      player.id,
                                      training.id,
                                    );

                                    return Container(
                                      width: trainingColumnWidth,
                                      padding: const EdgeInsets.all(8),
                                      child: widget.isPlayerMode
                                          ? Container(
                                              height: isSmallScreen ? 36 : 44,
                                              decoration: BoxDecoration(
                                                color: UI.primary.withValues(
                                                  alpha: 0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: UI.primary.withValues(
                                                    alpha: 0.3,
                                                  ),
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  points.toString(),
                                                  style: TextStyle(
                                                    color: UI.primary,
                                                    fontSize: isSmallScreen
                                                        ? 14
                                                        : 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Row(
                                              children: [
                                                Checkbox(
                                                  value: points > 0,
                                                  onChanged: (value) {
                                                    _setPlayerPoints(
                                                      player,
                                                      training,
                                                      value == true ? 1 : 0,
                                                    );
                                                  },
                                                  activeColor: UI.primary,
                                                  materialTapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                ),
                                                Expanded(
                                                  child: GestureDetector(
                                                    onTap: () =>
                                                        _editPlayerPoints(
                                                          player,
                                                          training,
                                                        ),
                                                    child: Container(
                                                      height: isSmallScreen
                                                          ? 28
                                                          : 32,
                                                      decoration: BoxDecoration(
                                                        color: UI.primary
                                                            .withValues(
                                                              alpha: 0.1,
                                                            ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                        border: Border.all(
                                                          color: UI.primary
                                                              .withValues(
                                                                alpha: 0.3,
                                                              ),
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          points.toString(),
                                                          style: TextStyle(
                                                            color: UI.primary,
                                                            fontSize:
                                                                isSmallScreen
                                                                ? 12
                                                                : 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                    );
                                  }),

                                  // Средний балл
                                  Container(
                                    width: totalColumnWidth,
                                    padding: const EdgeInsets.all(8),
                                    child: Container(
                                      height: isSmallScreen ? 28 : 32,
                                      decoration: BoxDecoration(
                                        color: UI.primary.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _monthlyAverage(
                                            player.id,
                                          ).toStringAsFixed(1),
                                          style: TextStyle(
                                            color: UI.white,
                                            fontSize: isSmallScreen ? 10 : 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      height: UI.isSmallScreen(context) ? 120 : 140,
      padding: UI.getCardPadding(context),
      decoration: BoxDecoration(
        color: UI.card,
        borderRadius: BorderRadius.circular(UI.radiusLg),
        border: Border.all(color: UI.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: UI.primary,
            size: UI.isSmallScreen(context) ? 24 : 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: UI.white,
              fontSize: UI.isSmallScreen(context) ? 20 : 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: UI.muted,
              fontSize: UI.isSmallScreen(context) ? 12 : 14,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTopPlayersCard(BuildContext context) {
    return Container(
      height: UI.isSmallScreen(context) ? 120 : 140,
      padding: UI.getCardPadding(context),
      decoration: BoxDecoration(
        color: UI.card,
        borderRadius: BorderRadius.circular(UI.radiusLg),
        border: Border.all(color: UI.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: UI.primary,
                size: UI.isSmallScreen(context) ? 20 : 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Топ-3 игроков',
                style: TextStyle(
                  color: UI.white,
                  fontSize: UI.isSmallScreen(context) ? 14 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Column(
              children: _topPlayers
                  .take(3)
                  .map(
                    (player) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.emoji_events,
                            color: UI.primary,
                            size: UI.isSmallScreen(context) ? 10 : 12,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              player.name,
                              style: TextStyle(
                                color: UI.white,
                                fontSize: UI.isSmallScreen(context) ? 10 : 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _monthlyAverage(player.id).toStringAsFixed(1),
                            style: TextStyle(
                              color: UI.primary,
                              fontSize: UI.isSmallScreen(context) ? 10 : 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setPlayerPoints(
    Player player,
    TrainingSession training,
    int points,
  ) async {
    try {
      await repo.updateAttendancePoints(
        sessionId: training.id,
        playerId: player.id,
        points: points,
      );
      if (!mounted) return;
      setState(() {
        attendanceMap['${training.id}_${player.id}'] = Attendance(
          id: '${training.id}_${player.id}',
          session_id: training.id,
          player_id: player.id,
          attended: points > 0,
          points: points,
          created_at: DateTime.now().toIso8601String(),
        );
        _updateLeader();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _editPlayerPoints(
    Player player,
    TrainingSession training,
  ) async {
    final currentPoints = _pointsFor(player.id, training.id);
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: UI.card,
        title: Text(
          '${player.name} - ${training.title}',
          style: TextStyle(
            color: UI.muted,
            fontSize: UI.getBodyFontSize(context),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Выберите количество баллов:',
              style: TextStyle(
                color: UI.white,
                fontSize: UI.getBodyFontSize(context),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: UI.background,
                borderRadius: BorderRadius.circular(UI.radiusSm),
                border: Border.all(color: UI.border),
              ),
              child: DropdownButton<int>(
                dropdownColor: UI.card,
                value: currentPoints,
                underline: const SizedBox(),
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: UI.white,
                  size: 16,
                ),
                items: List.generate(6, (i) {
                  return DropdownMenuItem(
                    value: i,
                    child: Text(
                      i.toString(),
                      style: const TextStyle(color: UI.white),
                    ),
                  );
                }),
                onChanged: (value) {
                  if (value != null) {
                    Navigator.of(context).pop(value);
                  }
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена', style: TextStyle(color: UI.muted)),
          ),
        ],
      ),
    );
    if (result != null) {
      await _setPlayerPoints(player, training, result);
    }
  }

  Future<void> _openAddTrainingDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _AddTrainingDialog(group: widget.group),
    );
    if (result != null && mounted) {
      await _load();
    }
  }

  Future<void> _openTrainingScheduleDialog() async {
    await showDialog(
      context: context,
      builder: (context) => TrainingScheduleDialog(group: widget.group),
    );
  }
}

class _AddTrainingDialog extends StatefulWidget {
  const _AddTrainingDialog({required this.group});

  final Group group;

  @override
  State<_AddTrainingDialog> createState() => _AddTrainingDialogState();
}

class _AddTrainingDialogState extends State<_AddTrainingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? selectedDate;
  final repo = SupabaseRepository();

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: UI.card,
      title: const Text(
        'Создать тренировку',
        style: TextStyle(color: UI.white),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              style: const TextStyle(color: UI.white),
              decoration: const InputDecoration(
                labelText: 'Название тренировки',
                labelStyle: TextStyle(color: UI.muted),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: UI.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: UI.primary),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите название тренировки';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              style: const TextStyle(color: UI.white),
              decoration: const InputDecoration(
                labelText: 'Место проведения',
                labelStyle: TextStyle(color: UI.muted),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: UI.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: UI.primary),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите место проведения';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => selectedDate = date);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: UI.border),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: UI.muted, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      selectedDate == null
                          ? 'Выберите дату'
                          : DateFormat('dd.MM.yyyy').format(selectedDate!),
                      style: TextStyle(
                        color: selectedDate == null ? UI.muted : UI.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (selectedDate == null)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Выберите дату тренировки',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена', style: TextStyle(color: UI.muted)),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate() && selectedDate != null) {
              try {
                await repo.createTrainingSession(
                  groupId: widget.group.id,
                  address: _locationController.text,
                  date: selectedDate!,
                );
                if (mounted) {
                  Navigator.of(context).pop({
                    'title': _titleController.text,
                    'location': _locationController.text,
                    'date': selectedDate!,
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Тренировка на ${DateFormat('dd.MM.yyyy').format(selectedDate!)} создана',
                      ),
                      backgroundColor: UI.primary,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ошибка: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: UI.primary,
            foregroundColor: UI.white,
          ),
          child: const Text('Создать'),
        ),
      ],
    );
  }
}

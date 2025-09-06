import 'package:flutter/material.dart';
import '../ui/ui_constants.dart';

import '../data/supabase_repository.dart';
import '../models/group.dart';
import '../models/player.dart';
import '../models/training_session.dart';
import '../models/attendance.dart';
import '../widgets/back_button.dart';
import '../widgets/training_schedule_dialog.dart';
import '../widgets/scheduled_trainings_dialog.dart';

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

  String _formatTrainingDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return '${date.day}.${date.month}';
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
              child: SingleChildScrollView(
                controller: _vScroll,
                child: Column(
                  children: [
                    // Заголовок и контент с отступами
                    Padding(
                      padding: UI.getScreenPadding(context),
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
                                  style: TextStyle(
                              color: UI.white,
                                    fontSize: UI.getSubtitleFontSize(context),
                              fontWeight: FontWeight.bold,
                            ),
                                  overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const CustomBackButton(),
                      ],
                    ),
                          SizedBox(height: UI.isSmallScreen(context) ? 16 : 24),

                    // Карточки статистики
                          UI.isSmallScreen(context)
                              ? Column(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: _buildStatCard(
                                        context: context,
                                        icon: Icons.emoji_events,
                                        value:
                                            '${players.fold<int>(0, (s, p) => s + _monthlyTotal(p.id))}',
                                        label: 'Очки за месяц',
                                      ),
                                    ),
                                    if (players.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        child: _buildStatCard(
                                          context: context,
                                          icon: Icons.military_tech,
                                          value: _leader?.name ?? '-',
                                          label: _leader == null
                                              ? 'Лидер команды'
                                              : 'Лидер команды • ${_monthlyTotal(_leader!.id)} очков за месяц',
                                        ),
                                      ),
                                    ],
                                  ],
                                )
                              : Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                                        context: context,
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
                                          context: context,
                              icon: Icons.military_tech,
                              value: _leader?.name ?? '-',
                              label: _leader == null
                                  ? 'Лидер команды'
                                  : 'Лидер команды • ${_monthlyTotal(_leader!.id)} очков за месяц',
                            ),
                          ),
                      ],
                    ),

                          SizedBox(height: UI.isSmallScreen(context) ? 16 : 24),

                    // Секция игроков команды
                          UI.isSmallScreen(context)
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Игроки команды',
                                      style: TextStyle(
                                        color: UI.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Text(
                                          'Месяц:',
                                          style: TextStyle(color: UI.white),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: UI.card,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    UI.radiusLg,
                                                  ),
                                              border: Border.all(
                                                color: UI.border,
                                              ),
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
                                                    style: const TextStyle(
                                                      color: UI.white,
                                                    ),
                                                  ),
                                                );
                                              }),
                                              onChanged: (v) {
                                                if (v == null) return;
                                                setState(
                                                  () => selectedMonth = v,
                                                );
                                                _load();
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (!widget.isPlayerMode) ...[
                                      const SizedBox(height: 12),
                                      UI.isSmallScreen(context)
                                          ? Column(
                                              children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: SizedBox(
                                                        height: 36,
                                              child: ElevatedButton.icon(
                                                onPressed: () =>
                                                    _openAddTrainingDialog(),
                                                style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                UI.primary,
                                                            foregroundColor:
                                                                UI.white,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    6,
                                                                  ),
                                                            ),
                                                          ),
                                                          icon: const Icon(
                                                            Icons.add,
                                                            size: 14,
                                                          ),
                                                          label: const Text(
                                                            'Тренировка',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                      child: SizedBox(
                                                        height: 36,
                                                        child: ElevatedButton.icon(
                                                          onPressed: () =>
                                                              _openScheduledTrainingsDialog(),
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                UI.primary,
                                                            foregroundColor:
                                                                UI.white,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    6,
                                                                  ),
                                                            ),
                                                          ),
                                                          icon: const Icon(
                                                            Icons.queue,
                                                            size: 14,
                                                          ),
                                                          label: const Text(
                                                            'Очередь',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                SizedBox(
                                                  width: double.infinity,
                                                  height: 36,
                                                  child: ElevatedButton.icon(
                                                    onPressed: () =>
                                                        _openTrainingScheduleDialog(),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          UI.primary,
                                                  foregroundColor: UI.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                              6,
                                                            ),
                                                      ),
                                                    ),
                                                    icon: const Icon(
                                                      Icons.schedule,
                                                      size: 14,
                                                    ),
                                                    label: const Text(
                                                      'Расписание',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Row(
                                              children: [
                                                Expanded(
                                                  child: SizedBox(
                                                    height: 40,
                                                    child: ElevatedButton.icon(
                                                      onPressed: () =>
                                                          _openAddTrainingDialog(),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            UI.primary,
                                                        foregroundColor:
                                                            UI.white,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                        ),
                                                  ),
                                                ),
                                                      icon: const Icon(
                                                  Icons.add,
                                                        size: 16,
                                                ),
                                                      label: const Text(
                                                  'Тренировка',
                                                  style: TextStyle(
                                                          fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: SizedBox(
                                                    height: 40,
                                                    child: ElevatedButton.icon(
                                                      onPressed: () =>
                                                          _openScheduledTrainingsDialog(),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            UI.primary,
                                                        foregroundColor:
                                                            UI.white,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                      ),
                                                      icon: const Icon(
                                                        Icons.queue,
                                                        size: 16,
                                                      ),
                                                      label: const Text(
                                                        'Очередь',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                          Expanded(
                                            child: SizedBox(
                                                    height: 40,
                                              child: ElevatedButton.icon(
                                                onPressed: () =>
                                                    _openTrainingScheduleDialog(),
                                                style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            UI.primary,
                                                        foregroundColor:
                                                            UI.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                                8,
                                                        ),
                                                  ),
                                                ),
                                                      icon: const Icon(
                                                  Icons.schedule,
                                                        size: 16,
                                                ),
                                                      label: const Text(
                                                  'Расписание',
                                                  style: TextStyle(
                                                          fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                )
                              : Row(
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
                                    const Text(
                                      'Месяц:',
                                      style: TextStyle(color: UI.white),
                                    ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: UI.card,
                                        borderRadius: BorderRadius.circular(
                                          UI.radiusLg,
                                        ),
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
                                              style: const TextStyle(
                                                color: UI.white,
                                              ),
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
                                    if (!widget.isPlayerMode) ...[
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        height: 40,
                                        child: ElevatedButton.icon(
                                          onPressed: () =>
                                              _openAddTrainingDialog(),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: UI.primary,
                                            foregroundColor: UI.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          icon: const Icon(Icons.add, size: 16),
                                          label: const Text(
                                            'Тренировка',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        height: 40,
                                        child: ElevatedButton.icon(
                                          onPressed: () =>
                                              _openScheduledTrainingsDialog(),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: UI.primary,
                                            foregroundColor: UI.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          icon: const Icon(
                                            Icons.queue,
                                            size: 16,
                                          ),
                                          label: const Text(
                                            'Очередь',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        height: 40,
                                        child: ElevatedButton.icon(
                                          onPressed: () =>
                                              _openTrainingScheduleDialog(),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: UI.primary,
                                            foregroundColor: UI.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                                  ),
                                            ),
                                          icon: const Icon(
                                            Icons.schedule,
                                            size: 16,
                                          ),
                                          label: const Text(
                                            'Расписание',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Таблица игроков
                    Container(
                      height: 400, // Фиксированная высота вместо Expanded
                        decoration: BoxDecoration(
                          color: UI.card,
                          borderRadius: BorderRadius.circular(UI.radiusLg),
                          border: Border.all(color: UI.border),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width,
                        ),
                        child: Column(
                          children: [
                            // Заголовок таблицы
                            Container(
                                padding: UI.getCardPadding(context),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: UI.border),
                                ),
                              ),
                              child: Row(
                                children: [
                                    // Колонка игрока - адаптивная ширина
                                    Container(
                                      width: UI.isSmallScreen(context)
                                          ? 160
                                          : 250,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                    child: Text(
                                      'Игрок',
                                      style: TextStyle(
                                        color: UI.muted,
                                          fontSize: UI.isSmallScreen(context)
                                              ? 13
                                              : 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    // Колонки тренировок - адаптивная ширина
                                    ...trainings.map(
                                      (training) => Container(
                                        width: UI.isSmallScreen(context)
                                            ? 120
                                            : 160,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                      child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                        children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                            Icons.calendar_today,
                                            color: UI.muted,
                                                  size:
                                                      UI.isSmallScreen(context)
                                                      ? 16
                                                      : 20,
                                                ),
                                                SizedBox(
                                                  width:
                                                      UI.isSmallScreen(context)
                                                      ? 2
                                                      : 4,
                                                ),
                                                if (!widget.isPlayerMode)
                                                  PopupMenuButton<String>(
                                                    icon: Icon(
                                                      Icons.more_vert,
                                                      color: UI.muted,
                                                      size:
                                                          UI.isSmallScreen(
                                                            context,
                                                          )
                                                          ? 12
                                                          : 16,
                                                    ),
                                                    onSelected: (value) {
                                                      if (value == 'delete') {
                                                        _deleteTraining(
                                                          training,
                                                        );
                                                      } else if (value ==
                                                          'create') {
                                                        _openAddTrainingDialog();
                                                      }
                                                    },
                                                    itemBuilder: (context) => [
                                                      const PopupMenuItem(
                                                        value: 'create',
                                                        child: Text(
                                                          'Создать тренировку',
                                                        ),
                                                      ),
                                                      const PopupMenuItem(
                                                        value: 'delete',
                                                        child: Text(
                                                          'Удалить тренировку',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                              training.title,
                                            style: TextStyle(
                                              color: UI.muted,
                                                fontSize:
                                                    UI.isSmallScreen(context)
                                                    ? 8
                                                    : 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              _formatTrainingDate(
                                                training.date,
                                              ),
                                              style: TextStyle(
                                                color: UI.muted.withOpacity(
                                                  0.7,
                                                ),
                                                fontSize:
                                                    UI.isSmallScreen(context)
                                                    ? 11
                                                    : 13,
                                              ),
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                    ),
                                    // Колонка итого - адаптивная ширина
                                    Container(
                                      width: UI.isSmallScreen(context)
                                          ? 60
                                          : 100,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                      children: [
                                          Icon(
                                          Icons.emoji_events,
                                          color: UI.muted,
                                            size: UI.isSmallScreen(context)
                                                ? 12
                                                : 16,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Итого',
                                          style: TextStyle(
                                            color: UI.muted,
                                              fontSize:
                                                  UI.isSmallScreen(context)
                                                  ? 8
                                                  : 12,
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
                            // Строки игроков
                              ...players.asMap().entries.map((entry) {
                                final index = entry.key;
                                final player = entry.value;
                                  final isLeader = player.id == _leader?.id;
                                  final monthlyTotal = _monthlyTotal(player.id);

                                return Container(
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
                                      // Колонка игрока - адаптивная ширина
                                      Container(
                                        width: UI.isSmallScreen(context)
                                            ? 160
                                            : 250,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: UI.isSmallScreen(context)
                                              ? 12
                                              : 20,
                                          vertical: 16,
                                        ),
                                        child: _PlayerInfo(
                                    player: player,
                                    isLeader: isLeader,
                                    isLast: index == players.length - 1,
                                        ),
                                      ),
                                      // Колонки баллов для каждой тренировки - адаптивная ширина
                                      ...trainings.map((training) {
                                        final trainingPoints = _pointsFor(
                                          player.id,
                                          training.id,
                                        );
                                        return Container(
                                          width: UI.isSmallScreen(context)
                                              ? 120
                                              : 160,
                                          padding: EdgeInsets.symmetric(
                                            horizontal:
                                                UI.isSmallScreen(context)
                                                ? 8
                                                : 16,
                                            vertical: 16,
                                          ),
                                          child: widget.isPlayerMode
                                              ? Container(
                                                  height:
                                                      UI.isSmallScreen(context)
                                                      ? 44
                                                      : 48,
                                                  decoration: BoxDecoration(
                                                    color: UI.primary
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          UI.isSmallScreen(
                                                                context,
                                                              )
                                                              ? 4
                                                              : 6,
                                                        ),
                                                    border: Border.all(
                                                      color: UI.primary
                                                          .withOpacity(0.3),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      trainingPoints.toString(),
                                                      style: TextStyle(
                                                        color: UI.primary,
                                                        fontSize:
                                                            UI.isSmallScreen(
                                                              context,
                                                            )
                                                            ? 14
                                                            : 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                )
                                              : GestureDetector(
                                                  onTap: () =>
                                                      _editPlayerPoints(
                                                        player,
                                                        training,
                                                      ),
                                                  child: Container(
                                                    height:
                                                        UI.isSmallScreen(
                                                          context,
                                                        )
                                                        ? 28
                                                        : 32,
                                                    decoration: BoxDecoration(
                                                      color: UI.primary
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            UI.isSmallScreen(
                                                                  context,
                                                                )
                                                                ? 4
                                                                : 6,
                                                          ),
                                                      border: Border.all(
                                                        color: UI.primary
                                                            .withOpacity(0.3),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        trainingPoints
                                                            .toString(),
                                                        style: TextStyle(
                                                          color: UI.primary,
                                                          fontSize:
                                                              UI.isSmallScreen(
                                                                context,
                                                              )
                                                              ? 10
                                                              : 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                        );
                                      }),
                                      // Колонка итого - адаптивная ширина
                                      Container(
                                        width: UI.isSmallScreen(context)
                                            ? 60
                                            : 100,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: UI.isSmallScreen(context)
                                              ? 4
                                              : 8,
                                          vertical: 8,
                                        ),
                                        child: Container(
                                          height: UI.isSmallScreen(context)
                                              ? 28
                                              : 32,
                                          decoration: BoxDecoration(
                                            color: UI.primary.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(
                                              UI.isSmallScreen(context) ? 4 : 6,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              monthlyTotal.toString(),
                                              style: TextStyle(
                                                color: UI.white,
                                                fontSize:
                                                    UI.isSmallScreen(context)
                                                    ? 10
                                                    : 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                              ),
                            ),
                          ],
                                  ),
                                );
                              }),
                            ],
                          ),
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
    required BuildContext context,
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: UI.getCardPadding(context),
      decoration: BoxDecoration(
        color: UI.card,
        borderRadius: BorderRadius.circular(UI.radiusLg),
        border: Border.all(color: UI.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: UI.primary, size: UI.getIconSize(context) + 4),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: UI.primary,
              fontSize: UI.isSmallScreen(context) ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: UI.white,
              fontSize: UI.isSmallScreen(context) ? 10 : 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Future<void> _editPlayerPoints(
    Player player,
    TrainingSession training,
  ) async {
    final currentPoints = _pointsFor(player.id, training.id);
    int selectedPoints = currentPoints;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: UI.card,
          title: Text(
            'Редактировать баллы',
            style: TextStyle(
              color: UI.white,
              fontSize: UI.getSubtitleFontSize(context),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${player.name} - ${training.title}',
                style: TextStyle(
                  color: UI.muted,
                  fontSize: UI.getBodyFontSize(context),
                ),
              ),
              const SizedBox(height: 16),

              // Селектор баллов от 0 до 5
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: UI.background,
                  borderRadius: BorderRadius.circular(UI.radiusSm),
                  border: Border.all(color: UI.border),
                ),
                child: DropdownButton<int>(
                  value: selectedPoints,
                  dropdownColor: UI.card,
                  underline: const SizedBox(),
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: UI.white,
                    size: 16,
                  ),
                  style: const TextStyle(color: UI.white),
                  items: List.generate(6, (i) {
                    return DropdownMenuItem<int>(
                      value: i,
                      child: Text(
                        i.toString(),
                        style: const TextStyle(color: UI.white),
                      ),
                    );
                  }),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        selectedPoints = value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Отмена', style: TextStyle(color: UI.muted)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: UI.primary,
                foregroundColor: UI.white,
              ),
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final newPoints = selectedPoints;

      try {
        // Обновляем или создаем запись посещения
        await repo.updateAttendancePoints(
          sessionId: training.id,
          playerId: player.id,
          points: newPoints,
        );

        // Обновляем локальные данные только если виджет еще смонтирован
        if (mounted) {
          setState(() {
            attendanceMap['${training.id}_${player.id}'] = Attendance(
              id: attendanceMap['${training.id}_${player.id}']?.id ?? '',
              player_id: player.id,
              session_id: training.id,
              attended:
                  true, // Всегда считаем присутствовавшим при редактировании баллов
              points: newPoints,
              created_at:
                  attendanceMap['${training.id}_${player.id}']?.created_at ??
                  DateTime.now().toIso8601String(),
              training_sessions: training,
            );
          });

          _updateLeader();
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Баллы обновлены для ${player.name}'),
              backgroundColor: UI.primary,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка при обновлении баллов: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteTraining(TrainingSession training) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: UI.card,
        title: Text(
          'Удалить тренировку',
          style: TextStyle(
            color: UI.white,
            fontSize: UI.getSubtitleFontSize(context),
          ),
        ),
        content: Text(
          'Вы уверены, что хотите удалить тренировку "${training.title}"?',
          style: TextStyle(
            color: UI.muted,
            fontSize: UI.getBodyFontSize(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Отмена', style: TextStyle(color: UI.muted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: UI.white,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await repo.deleteTrainingSession(training.id);
        await _load(); // Перезагружаем данные

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Тренировка "${training.title}" удалена'),
              backgroundColor: UI.primary,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка при удалении тренировки: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _openAddTrainingDialog() async {
    final dateController = TextEditingController();
    DateTime? selectedDate;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: UI.card,
        title: Text(
          'Создать тренировку',
          style: TextStyle(
            color: UI.white,
            fontSize: UI.getSubtitleFontSize(context),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: dateController,
              style: const TextStyle(color: UI.white),
              decoration: InputDecoration(
                labelText: 'Дата тренировки',
                labelStyle: const TextStyle(color: UI.muted),
                filled: true,
                fillColor: UI.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(UI.radiusSm),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today, color: UI.muted),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 30),
                      ),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      selectedDate = date;
                      dateController.text =
                          '${date.day}.${date.month}.${date.year}';
                    }
                  },
                ),
              ),
              readOnly: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Отмена', style: TextStyle(color: UI.muted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: UI.primary,
              foregroundColor: UI.white,
            ),
            child: const Text('Создать'),
          ),
        ],
      ),
    );

    if (result == true && selectedDate != null) {
      try {
        // Сначала пытаемся создать тренировку на основе расписания
        try {
          await repo.createTrainingFromSchedule(
            groupId: widget.group.id,
            date: selectedDate!,
          );
        } catch (e) {
          // Если нет расписания, создаем обычную тренировку
        await repo.createTrainingSession(date: selectedDate!);
        }

        await _load(); // Перезагружаем данные

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Тренировка на ${selectedDate!.day}.${selectedDate!.month}.${selectedDate!.year} создана',
              ),
              backgroundColor: UI.primary,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка при создании тренировки: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _openTrainingScheduleDialog() async {
    await showDialog(
      context: context,
      builder: (context) => TrainingScheduleDialog(
        group: widget.group,
        onScheduleCreated: () {
          _load();
        },
      ),
    );
  }

  Future<void> _openScheduledTrainingsDialog() async {
    await showDialog(
      context: context,
      builder: (context) => ScheduledTrainingsDialog(
        group: widget.group,
        onTrainingCreated: () {
          _load();
        },
      ),
    );
  }
}

class _PlayerInfo extends StatelessWidget {
  const _PlayerInfo({
    required this.player,
    required this.isLeader,
    required this.isLast,
  });

  final Player player;
  final bool isLeader;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final avatarSize = UI.isSmallScreen(context) ? 32.0 : 40.0;
    final iconSize = UI.isSmallScreen(context) ? 16.0 : 18.0;

    return Container(
      decoration: BoxDecoration(
        color: isLeader ? UI.primary.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(UI.isSmallScreen(context) ? 4 : 6),
      ),
      child: Row(
        children: [
          // Аватар игрока
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isLeader ? UI.primary : UI.border,
                width: 1,
              ),
            ),
            child: ClipOval(
              child: player.avatar_url != null && player.avatar_url!.isNotEmpty
                  ? Image.network(
                      player.avatar_url!,
                      width: avatarSize,
                      height: avatarSize,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlayerFallbackAvatar(player, avatarSize),
                    )
                  : _buildPlayerFallbackAvatar(player, avatarSize),
            ),
          ),
          SizedBox(width: UI.isSmallScreen(context) ? 12 : 16),
          // Информация об игроке
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                      player.name,
                        style: TextStyle(
                        color: UI.white,
                          fontSize: UI.isSmallScreen(context) ? 14 : 17,
                        fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    if (isLeader) ...[
                      SizedBox(width: UI.isSmallScreen(context) ? 2 : 4),
                      Icon(
                        Icons.military_tech,
                        color: UI.primary,
                        size: iconSize,
                      ),
                    ],
                  ],
                ),
                SizedBox(height: UI.isSmallScreen(context) ? 1 : 2),
                Text(
                  '@${player.login}',
                  style: TextStyle(
                    color: UI.muted,
                    fontSize: UI.isSmallScreen(context) ? 11 : 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerFallbackAvatar(Player player, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: UI.primary, shape: BoxShape.circle),
      child: Center(
        child: Text(
          player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
          style: TextStyle(
            color: UI.white,
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

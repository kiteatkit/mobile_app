import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../ui/ui_constants.dart';

import '../data/supabase_repository.dart';
import '../models/group.dart';
import '../models/player.dart';
import '../models/training_session.dart';
import '../models/attendance.dart';
import '../widgets/training_schedule_dialog.dart';
// import '../widgets/scheduled_trainings_dialog.dart';

// Класс для фиксированного заголовка таблицы
class _TableHeaderDelegate extends SliverPersistentHeaderDelegate {
  final bool isSmallScreen;
  final List<TrainingSession> trainings;
  final String Function(String) formatTrainingDateFull;
  final bool isPlayerMode;
  final Function(TrainingSession) onDeleteTraining;
  final VoidCallback onAddTraining;
  final ScrollController horizontalScrollController;

  _TableHeaderDelegate({
    required this.isSmallScreen,
    required this.trainings,
    required this.formatTrainingDateFull,
    required this.isPlayerMode,
    required this.onDeleteTraining,
    required this.onAddTraining,
    required this.horizontalScrollController,
  });

  @override
  double get minExtent => isSmallScreen ? 72 : 72;

  @override
  double get maxExtent => isSmallScreen ? 72 : 72;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: UI.card,
        border: const Border(bottom: BorderSide(color: UI.border)),
      ),
      child: Row(
        children: [
          // Закрепленный столбец с заголовком "Игрок"
          Container(
            width: isSmallScreen ? 160 : 250,
            padding: UI.getCardPadding(context),
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: UI.border, width: 1)),
            ),
            child: Center(
              child: Text(
                'Игрок',
                style: TextStyle(
                  color: UI.muted,
                  fontSize: isSmallScreen ? 13 : 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Прокручиваемая область с заголовками тренировок
          Expanded(
            child: SingleChildScrollView(
              controller: horizontalScrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Колонки тренировок - адаптивная ширина
                  ...trainings.map(
                    (training) => Container(
                      width: isSmallScreen ? 120 : 160,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      formatTrainingDateFull(training.date),
                                      style: TextStyle(
                                        color: UI.muted,
                                        fontSize: isSmallScreen ? 11 : 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    if (training.title.isNotEmpty &&
                                        training.title !=
                                            formatTrainingDateFull(
                                              training.date,
                                            )) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        training.title,
                                        style: TextStyle(
                                          color: UI.muted.withOpacity(0.7),
                                          fontSize: isSmallScreen ? 9 : 10,
                                          fontWeight: FontWeight.normal,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (!isPlayerMode)
                                PopupMenuButton<String>(
                                  icon: Icon(
                                    Icons.more_vert,
                                    color: UI.muted,
                                    size: isSmallScreen ? 12 : 16,
                                  ),
                                  onSelected: (value) {
                                    if (value == 'delete') {
                                      onDeleteTraining(training);
                                    } else if (value == 'create') {
                                      onAddTraining();
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'create',
                                      child: Text('Создать тренировку'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Удалить тренировку'),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Колонка итого - адаптивная ширина
                  Container(
                    width: isSmallScreen ? 60 : 100,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

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
  late final ScrollController _tableScrollController;
  late final ScrollController _playersScrollController;
  late final ScrollController _headerScrollController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _hScroll = ScrollController();
    _vScroll = ScrollController();
    _tableScrollController = ScrollController();
    _playersScrollController = ScrollController();
    _headerScrollController = ScrollController();

    // Синхронизация прокрутки теперь происходит через NotificationListener

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
      // Сортируем тренировки от старых к новым
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

  int _monthlyTotal(String playerId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return trainings
        .where(
          (t) => DateTime.parse(
            t.date,
          ).isBefore(today.add(const Duration(days: 1))),
        )
        .fold(0, (sum, t) => sum + _pointsFor(playerId, t.id));
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
    return _monthlyTotal(playerId) / attendedTrainings;
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
  void dispose() {
    _hScroll.dispose();
    _vScroll.dispose();
    _tableScrollController.dispose();
    _playersScrollController.dispose();
    _headerScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: UI.background,
      body: SafeArea(
        top: true,
        bottom: true,
        left: true,
        right: true,
        child: loading
            ? const Center(child: CircularProgressIndicator(color: UI.primary))
            : CustomScrollView(
                controller: _vScroll,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // SliverAppBar с заголовком и статистикой
                  SliverAppBar(
                    expandedHeight: UI.isSmallScreen(context) ? 200 : 250,
                    floating: false,
                    pinned: true,
                    snap: false,
                    backgroundColor: UI.background,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Padding(
                        padding: EdgeInsets.only(
                          top: UI.getScreenPadding(context).top + 8,
                          left: UI.getScreenPadding(context).left,
                          right: UI.getScreenPadding(context).right,
                          bottom: UI.getScreenPadding(context).bottom,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Заголовок с зеленой точкой
                            Row(
                              children: [
                                // Кастомная кнопка "Назад" в стиле хедера
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => Navigator.of(context).pop(),
                                    borderRadius: BorderRadius.circular(
                                      UI.radiusLg,
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: UI.isSmallScreen(context)
                                            ? 8
                                            : 12,
                                        vertical: UI.isSmallScreen(context)
                                            ? 6
                                            : 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: UI.card,
                                        borderRadius: BorderRadius.circular(
                                          UI.radiusLg,
                                        ),
                                        border: Border.all(color: UI.border),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.arrow_back_ios,
                                            color: UI.white,
                                            size: UI.isSmallScreen(context)
                                                ? 14
                                                : 16,
                                          ),
                                          SizedBox(
                                            width: UI.isSmallScreen(context)
                                                ? 2
                                                : 4,
                                          ),
                                          Text(
                                            'Назад',
                                            style: TextStyle(
                                              color: UI.white,
                                              fontSize:
                                                  UI.isSmallScreen(context)
                                                  ? 12
                                                  : 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: UI.isSmallScreen(context) ? 8 : 12,
                                ),
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
                            SizedBox(
                              height: UI.isSmallScreen(context) ? 16 : 24,
                            ),

                            // Карточки статистики
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
                                                    (s, p) =>
                                                        s +
                                                        _monthlyAverage(p.id),
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
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Выбор месяца
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: UI.getScreenPadding(context),
                      child: UI.isSmallScreen(context)
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                          horizontal: 8,
                                          vertical: 2,
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
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                const Spacer(),
                                const Text(
                                  'Месяц:',
                                  style: TextStyle(color: UI.white),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
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
                              ],
                            ),
                    ),
                  ),

                  // Кнопки управления
                  if (!widget.isPlayerMode)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: UI.getScreenPadding(context),
                        child: UI.isSmallScreen(context)
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
                                              backgroundColor: UI.primary,
                                              foregroundColor: UI.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                            ),
                                            icon: const Icon(
                                              Icons.add,
                                              size: 14,
                                            ),
                                            label: const Text(
                                              'Тренировка',
                                              style: TextStyle(fontSize: 12),
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
                                                _openTrainingScheduleDialog(),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: UI.primary,
                                              foregroundColor: UI.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                            ),
                                            icon: const Icon(
                                              Icons.schedule,
                                              size: 14,
                                            ),
                                            label: const Text(
                                              'Расписание',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),

                  // Фиксированные заголовки таблицы
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _TableHeaderDelegate(
                      isSmallScreen: UI.isSmallScreen(context),
                      trainings: trainings,
                      formatTrainingDateFull: _formatTrainingDateFull,
                      isPlayerMode: widget.isPlayerMode,
                      onDeleteTraining: _deleteTraining,
                      onAddTraining: _openAddTrainingDialog,
                      horizontalScrollController: _headerScrollController,
                    ),
                  ),

                  // Таблица игроков
                  SliverToBoxAdapter(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.6,
                      decoration: BoxDecoration(
                        color: UI.card,
                        borderRadius: BorderRadius.circular(UI.radiusLg),
                        border: Border.all(color: UI.border),
                      ),
                      child: SingleChildScrollView(
                        controller: _headerScrollController,
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: SizedBox(
                          width:
                              (UI.isSmallScreen(context) ? 160 : 250) +
                              (trainings.length *
                                  (UI.isSmallScreen(context) ? 120.0 : 160.0)) +
                              (UI.isSmallScreen(context) ? 60.0 : 100.0),
                          child: ListView.builder(
                            controller: _tableScrollController,
                            physics: const BouncingScrollPhysics(),
                            itemCount: players.length,
                            itemBuilder: (context, index) {
                              final player = players[index];
                              final isTopPlayer = _topPlayers.any(
                                (p) => p.id == player.id,
                              );

                              return Container(
                                height: UI.isSmallScreen(context) ? 100 : 120,
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
                                    // Закрепленный столбец с игроками
                                    Container(
                                      width: UI.isSmallScreen(context)
                                          ? 160
                                          : 250,
                                      decoration: BoxDecoration(
                                        color: UI.card,
                                        border: const Border(
                                          right: BorderSide(
                                            color: UI.border,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      child: _PlayerInfo(
                                        player: player,
                                        isLeader: isTopPlayer,
                                        isLast: index == players.length - 1,
                                      ),
                                    ),
                                    // Столбец с баллами
                                    Expanded(
                                      child: _TrainingRowWidget(
                                        player: player,
                                        trainings: trainings,
                                        isPlayerMode: widget.isPlayerMode,
                                        pointsFor: _pointsFor,
                                        monthlyAverage: _monthlyAverage,
                                        setPlayerPoints: _setPlayerPoints,
                                        editPlayerPoints: _editPlayerPoints,
                                        index: index,
                                        isLast: index == players.length - 1,
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

  Future<void> _deleteTraining(TrainingSession training) async {
    try {
      await repo.deleteTrainingSession(training.id);
      if (!mounted) return;
      setState(() {
        trainings.removeWhere((t) => t.id == training.id);
      });
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
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
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
    return Padding(
      padding: UI.getCardPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isLeader)
                Icon(
                  Icons.emoji_events,
                  color: UI.primary,
                  size: UI.isSmallScreen(context) ? 12 : 16,
                ),
              if (isLeader) const SizedBox(width: 8),
              Expanded(
                child: Text(
                  player.name,
                  style: TextStyle(
                    color: UI.white,
                    fontSize: UI.isSmallScreen(context) ? 12 : 14,
                    fontWeight: isLeader ? FontWeight.bold : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (!isLast) const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// Оптимизированный виджет для строки таблицы с тренировками
class _TrainingRowWidget extends StatelessWidget {
  const _TrainingRowWidget({
    required this.player,
    required this.trainings,
    required this.isPlayerMode,
    required this.pointsFor,
    required this.monthlyAverage,
    required this.setPlayerPoints,
    required this.editPlayerPoints,
    required this.index,
    required this.isLast,
  });

  final Player player;
  final List<TrainingSession> trainings;
  final bool isPlayerMode;
  final int Function(String, String) pointsFor;
  final double Function(String) monthlyAverage;
  final Function(Player, TrainingSession, int) setPlayerPoints;
  final Function(Player, TrainingSession) editPlayerPoints;
  final int index;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = UI.isSmallScreen(context);
    final rowHeight = isSmallScreen ? 100.0 : 120.0;

    return Container(
      height: rowHeight,
      decoration: BoxDecoration(
        border: !isLast
            ? const Border(bottom: BorderSide(color: UI.border, width: 0.5))
            : null,
      ),
      child: Row(
        children: [
          // Колонки баллов для каждой тренировки - адаптивная ширина
          ...trainings.map((training) {
            final trainingPoints = pointsFor(player.id, training.id);
            final columnWidth = isSmallScreen ? 120.0 : 160.0;
            final horizontalPadding = isSmallScreen ? 8.0 : 16.0;

            return Container(
              width: columnWidth,
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16,
              ),
              child: isPlayerMode
                  ? Container(
                      height: isSmallScreen ? 44 : 48,
                      decoration: BoxDecoration(
                        color: UI.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          isSmallScreen ? 4 : 6,
                        ),
                        border: Border.all(
                          color: UI.primary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          trainingPoints.toString(),
                          style: TextStyle(
                            color: UI.primary,
                            fontSize: isSmallScreen ? 14 : 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        // Чекбокс для быстрого выставления 1 балла
                        Checkbox(
                          value: trainingPoints > 0,
                          onChanged: (bool? value) {
                            if (value == true) {
                              setPlayerPoints(player, training, 1);
                            } else {
                              setPlayerPoints(player, training, 0);
                            }
                          },
                          activeColor: UI.primary,
                          checkColor: UI.white,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        // Кнопка для редактирования баллов
                        Expanded(
                          child: GestureDetector(
                            onTap: () => editPlayerPoints(player, training),
                            child: Container(
                              height: isSmallScreen ? 28 : 32,
                              decoration: BoxDecoration(
                                color: UI.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                  isSmallScreen ? 4 : 6,
                                ),
                                border: Border.all(
                                  color: UI.primary.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  trainingPoints.toString(),
                                  style: TextStyle(
                                    color: UI.primary,
                                    fontSize: isSmallScreen ? 10 : 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            );
          }),
          // Колонка итого - адаптивная ширина
          Container(
            width: isSmallScreen ? 60 : 100,
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 4 : 8,
              vertical: 8,
            ),
            child: Container(
              height: isSmallScreen ? 28 : 32,
              decoration: BoxDecoration(
                color: UI.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(isSmallScreen ? 4 : 6),
              ),
              child: Center(
                child: Text(
                  monthlyAverage(player.id).toStringAsFixed(1),
                  style: TextStyle(
                    color: UI.white,
                    fontSize: isSmallScreen ? 10 : 14,
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
  }
}

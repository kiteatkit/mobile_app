import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../ui/ui_constants.dart';
import '../data/supabase_repository.dart';
import '../data/player_score_data_source.dart';
import '../models/group.dart';
import '../models/player.dart';
import '../models/training_session.dart';
import '../models/attendance.dart';
import '../models/player_score_row.dart';
import '../widgets/training_schedule_dialog.dart';

class GroupViewPageV2 extends StatefulWidget {
  const GroupViewPageV2({
    super.key,
    required this.group,
    this.isPlayerMode = false,
  });

  final Group group;
  final bool isPlayerMode;

  @override
  State<GroupViewPageV2> createState() => _GroupViewPageV2State();
}

class _GroupViewPageV2State extends State<GroupViewPageV2>
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
  List<PlayerScoreRow> playerRows = [];

  late PlayerScoreDataSource dataSource;

  // Кэш для средних баллов
  final Map<String, double> _monthlyAverageCache = {};
  DateTime? _lastCacheUpdate;

  // Топ игроки
  List<Player> _topPlayers = [];
  List<Player>? _cachedTopPlayers;
  String? _lastTopPlayersCacheKey;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    dataSource = PlayerScoreDataSource(
      playerRows: [],
      trainings: [],
      isPlayerMode: widget.isPlayerMode,
      onPointsChanged: _setPlayerPoints,
      onEditPoints: _editPlayerPoints,
    );
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => loading = true);

    final start = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final end = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);

    final p = await repo.getPlayers(groupId: widget.group.id);
    final ts = await repo.getTrainingsInRange(
      start,
      end,
      groupId: widget.group.id,
    );
    final a = await repo.getAttendanceForSessions(ts.map((t) => t.id).toList());

    if (!mounted) return;

    // Сортируем тренировки
    final sortedTrainings = ts
      ..sort(
        (a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)),
      );

    setState(() {
      players = p;
      trainings = sortedTrainings;
      attendanceMap = {for (final r in a) '${r.session_id}_${r.player_id}': r};

      // Очищаем кэши при обновлении данных
      _monthlyAverageCache.clear();
      _cachedTopPlayers = null;
      _lastTopPlayersCacheKey = null;

      _updatePlayerRows();
      _updateLeader();
      loading = false;
    });
  }

  void _updatePlayerRows() {
    playerRows = players.map((player) {
      final trainingScores = <String, int>{};
      for (final training in trainings) {
        trainingScores[training.id] = _pointsFor(player.id, training.id);
      }

      final totalScore = _monthlyTotal(player.id);
      final isTopPlayer = _topPlayers.any((p) => p.id == player.id);

      return PlayerScoreRow(
        player: player,
        trainingScores: trainingScores,
        averageScore: totalScore,
        isTopPlayer: isTopPlayer,
      );
    }).toList();

    dataSource.updateData(playerRows, trainings);
  }

  int _pointsFor(String playerId, String trainingId) {
    final rec = attendanceMap['${trainingId}_$playerId'];
    if (rec == null || !rec.attended) return 0;
    return rec.points;
  }

  double _monthlyTotal(String playerId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Проверяем, нужно ли обновить кэш
    if (_lastCacheUpdate == null ||
        _lastCacheUpdate!.day != today.day ||
        _lastCacheUpdate!.month != today.month) {
      _monthlyAverageCache.clear();
      _lastCacheUpdate = today;
    }

    // Возвращаем из кэша, если есть
    if (_monthlyAverageCache.containsKey(playerId)) {
      return _monthlyAverageCache[playerId]!;
    }

    // Вычисляем общее количество баллов за месяц до текущего дня
    final pastTrainings = trainings
        .where(
          (t) =>
              DateTime.parse(t.date).isBefore(today) ||
              DateTime.parse(t.date).isAtSameMomentAs(today),
        )
        .toList();

    if (pastTrainings.isEmpty) {
      _monthlyAverageCache[playerId] = 0.0;
      return 0.0;
    }

    int totalPoints = 0;

    for (final training in pastTrainings) {
      final points = _pointsFor(playerId, training.id);
      totalPoints += points; // Суммируем все баллы, включая 0
    }

    _monthlyAverageCache[playerId] = totalPoints.toDouble();
    return totalPoints.toDouble();
  }

  void _updateLeader() {
    if (players.isEmpty) {
      _topPlayers = [];
      _cachedTopPlayers = null;
      _lastTopPlayersCacheKey = null;
      return;
    }

    // Создаем ключ кэша на основе ID игроков
    final cacheKey = players.map((p) => p.id).join(',');

    // Проверяем кэш
    if (_cachedTopPlayers != null && _lastTopPlayersCacheKey == cacheKey) {
      _topPlayers = _cachedTopPlayers!;
      return;
    }

    final copy = [...players];
    copy.sort((a, b) => _monthlyTotal(b.id).compareTo(_monthlyTotal(a.id)));

    _topPlayers = copy.take(3).toList();
    _cachedTopPlayers = _topPlayers;
    _lastTopPlayersCacheKey = cacheKey;
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
        child: CustomScrollView(
          slivers: [
            // Верхняя часть - статистика и фильтры
            SliverToBoxAdapter(child: _buildHeader(context)),

            // Таблица с данными
            SliverFillRemaining(child: _buildDataGrid(context)),
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
                          color: UI.textPrimary,
                          size: UI.isSmallScreen(context) ? 14 : 16,
                        ),
                        SizedBox(width: UI.isSmallScreen(context) ? 2 : 4),
                        Text(
                          'Назад',
                          style: TextStyle(
                            color: UI.textPrimary,
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
                    color: UI.textPrimary,
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
                                  (s, p) => s + _monthlyTotal(p.id),
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
              const Text('Месяц:', style: TextStyle(color: UI.textPrimary)),
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
                    color: UI.textPrimary,
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
                        style: const TextStyle(color: UI.textPrimary),
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
                      foregroundColor: UI.textPrimary,
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
                      foregroundColor: UI.textPrimary,
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

  Widget _buildDataGrid(BuildContext context) {
    return Container(
      margin: UI.getScreenPadding(context),
      decoration: BoxDecoration(
        color: UI.card,
        borderRadius: BorderRadius.circular(UI.radiusLg),
        border: Border.all(color: UI.border),
      ),
      child: SfDataGrid(
        source: dataSource,
        columns: _buildColumns(context),
        allowSorting: true,
        gridLinesVisibility: GridLinesVisibility.none,
        headerGridLinesVisibility: GridLinesVisibility.none,
        headerRowHeight: 80,
        rowHeight: 60,
        columnWidthMode: ColumnWidthMode.fitByColumnName,
        selectionMode: SelectionMode.none,
        frozenColumnsCount: 1,
        onCellTap: (DataGridCellTapDetails details) {
          if (details.rowColumnIndex.rowIndex > 0) {
            _handleCellTap(details);
          }
        },
      ),
    );
  }

  List<GridColumn> _buildColumns(BuildContext context) {
    final columns = <GridColumn>[
      // Колонка с игроками
      GridColumn(
        columnName: 'player',
        width: UI.isSmallScreen(context) ? 120 : 180,
        label: Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.centerLeft,
          child: Text(
            'Игрок',
            style: TextStyle(
              color: UI.muted,
              fontSize: UI.isSmallScreen(context) ? 13 : 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    ];

    // Колонки тренировок
    for (final training in trainings) {
      columns.add(
        GridColumn(
          columnName: training.id,
          width: UI.isSmallScreen(context) ? 120 : 160,
          allowSorting: false,
          label: Container(
            padding: const EdgeInsets.all(6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _formatTrainingDateFull(training.date),
                        style: TextStyle(
                          color: UI.muted,
                          fontSize: UI.isSmallScreen(context) ? 11 : 13,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!widget.isPlayerMode)
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: UI.muted,
                          size: UI.isSmallScreen(context) ? 12 : 16,
                        ),
                        onSelected: (value) {
                          if (value == 'delete') {
                            _deleteTraining(training);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Удалить тренировку'),
                          ),
                        ],
                      ),
                  ],
                ),
                if (training.title.isNotEmpty &&
                    training.title !=
                        _formatTrainingDateFull(training.date)) ...[
                  Container(
                    padding: const EdgeInsets.only(
                      left: 6,
                      right: 6,
                      top: 0,
                      bottom: 2,
                    ),
                    decoration: BoxDecoration(
                      color: UI.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      training.title,
                      style: TextStyle(
                        color: UI.primary,
                        fontSize: UI.isSmallScreen(context) ? 9 : 10,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    // Колонка среднего балла
    columns.add(
      GridColumn(
        columnName: 'average',
        width: UI.isSmallScreen(context) ? 100 : 120,
        label: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events,
                color: UI.muted,
                size: UI.isSmallScreen(context) ? 12 : 16,
              ),
              const SizedBox(height: 4),
              Text(
                'Общий балл',
                style: TextStyle(
                  color: UI.muted,
                  fontSize: UI.isSmallScreen(context) ? 8 : 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );

    return columns;
  }

  void _handleCellTap(DataGridCellTapDetails details) {
    if (widget.isPlayerMode) return;

    final columnName = details.column.columnName;
    final rowIndex = details.rowColumnIndex.rowIndex - 1; // -1 для заголовка

    if (rowIndex < 0 || rowIndex >= players.length) return;

    final player = players[rowIndex];

    // Находим тренировку по columnName
    final training = trainings.firstWhere(
      (t) => t.id == columnName,
      orElse: () =>
          TrainingSession(id: '', date: '', title: '', created_at: ''),
    );

    if (training.id.isNotEmpty) {
      final currentPoints = _pointsFor(player.id, training.id);
      _editPlayerPoints(player.id, training.id, currentPoints);
    }
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
              color: UI.textPrimary,
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
                  color: UI.textPrimary,
                  fontSize: UI.isSmallScreen(context) ? 14 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Column(
              children: _topPlayers.take(3).toList().asMap().entries.map((
                entry,
              ) {
                final index = entry.key;
                final player = entry.value;
                final medalColor = _getMedalColor(index, _topPlayers);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      // Аватар игрока
                      Container(
                        width: UI.isSmallScreen(context) ? 16 : 20,
                        height: UI.isSmallScreen(context) ? 16 : 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: UI.primary, width: 1),
                        ),
                        child: ClipOval(
                          child:
                              player.avatar_url != null &&
                                  player.avatar_url!.isNotEmpty
                              ? Image.network(
                                  player.avatar_url!,
                                  width: UI.isSmallScreen(context) ? 16 : 20,
                                  height: UI.isSmallScreen(context) ? 16 : 20,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildPlayerFallbackAvatar(player),
                                )
                              : _buildPlayerFallbackAvatar(player),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.emoji_events,
                        color: medalColor,
                        size: UI.isSmallScreen(context) ? 10 : 12,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          player.name,
                          style: TextStyle(
                            color: UI.textPrimary,
                            fontSize: UI.isSmallScreen(context) ? 10 : 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _monthlyTotal(player.id).toStringAsFixed(0),
                        style: TextStyle(
                          color: UI.primary,
                          fontSize: UI.isSmallScreen(context) ? 10 : 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getMedalColor(int index, List<Player> players) {
    if (players.isEmpty) return Colors.grey;

    final currentPlayer = players[index];
    final currentPoints = _monthlyTotal(currentPlayer.id);

    // Находим уникальные очки и сортируем их
    final uniquePoints =
        players.map((p) => _monthlyTotal(p.id)).toSet().toList()
          ..sort((a, b) => b.compareTo(a));

    if (uniquePoints.isEmpty) return Colors.grey;

    // Определяем место по очкам
    final place = uniquePoints.indexOf(currentPoints);

    switch (place) {
      case 0:
        return Colors.amber; // Золото
      case 1:
        return Colors.grey[400]!; // Серебро
      case 2:
        return Colors.orange[700]!; // Бронза
      default:
        return Colors.grey;
    }
  }

  Future<void> _setPlayerPoints(
    String playerId,
    String trainingId,
    int points,
  ) async {
    try {
      await repo.updateAttendancePoints(
        sessionId: trainingId,
        playerId: playerId,
        points: points,
      );
      if (!mounted) return;
      setState(() {
        attendanceMap['${trainingId}_$playerId'] = Attendance(
          id: '${trainingId}_$playerId',
          session_id: trainingId,
          player_id: playerId,
          attended: points > 0,
          points: points,
          created_at: DateTime.now().toIso8601String(),
        );

        // Обновляем посещаемость игрока немедленно
        _updatePlayerAttendance(playerId);

        // Очищаем кэш средних баллов для этого игрока
        _monthlyAverageCache.remove(playerId);
        _cachedTopPlayers = null;
        _lastTopPlayersCacheKey = null;

        _updatePlayerRows();
        _updateLeader();
      });
      
      // Очищаем кэш репозитория для синхронизации с другими страницами
      print('🧹 Очищаем кэш после изменения баллов игрока $playerId');
      await repo.clearCache();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: UI.warning),
        );
      }
    }
  }

  void _updatePlayerAttendance(String playerId) {
    // Пересчитываем посещаемость для конкретного игрока
    int attendedCount = 0;
    
    for (final training in trainings) {
      final attendance = attendanceMap['${training.id}_$playerId'];
      if (attendance != null && attendance.attended) {
        attendedCount++;
      }
    }
    
    // Обновляем данные игрока с новой посещаемостью
    final playerIndex = players.indexWhere((p) => p.id == playerId);
    if (playerIndex != -1) {
      final player = players[playerIndex];
      players[playerIndex] = Player(
        id: player.id,
        name: player.name,
        birth_date: player.birth_date,
        login: player.login,
        password: player.password,
        avatar_url: player.avatar_url,
        group_id: player.group_id,
        total_points: player.total_points,
        attendance_count: attendedCount,
        created_at: player.created_at,
        updated_at: player.updated_at,
      );
    }
  }

  Future<void> _editPlayerPoints(
    String playerId,
    String trainingId,
    int currentPoints,
  ) async {
    final player = players.firstWhere((p) => p.id == playerId);
    final training = trainings.firstWhere((t) => t.id == trainingId);
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
                color: UI.textPrimary,
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
                  color: UI.textPrimary,
                  size: 16,
                ),
                items: List.generate(6, (i) {
                  return DropdownMenuItem(
                    value: i,
                    child: Text(
                      i.toString(),
                      style: const TextStyle(color: UI.textPrimary),
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
      await _setPlayerPoints(playerId, trainingId, result);
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
      builder: (context) => TrainingScheduleDialog(
        group: widget.group,
        onScheduleCreated: () {
          _load();
        },
      ),
    );
  }

  Future<void> _deleteTraining(TrainingSession training) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: UI.card,
        title: Text(
          'Удалить тренировку',
          style: TextStyle(
            color: UI.textPrimary,
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
              backgroundColor: UI.warning,
              foregroundColor: UI.textPrimary,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await repo.deleteTrainingSession(training.id);
        await _load();

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
              backgroundColor: UI.warning,
            ),
          );
        }
      }
    }
  }

  Widget _buildPlayerFallbackAvatar(Player player) {
    final size = UI.isSmallScreen(context) ? 16.0 : 20.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: UI.primary.withOpacity(0.2), // Светлый оранжевый фон
        shape: BoxShape.circle,
        border: Border.all(color: UI.primary.withOpacity(0.3), width: 1),
      ),
      child: Center(
        child: Text(
          player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
          style: TextStyle(
            color: UI.primary, // Оранжевый текст на светлом фоне
            fontSize: UI.isSmallScreen(context) ? 8 : 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();
  DateTime? selectedDate;
  final repo = SupabaseRepository();

  // Маска для ввода даты
  final dateMaskFormatter = MaskTextInputFormatter(
    mask: '##.##.####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void dispose() {
    _locationController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: UI.card,
      title: const Text(
        'Создать тренировку',
        style: TextStyle(color: UI.textPrimary),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _locationController,
              style: const TextStyle(color: UI.textPrimary),
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
            TextField(
              controller: _dateController,
              inputFormatters: [dateMaskFormatter],
              keyboardType: TextInputType.number,
              style: const TextStyle(color: UI.textPrimary),
              decoration: InputDecoration(
                labelText: 'Дата тренировки (дд.мм.гггг)',
                labelStyle: const TextStyle(color: UI.muted),
                filled: true,
                fillColor: UI.card,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: UI.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: UI.primary),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today, color: UI.muted),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365),
                      ),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: UI.primary,
                              onPrimary: UI.textPrimary,
                              surface: UI.card,
                              onSurface: UI.textPrimary,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                        _dateController.text =
                            '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
                      });
                    }
                  },
                ),
              ),
              onChanged: (value) {
                // Парсим введенную дату
                if (value.length == 10) {
                  try {
                    final parts = value.split('.');
                    if (parts.length == 3) {
                      final day = int.parse(parts[0]);
                      final month = int.parse(parts[1]);
                      final year = int.parse(parts[2]);
                      if (day >= 1 &&
                          day <= 31 &&
                          month >= 1 &&
                          month <= 12 &&
                          year >= 1900 &&
                          year <= DateTime.now().year + 1) {
                        setState(() {
                          selectedDate = DateTime(year, month, day);
                        });
                      }
                    }
                  } catch (e) {
                    // Игнорируем ошибки парсинга
                  }
                }
              },
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
            if (_formKey.currentState!.validate()) {
              // Получаем дату из TextField или selectedDate
              DateTime? trainingDate = selectedDate;
              if (_dateController.text.isNotEmpty &&
                  _dateController.text.length == 10) {
                try {
                  final parts = _dateController.text.split('.');
                  if (parts.length == 3) {
                    final day = int.parse(parts[0]);
                    final month = int.parse(parts[1]);
                    final year = int.parse(parts[2]);
                    if (day >= 1 &&
                        day <= 31 &&
                        month >= 1 &&
                        month <= 12 &&
                        year >= 1900 &&
                        year <= DateTime.now().year + 1) {
                      trainingDate = DateTime(year, month, day);
                    }
                  }
                } catch (e) {
                  // Игнорируем ошибки парсинга
                }
              }

              if (trainingDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Введите корректную дату тренировки'),
                    backgroundColor: UI.warning,
                  ),
                );
                return;
              }

              try {
                await repo.createTrainingSession(
                  groupId: widget.group.id,
                  address: _locationController.text,
                  date: trainingDate,
                );
                if (mounted) {
                  Navigator.of(context).pop({
                    'location': _locationController.text,
                    'date': trainingDate,
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Тренировка на ${DateFormat('dd.MM.yyyy').format(trainingDate)} создана',
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
                      backgroundColor: UI.warning,
                    ),
                  );
                }
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: UI.primary,
            foregroundColor: UI.textPrimary,
          ),
          child: const Text('Создать'),
        ),
      ],
    );
  }
}

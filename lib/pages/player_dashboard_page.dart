import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/group.dart';
import '../models/training_session.dart';
import '../models/attendance.dart';
import '../ui/ui_constants.dart';
import '../data/supabase_repository.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_storage_service.dart';

class PlayerDashboardPage extends StatefulWidget {
  const PlayerDashboardPage({super.key, required this.player});

  final Player player;

  @override
  State<PlayerDashboardPage> createState() => _PlayerDashboardPageState();
}

class _PlayerDashboardPageState extends State<PlayerDashboardPage>
    with AutomaticKeepAliveClientMixin {
  final SupabaseRepository _repository = SupabaseRepository();
  List<Player> _allPlayers = [];
  List<Group> _groups = [];
  bool _isLoading = true;
  bool _isRankingExpanded = false;
  late Player _currentPlayer;
  
  // Данные для расчета среднего балла команды
  List<TrainingSession> _trainings = [];
  Map<String, Attendance> _attendanceMap = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _currentPlayer = widget.player;
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Обновляем данные при возвращении на страницу
    _loadData();
  }

  String _getCurrentMonthName() {
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
    final now = DateTime.now();
    return monthsRu[now.month - 1];
  }

  // Методы для расчета баллов (аналогично group_view_page_v2.dart)
  int _pointsFor(String playerId, String trainingId) {
    final rec = _attendanceMap['${trainingId}_$playerId'];
    if (rec == null || !rec.attended) return 0;
    return rec.points;
  }

  double _monthlyTotal(String playerId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Вычисляем общее количество баллов за месяц до текущего дня
    final pastTrainings = _trainings
        .where(
          (t) =>
              DateTime.parse(t.date).isBefore(today) ||
              DateTime.parse(t.date).isAtSameMomentAs(today),
        )
        .toList();

    if (pastTrainings.isEmpty) {
      return 0.0;
    }

    int totalPoints = 0;

    for (final training in pastTrainings) {
      final points = _pointsFor(playerId, training.id);
      totalPoints += points; // Суммируем все баллы, включая 0
    }

    return totalPoints.toDouble();
  }

  Future<void> _loadData() async {
    try {
      final players = await _repository.getPlayers();
      final groups = await _repository.getGroups();

      // Загружаем данные о тренировках и посещениях для расчета среднего балла команды
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, 1);
      final end = DateTime(now.year, now.month + 1, 0);
      
      List<TrainingSession> trainings = [];
      Map<String, Attendance> attendanceMap = {};
      
      // Загружаем тренировки и посещения для каждой группы
      for (final group in groups) {
        final groupTrainings = await _repository.getTrainingsInRange(
          start,
          end,
          groupId: group.id,
        );
        trainings.addAll(groupTrainings);
        
        if (groupTrainings.isNotEmpty) {
          final attendance = await _repository.getAttendanceForSessions(
            groupTrainings.map((t) => t.id).toList()
          );
          attendanceMap.addAll({for (final r in attendance) '${r.session_id}_${r.player_id}': r});
        }
      }

      setState(() {
        _allPlayers = players;
        _groups = groups;
        _trainings = trainings;
        _attendanceMap = attendanceMap;
        _isLoading = false;
        // Обновляем данные текущего игрока
        final updatedPlayer = players.firstWhere(
          (p) => p.id == _currentPlayer.id,
          orElse: () => _currentPlayer,
        );
        _currentPlayer = updatedPlayer;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    if (_isLoading) {
      return Scaffold(
        backgroundColor: UI.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: UI.primary, strokeWidth: 3),
              const SizedBox(height: 16),
              Text(
                'Загрузка данных...',
                style: TextStyle(color: UI.muted, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: UI.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: UI.getScreenPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BounceInAnimation(child: _buildHeader(context)),
              SizedBox(height: UI.isSmallScreen(context) ? 16 : 24),
              BounceInAnimation(
                delay: const Duration(milliseconds: 200),
                child: _buildAchievementsSection(context),
              ),
              SizedBox(height: UI.isSmallScreen(context) ? 16 : 24),
              BounceInAnimation(
                delay: const Duration(milliseconds: 400),
                child: _buildTeamsSection(context),
              ),
              SizedBox(height: UI.isSmallScreen(context) ? 16 : 24),
              BounceInAnimation(
                delay: const Duration(milliseconds: 600),
                child: _buildRankingSection(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: UI.gradientBasketball,
        borderRadius: BorderRadius.circular(UI.radiusLg * 2),
        boxShadow: [UI.cardShadow.copyWith(color: UI.primary.withOpacity(0.2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/logo_black_white.png',
                width: 40,
                height: 40,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Панель игрока',
                      style: TextStyle(
                        fontSize: UI.getTitleFontSize(context),
                        fontWeight: UI.fontWeightBold,
                        color: UI.white, // Светлый текст
                        fontFamily: UI.fontFamily,
                      ),
                    ),
                    Text(
                      'Добро пожаловать, ${_currentPlayer.name}!',
                      style: TextStyle(
                        fontSize: UI.getBodyFontSize(context),
                        color: UI.white.withOpacity(0.8), // Светлый текст с прозрачностью
                        fontFamily: UI.fontFamily,
                        fontWeight: UI.fontWeightRegular,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        _buildActionButton(
          context: context,
          icon: Icons.person,
          text: 'Редактировать профиль',
          onTap: () async {
            await context.push('/profile', extra: _currentPlayer);
            // Принудительно очищаем кэш и обновляем данные после возврата из профиля
            await _repository.clearCache();
            _loadData();
          },
        ),
        const SizedBox(height: 8),
        _buildActionButton(
          context: context,
          icon: Icons.visibility,
          text: 'Статистика',
          onTap: () async {
            await context.push('/stats', extra: _currentPlayer);
            // Обновляем данные после возврата из статистики
            _loadData();
          },
        ),
        const SizedBox(height: 8),
        _buildActionButton(
          context: context,
          icon: Icons.exit_to_app,
          text: 'Выход',
          onTap: () async {
            await AuthStorageService.clearLoginData();
            if (mounted) context.go('/');
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return AnimatedButton(
      onPressed: onTap,
      child: Container(
        width: double.infinity,
        height: UI.getButtonHeight(context) + 8,
        decoration: BoxDecoration(
          color: UI.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(UI.radiusLg),
          border: Border.all(color: UI.white.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: UI.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(icon, size: UI.getIconSize(context), color: UI.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: UI.getBodyFontSize(context),
                  color: UI.white,
                  fontWeight: UI.fontWeightSemiBold,
                  fontFamily: UI.fontFamily,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: UI.white,
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsSection(BuildContext context) {
    return AnimatedCard(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: UI.gradientCard,
          borderRadius: BorderRadius.circular(UI.radiusLg * 2),
          border: Border.all(color: UI.border),
          boxShadow: [UI.cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: UI.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(UI.radiusLg),
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    color: UI.primary,
                    size: UI.getIconSize(context),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Мои достижения',
                  style: TextStyle(
                    fontSize: UI.getSubtitleFontSize(context),
                    fontWeight: UI.fontWeightBold,
                    color: UI.textPrimary,
                    fontFamily: UI.fontFamily,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildAchievementCard(
                    context: context,
                    title: 'Очки за ${_getCurrentMonthName()}',
                    value: _currentPlayer.total_points.toString(),
                    icon: Icons.star,
                    color: UI.warning,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAchievementCard(
                    context: context,
                    title: 'Посещено тренировок',
                    value: _currentPlayer.attendance_count.toString(),
                    icon: Icons.sports_basketball,
                    color: UI.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      height: 120, // Фиксированная высота для одинакового размера
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(UI.radiusLg),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Равномерное распределение
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: UI.textMuted,
                    fontSize: UI.isSmallScreen(context) ? 12 : 14,
                    fontWeight: UI.fontWeightMedium,
                    fontFamily: UI.fontFamily,
                  ),
                  maxLines: 2, // Максимум 2 строки для заголовка
                  overflow: TextOverflow.ellipsis, // Обрезание длинного текста
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: UI.isSmallScreen(context) ? 24 : 28,
              fontWeight: UI.fontWeightBold,
              fontFamily: UI.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamsSection(BuildContext context) {
    Group? playerGroup;
    try {
      playerGroup = _groups.firstWhere(
        (group) => group.id == _currentPlayer.group_id,
      );
    } catch (e) {
      // Группа не найдена
      playerGroup = null;
    }

    return AnimatedCard(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: UI.gradientCard,
          borderRadius: BorderRadius.circular(UI.radiusLg * 2),
          border: Border.all(color: UI.border),
          boxShadow: [UI.cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: UI.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(UI.radiusLg),
                  ),
                  child: Icon(
                    Icons.groups,
                    color: UI.info,
                    size: UI.getIconSize(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Команды',
                        style: TextStyle(
                          fontSize: UI.getSubtitleFontSize(context),
                          fontWeight: UI.fontWeightBold,
                          color: UI.textPrimary,
                          fontFamily: UI.fontFamily,
                        ),
                      ),
                      Text(
                        'Нажмите на карточку команды, чтобы увидеть детальную информацию',
                        style: TextStyle(
                          color: UI.textMuted,
                          fontSize: UI.isSmallScreen(context) ? 12 : 14,
                          fontFamily: UI.fontFamily,
                          fontWeight: UI.fontWeightRegular,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (playerGroup != null)
              _TeamCard(
                context: context,
                group: playerGroup,
                allPlayers: _allPlayers,
                trainings: _trainings,
                attendanceMap: _attendanceMap,
                monthlyTotal: _monthlyTotal,
                onTap: () async {
                  await context.push(
                    '/group-view',
                    extra: {'group': playerGroup, 'isPlayerMode': true},
                  );
                  // Обновляем данные после возврата из группы
                  _loadData();
                },
              )
            else
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: UI.surface,
                  borderRadius: BorderRadius.circular(UI.radiusLg),
                  border: Border.all(color: UI.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: UI.muted,
                      size: UI.getIconSize(context),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Игрок не состоит ни в одной группе',
                        style: TextStyle(
                          color: UI.muted,
                          fontSize: UI.getBodyFontSize(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingSection(BuildContext context) {
    final sortedPlayers = List<Player>.from(_allPlayers)
      ..sort((a, b) => b.total_points.compareTo(a.total_points));

    final playersToShow = _isRankingExpanded
        ? sortedPlayers
        : sortedPlayers.take(10).toList();

    return AnimatedCard(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: UI.gradientCard,
          borderRadius: BorderRadius.circular(UI.radiusLg * 2),
          border: Border.all(color: UI.border),
          boxShadow: [UI.cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: UI.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(UI.radiusLg),
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    color: UI.accent,
                    size: UI.getIconSize(context),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Рейтинг игроков',
                  style: TextStyle(
                    fontSize: UI.getSubtitleFontSize(context),
                    fontWeight: UI.fontWeightBold,
                    color: UI.textPrimary,
                    fontFamily: UI.fontFamily,
                  ),
                ),
                const Spacer(),
                if (sortedPlayers.length > 10)
                  AnimatedButton(
                    onPressed: () {
                      setState(() {
                        _isRankingExpanded = !_isRankingExpanded;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: UI.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(UI.radiusLg),
                        border: Border.all(color: UI.primary.withOpacity(0.3)),
                      ),
                      child: Icon(
                        _isRankingExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        size: 18,
                        color: UI.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: UI.surface,
                borderRadius: BorderRadius.circular(UI.radiusLg),
                border: Border.all(color: UI.border),
              ),
              child: Column(
                children: [
                  _buildRankingHeader(context),
                  ...playersToShow.asMap().entries.map((entry) {
                    final index = entry.key;
                    final player = entry.value;
                    final isCurrentPlayer = player.id == _currentPlayer.id;
                    return _RankingRow(
                      context: context,
                      position: index + 1,
                      player: player,
                      groups: _groups,
                      isHighlighted: isCurrentPlayer,
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: UI.primary.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(UI.radiusLg),
          topRight: Radius.circular(UI.radiusLg),
        ),
        border: const Border(bottom: BorderSide(color: UI.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: UI.isSmallScreen(context) ? 50 : 60,
            child: Text(
              'Место',
              style: TextStyle(
                color: UI.primary,
                fontSize: UI.isSmallScreen(context) ? 10 : 12,
                fontWeight: UI.fontWeightBold,
                fontFamily: UI.fontFamily,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Игрок',
              style: TextStyle(
                color: UI.primary,
                fontSize: UI.isSmallScreen(context) ? 10 : 12,
                fontWeight: UI.fontWeightBold,
                fontFamily: UI.fontFamily,
              ),
            ),
          ),
          SizedBox(
            width: UI.isSmallScreen(context) ? 50 : 60,
            child: Text(
              'Очки',
              style: TextStyle(
                color: UI.primary,
                fontSize: UI.isSmallScreen(context) ? 10 : 12,
                fontWeight: UI.fontWeightBold,
                fontFamily: UI.fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  const _TeamCard({
    required this.context,
    required this.group,
    required this.allPlayers,
    required this.trainings,
    required this.attendanceMap,
    required this.monthlyTotal,
    required this.onTap,
  });

  final BuildContext context;
  final Group group;
  final List<Player> allPlayers;
  final List<TrainingSession> trainings;
  final Map<String, Attendance> attendanceMap;
  final double Function(String) monthlyTotal;
  final VoidCallback onTap;

  // Функция для определения медали по месту
  Color _getMedalColor(int index, List<Player> players) {
    if (players.isEmpty) return Colors.grey;

    final currentPlayer = players[index];
    final currentPoints = currentPlayer.total_points;

    // Находим уникальные очки и сортируем их
    final uniquePoints = players.map((p) => p.total_points).toSet().toList()
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

  @override
  Widget build(BuildContext context) {
    final groupPlayers = allPlayers
        .where((p) => p.group_id == group.id)
        .toList();
    // Правильный расчет среднего балла команды за текущий месяц
    final averagePoints = groupPlayers.isNotEmpty
        ? groupPlayers.fold<double>(
            0,
            (s, p) => s + monthlyTotal(p.id),
          ) / groupPlayers.length
        : 0.0;

    // Сортируем игроков по очкам (по убыванию)
    final sortedPlayers = [...groupPlayers]
      ..sort((a, b) => b.total_points.compareTo(a.total_points));

    final topPlayers = sortedPlayers.take(3).toList();

    return AnimatedButton(
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: UI.gradientCard,
          borderRadius: BorderRadius.circular(UI.radiusLg),
          border: Border.all(color: UI.border),
          boxShadow: [UI.cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    group.name,
                    style: TextStyle(
                      color: UI.textPrimary,
                      fontSize: UI.getBodyFontSize(context),
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            UI.isSmallScreen(context)
                ? Column(
                    children: [
                      _TeamStat(
                        context: context,
                        label: 'Игроков:',
                        value: groupPlayers.length.toString(),
                      ),
                      const SizedBox(height: 8),
                      _TeamStat(
                        context: context,
                        label: 'Средний балл:',
                        value: averagePoints.toStringAsFixed(0),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Flexible(
                        child: _TeamStat(
                          context: context,
                          label: 'Игроков:',
                          value: groupPlayers.length.toString(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Flexible(
                        child: _TeamStat(
                          context: context,
                          label: 'Средний балл:',
                          value: averagePoints.toStringAsFixed(0),
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 12),
            Text(
              'Топ игроки:',
              style: TextStyle(
                color: UI.muted,
                fontSize: UI.isSmallScreen(context) ? 12 : 14,
              ),
            ),
            const SizedBox(height: 8),
            ...topPlayers.asMap().entries.map((entry) {
              final index = entry.key;
              final player = entry.value;
              final medalColor = _getMedalColor(index, topPlayers);

              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: medalColor,
                      size: UI.getIconSize(context),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        player.name,
                        style: TextStyle(
                          color: UI.textPrimary,
                          fontSize: UI.isSmallScreen(context) ? 12 : 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      player.total_points.toString(),
                      style: TextStyle(
                        color: UI.textPrimary,
                        fontSize: UI.isSmallScreen(context) ? 12 : 14,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _TeamStat extends StatelessWidget {
  const _TeamStat({
    required this.context,
    required this.label,
    required this.value,
  });

  final BuildContext context;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: UI.muted,
              fontSize: UI.isSmallScreen(context) ? 10 : 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: UI.textPrimary,
              fontSize: UI.isSmallScreen(context) ? 14 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _RankingRow extends StatelessWidget {
  const _RankingRow({
    required this.context,
    required this.position,
    required this.player,
    required this.groups,
    this.isHighlighted = false,
  });

  final BuildContext context;
  final int position;
  final Player player;
  final List<Group> groups;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final group = player.group_id != null
        ? groups.firstWhere(
            (g) => g.id == player.group_id,
            orElse: () => Group(
              id: '',
              name: 'Без группы',
              created_at: '',
              updated_at: '',
            ),
          )
        : Group(id: '', name: 'Без группы', created_at: '', updated_at: '');

    final avatarSize = UI.getAvatarSize(context);
    final isSmall = UI.isSmallScreen(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isHighlighted ? UI.primary.withOpacity(0.1) : Colors.transparent,
        border: position < 3
            ? const Border(bottom: BorderSide(color: UI.border))
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: isSmall ? 50 : 60,
            child: Row(
              children: [
                Icon(
                  position == 1 ? Icons.emoji_events : Icons.star,
                  color: position == 1 ? Colors.amber : UI.muted,
                  size: UI.getIconSize(context),
                ),
                const SizedBox(width: 4),
                Text(
                  '#$position',
                  style: TextStyle(
                    color: UI.textPrimary,
                    fontSize: isSmall ? 12 : 14,
                    fontWeight: UI.fontWeightBold,
                    fontFamily: UI.fontFamily,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: UI.primary, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: UI.primary.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child:
                        player.avatar_url != null &&
                            player.avatar_url!.isNotEmpty
                        ? Image.network(
                            player.avatar_url!,
                            width: avatarSize,
                            height: avatarSize,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildRankingFallbackAvatar(player, avatarSize),
                          )
                        : _buildRankingFallbackAvatar(player, avatarSize),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.name,
                        style: TextStyle(
                          color: UI.textPrimary,
                          fontSize: isSmall ? 12 : 14,
                          fontWeight: UI.fontWeightBold,
                          fontFamily: UI.fontFamily,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '@${player.login}',
                        style: TextStyle(
                          color: UI.textMuted,
                          fontSize: isSmall ? 10 : 12,
                          fontFamily: UI.fontFamily,
                          fontWeight: UI.fontWeightRegular,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: isSmall ? 80 : 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  player.total_points.toString(),
                  style: TextStyle(
                    color: UI.textPrimary,
                    fontSize: isSmall ? 12 : 14,
                    fontWeight: UI.fontWeightBold,
                    fontFamily: UI.fontFamily,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: group.id.isEmpty
                        ? UI.muted.withOpacity(0.2)
                        : _parseColor(group.color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: group.id.isEmpty
                          ? UI.muted
                          : _parseColor(group.color),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    group.name,
                    style: TextStyle(
                      color: group.id.isEmpty
                          ? UI.muted
                          : _parseColor(group.color),
                      fontSize: isSmall ? 8 : 10,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingFallbackAvatar(Player player, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: UI.primary.withOpacity(0.2), // Светлый оранжевый фон вместо градиента
        shape: BoxShape.circle,
        border: Border.all(color: UI.primary.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: UI.primary.withOpacity(0.1), // Более мягкая тень
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
          style: TextStyle(
            color: UI.primary, // Оранжевый текст на светлом фоне
            fontSize: size * 0.5,
            fontWeight: UI.fontWeightBold,
            fontFamily: UI.fontFamily,
          ),
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    final value =
        int.tryParse(hex.replaceFirst('#', ''), radix: 16) ?? 0xEC5E27;
    return Color(0xFF000000 | value);
  }
}

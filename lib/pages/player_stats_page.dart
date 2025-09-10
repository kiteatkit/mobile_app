import 'package:flutter/material.dart';

import '../models/player.dart';
import '../models/attendance.dart';
import '../models/training_session.dart';
import '../ui/ui_constants.dart';
import '../data/supabase_repository.dart';
import '../supabase_client.dart';
import '../widgets/back_button.dart';

class PlayerStatsPage extends StatefulWidget {
  const PlayerStatsPage({super.key, required this.player});

  final Player player;

  @override
  State<PlayerStatsPage> createState() => _PlayerStatsPageState();
}

class _PlayerStatsPageState extends State<PlayerStatsPage>
    with AutomaticKeepAliveClientMixin {
  final repo = SupabaseRepository();
  bool loading = true;
  List<Attendance> history = [];
  List<TrainingSession> recentTrainings = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);

    // Загружаем историю посещений с деталями тренировок
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final a = await SupabaseManager.client
        .from('attendance')
        .select('*, training_sessions(*)')
        .eq('player_id', widget.player.id)
        .lte('training_sessions.date', today.toIso8601String().split('T')[0])
        .order('created_at', ascending: false)
        .limit(20);

    // Загружаем последние 5 тренировок (только прошедшие)
    final startOfMonth = DateTime(now.year, now.month, 1);
    final trainings = await repo.getTrainingsInRange(startOfMonth, now);

    setState(() {
      final allHistory = (a as List)
          .map((e) => Attendance.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      // Фильтруем только прошедшие тренировки на уровне приложения
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      history = allHistory.where((h) {
        if (h.training_sessions == null) return false;
        final trainingDate = DateTime.parse(h.training_sessions!.date);
        final trainingDateOnly = DateTime(
          trainingDate.year,
          trainingDate.month,
          trainingDate.day,
        );
        return trainingDateOnly.isBefore(today.add(const Duration(days: 1)));
      }).toList();

      recentTrainings = trainings.take(5).toList();
      loading = false;
    });
  }

  int _attendanceRate() {
    if (history.isEmpty) return 0;
    final attended = history.where((e) => e.attended).length;
    return ((attended / history.length) * 100).round();
  }

  int _monthlyPoints() {
    if (history.isEmpty) return 0;

    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    return history.fold(0, (sum, attendance) {
      if (attendance.training_sessions == null) return sum;
      final trainingDate = DateTime.parse(attendance.training_sessions!.date);
      if (trainingDate.month == currentMonth &&
          trainingDate.year == currentYear) {
        return sum + attendance.points;
      }
      return sum;
    });
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } catch (e) {
      return dateStr;
    }
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

  String _getPointsText(int points) {
    if (points == 1) return '1 балл';
    if (points >= 2 && points <= 4) return '$points балла';
    return '$points баллов';
  }

  int _getTotalTrainingsCount() {
    if (history.isEmpty) return 0;
    return history.length;
  }

  String _getTrainingsText() {
    final attended = widget.player.attendance_count;
    final total = _getTotalTrainingsCount();
    return '$attended ${_getTrainingWord(attended)} из $total';
  }

  String _getTrainingWord(int count) {
    if (count == 1) return 'тренировка';
    if (count >= 2 && count <= 4) return 'тренировки';
    return 'тренировок';
  }

  Widget _buildFallbackAvatar() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [UI.primary, UI.primary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          widget.player.name.isNotEmpty
              ? widget.player.name[0].toUpperCase()
              : '?',
          style: const TextStyle(
            color: UI.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
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
                padding: UI.getScreenPadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Заголовок с кнопкой назад
                    Row(children: [const CustomBackButton()]),
                    SizedBox(height: UI.isSmallScreen(context) ? 16 : 24),

                    // Заголовок "Статистика игрока"
                    Text(
                      'Статистика игрока',
                      style: TextStyle(
                        fontSize: UI.getTitleFontSize(context),
                        fontWeight: FontWeight.bold,
                        color: UI.primary,
                      ),
                    ),
                    SizedBox(height: UI.isSmallScreen(context) ? 16 : 24),

                    // Профиль игрока
                    Center(
                      child: Column(
                        children: [
                          // Аватар
                          Container(
                            width: UI.isSmallScreen(context) ? 70 : 80,
                            height: UI.isSmallScreen(context) ? 70 : 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: UI.primary, width: 2),
                            ),
                            child: ClipOval(
                              child:
                                  widget.player.avatar_url != null &&
                                      widget.player.avatar_url!.isNotEmpty
                                  ? Image.network(
                                      widget.player.avatar_url!,
                                      width: UI.isSmallScreen(context)
                                          ? 70
                                          : 80,
                                      height: UI.isSmallScreen(context)
                                          ? 70
                                          : 80,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              _buildFallbackAvatar(),
                                    )
                                  : _buildFallbackAvatar(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Имя игрока
                          Text(
                            widget.player.name,
                            style: TextStyle(
                              color: UI.white,
                              fontSize: UI.getTitleFontSize(context),
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),

                          // Логин
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: UI.card,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: UI.border),
                            ),
                            child: Text(
                              '@${widget.player.login}',
                              style: TextStyle(
                                color: UI.white,
                                fontSize: UI.getBodyFontSize(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: UI.isSmallScreen(context) ? 24 : 32),

                    // Карточки статистики
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Сетка карточек - адаптивная
                            UI.isSmallScreen(context)
                                ? Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _StatCard(
                                              context: context,
                                              title:
                                                  'Очки за ${_getCurrentMonthName()}',
                                              value: '${_monthlyPoints()}',
                                              icon: Icons.emoji_events,
                                              iconColor: Colors.amber,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _StatCard(
                                              context: context,
                                              title: 'Посещено тренировок',
                                              value: _getTrainingsText(),
                                              subtitle:
                                                  'Процент посещаемости: ${_attendanceRate()}%',
                                              icon: Icons.calendar_today,
                                              iconColor: UI.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      _StatCard(
                                        context: context,
                                        title: 'Процент посещаемости',
                                        value: '${_attendanceRate()}%',
                                        icon: Icons.track_changes,
                                        iconColor: UI.primary,
                                        showProgress: true,
                                        progressValue: _attendanceRate() / 100,
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _StatCard(
                                              context: context,
                                              title:
                                                  'Очки за ${_getCurrentMonthName()}',
                                              value: '${_monthlyPoints()}',
                                              icon: Icons.emoji_events,
                                              iconColor: Colors.amber,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _StatCard(
                                              context: context,
                                              title: 'Посещено тренировок',
                                              value: _getTrainingsText(),
                                              subtitle:
                                                  'Процент посещаемости: ${_attendanceRate()}%',
                                              icon: Icons.calendar_today,
                                              iconColor: UI.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _StatCard(
                                              context: context,
                                              title: 'Процент посещаемости',
                                              value: '${_attendanceRate()}%',
                                              icon: Icons.track_changes,
                                              iconColor: UI.primary,
                                              showProgress: true,
                                              progressValue:
                                                  _attendanceRate() / 100,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                            SizedBox(
                              height: UI.isSmallScreen(context) ? 16 : 24,
                            ),

                            // История посещений
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: UI.white,
                                  size: UI.getIconSize(context),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'История посещений',
                                  style: TextStyle(
                                    color: UI.white,
                                    fontSize: UI.getSubtitleFontSize(context),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Список истории
                            Container(
                              decoration: BoxDecoration(
                                color: UI.card,
                                borderRadius: BorderRadius.circular(
                                  UI.radiusLg,
                                ),
                                border: Border.all(color: UI.border),
                              ),
                              child: history.isEmpty
                                  ? Padding(
                                      padding: UI.getCardPadding(context),
                                      child: Center(
                                        child: Text(
                                          'Нет данных о посещениях',
                                          style: TextStyle(
                                            color: UI.muted,
                                            fontSize: UI.getBodyFontSize(
                                              context,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: history.length,
                                      separatorBuilder: (_, __) =>
                                          const Divider(
                                            color: UI.border,
                                            height: 1,
                                          ),
                                      itemBuilder: (context, i) {
                                        final h = history[i];
                                        final ts = h.training_sessions;
                                        return Padding(
                                          padding: UI.getCardPadding(context),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: h.attended
                                                      ? Colors.green
                                                      : Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      ts != null
                                                          ? _formatDate(ts.date)
                                                          : 'Тренировка',
                                                      style: TextStyle(
                                                        color: UI.white,
                                                        fontSize: UI
                                                            .getBodyFontSize(
                                                              context,
                                                            ),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    if (ts?.title != null &&
                                                        ts!
                                                            .title
                                                            .isNotEmpty) ...[
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        ts.title,
                                                        style: TextStyle(
                                                          color: UI.muted,
                                                          fontSize:
                                                              UI.isSmallScreen(
                                                                context,
                                                              )
                                                              ? 12
                                                              : 14,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    h.attended
                                                        ? 'Присутствовал'
                                                        : 'Отсутствовал',
                                                    style: TextStyle(
                                                      color: h.attended
                                                          ? Colors.green
                                                          : Colors.red,
                                                      fontSize:
                                                          UI.isSmallScreen(
                                                            context,
                                                          )
                                                          ? 12
                                                          : 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  if (h.attended) ...[
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      _getPointsText(h.points),
                                                      style: TextStyle(
                                                        color: Colors.amber,
                                                        fontSize:
                                                            UI.isSmallScreen(
                                                              context,
                                                            )
                                                            ? 10
                                                            : 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
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
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.context,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.showProgress = false,
    this.progressValue = 0.0,
  });

  final BuildContext context;
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final bool showProgress;
  final double progressValue;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: UI.isSmallScreen(context) ? 120 : 140,
      child: Container(
        padding: UI.getCardPadding(context),
        decoration: BoxDecoration(
          color: UI.card,
          borderRadius: BorderRadius.circular(UI.radiusLg),
          border: Border.all(color: UI.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: UI.white,
                      fontSize: UI.isSmallScreen(context) ? 12 : 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (icon != null)
                  Icon(
                    icon,
                    color: iconColor ?? UI.primary,
                    size: UI.getIconSize(context),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: UI.primary,
                    fontSize: UI.isSmallScreen(context) ? 18 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: UI.white,
                      fontSize: UI.isSmallScreen(context) ? 10 : 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (showProgress) ...[
                  const SizedBox(height: 8),
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: UI.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progressValue.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: UI.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

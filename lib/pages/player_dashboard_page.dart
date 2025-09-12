import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/group.dart';
import '../ui/ui_constants.dart';
import '../data/supabase_repository.dart';
import 'package:go_router/go_router.dart';

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

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _currentPlayer = widget.player;
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

  Future<void> _loadData() async {
    try {
      final players = await _repository.getPlayers();
      final groups = await _repository.getGroups();

      setState(() {
        _allPlayers = players;
        _groups = groups;
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
        body: const Center(child: CircularProgressIndicator(color: UI.primary)),
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
              _buildHeader(context),
              SizedBox(height: UI.isSmallScreen(context) ? 16 : 24),
              _buildAchievementsSection(context),
              SizedBox(height: UI.isSmallScreen(context) ? 16 : 24),
              _buildTeamsSection(context),
              SizedBox(height: UI.isSmallScreen(context) ? 16 : 24),
              _buildRankingSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Панель игрока',
          style: TextStyle(
            fontSize: UI.getTitleFontSize(context),
            fontWeight: FontWeight.bold,
            color: UI.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Добро пожаловать, ${_currentPlayer.name}!',
          style: TextStyle(
            fontSize: UI.getBodyFontSize(context),
            color: UI.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildActionButtons(context),
      ],
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
          onTap: () => context.go('/'),
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
    return SizedBox(
      width: double.infinity,
      height: UI.getButtonHeight(context),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: UI.card,
          foregroundColor: UI.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UI.radiusLg),
            side: const BorderSide(color: UI.border),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: UI.getIconSize(context)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: UI.getBodyFontSize(context)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.emoji_events,
              color: UI.primary,
              size: UI.getIconSize(context),
            ),
            const SizedBox(width: 8),
            Text(
              'Мои достижения',
              style: TextStyle(
                fontSize: UI.getSubtitleFontSize(context),
                fontWeight: FontWeight.bold,
                color: UI.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildAchievementCard(
                context: context,
                title: 'Очки за ${_getCurrentMonthName()}',
                value: _currentPlayer.total_points.toString(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAchievementCard(
                context: context,
                title: 'Посещено тренировок',
                value: _currentPlayer.attendance_count.toString(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAchievementCard({
    required BuildContext context,
    required String title,
    required String value,
  }) {
    return Container(
      padding: UI.getCardPadding(context),
      decoration: BoxDecoration(
        color: UI.card,
        borderRadius: BorderRadius.circular(UI.radiusLg),
        border: Border.all(color: UI.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: UI.muted,
              fontSize: UI.isSmallScreen(context) ? 12 : 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: UI.white,
              fontSize: UI.isSmallScreen(context) ? 18 : 20,
              fontWeight: FontWeight.bold,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Команды',
          style: TextStyle(
            fontSize: UI.getSubtitleFontSize(context),
            fontWeight: FontWeight.bold,
            color: UI.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Нажмите на карточку команды, чтобы увидеть детальную информацию',
          style: TextStyle(
            color: UI.muted,
            fontSize: UI.isSmallScreen(context) ? 12 : 14,
          ),
        ),
        const SizedBox(height: 12),
        if (playerGroup != null)
          _TeamCard(
            context: context,
            group: playerGroup,
            allPlayers: _allPlayers,
            onTap: () => context.push(
              '/group-view',
              extra: {'group': playerGroup, 'isPlayerMode': true},
            ),
          )
        else
          Container(
            padding: UI.getCardPadding(context),
            decoration: BoxDecoration(
              color: UI.card,
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
    );
  }

  Widget _buildRankingSection(BuildContext context) {
    final sortedPlayers = List<Player>.from(_allPlayers)
      ..sort((a, b) => b.total_points.compareTo(a.total_points));

    final playersToShow = _isRankingExpanded
        ? sortedPlayers
        : sortedPlayers.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.emoji_events,
              color: UI.primary,
              size: UI.getIconSize(context),
            ),
            const SizedBox(width: 8),
            Text(
              'Рейтинг игроков',
              style: TextStyle(
                fontSize: UI.getSubtitleFontSize(context),
                fontWeight: FontWeight.bold,
                color: UI.primary,
              ),
            ),
            const Spacer(),
            if (sortedPlayers.length > 10)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isRankingExpanded = !_isRankingExpanded;
                  });
                },
                icon: Icon(
                  _isRankingExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 16,
                ),
                label: Text(
                  _isRankingExpanded ? 'Свернуть' : 'Показать всех',
                  style: TextStyle(
                    fontSize: UI.getBodyFontSize(context),
                    color: UI.primary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: UI.card,
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
    );
  }

  Widget _buildRankingHeader(BuildContext context) {
    return Container(
      padding: UI.getCardPadding(context),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: UI.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: UI.isSmallScreen(context) ? 30 : 40,
            child: Text(
              'Место',
              style: TextStyle(
                color: UI.muted,
                fontSize: UI.isSmallScreen(context) ? 10 : 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Игрок',
              style: TextStyle(
                color: UI.muted,
                fontSize: UI.isSmallScreen(context) ? 10 : 12,
              ),
            ),
          ),
          SizedBox(
            width: UI.isSmallScreen(context) ? 50 : 60,
            child: Text(
              'Очки',
              style: TextStyle(
                color: UI.muted,
                fontSize: UI.isSmallScreen(context) ? 10 : 12,
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
    required this.onTap,
  });

  final BuildContext context;
  final Group group;
  final List<Player> allPlayers;
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
    final averagePoints = groupPlayers.isNotEmpty
        ? groupPlayers.map((p) => p.total_points).reduce((a, b) => a + b) /
              groupPlayers.length
        : 0.0;

    // Сортируем игроков по очкам (по убыванию)
    final sortedPlayers = [...groupPlayers]
      ..sort((a, b) => b.total_points.compareTo(a.total_points));

    final topPlayers = sortedPlayers.take(3).toList();

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                      color: UI.white,
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
                        label: 'Средние очки:',
                        value: averagePoints.toStringAsFixed(0),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _TeamStat(
                          context: context,
                          label: 'Игроков:',
                          value: groupPlayers.length.toString(),
                        ),
                      ),
                      Expanded(
                        child: _TeamStat(
                          context: context,
                          label: 'Средние очки:',
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
                          color: UI.white,
                          fontSize: UI.isSmallScreen(context) ? 12 : 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      player.total_points.toString(),
                      style: TextStyle(
                        color: UI.white,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            color: UI.white,
            fontSize: UI.isSmallScreen(context) ? 14 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
      padding: UI.getCardPadding(context),
      decoration: BoxDecoration(
        color: isHighlighted ? UI.border.withOpacity(0.3) : Colors.transparent,
        border: position < 3
            ? const Border(bottom: BorderSide(color: UI.border))
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: isSmall ? 30 : 40,
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
                    color: UI.white,
                    fontSize: isSmall ? 12 : 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Container(
                  width: avatarSize,
                  height: avatarSize,
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
                          color: UI.white,
                          fontSize: isSmall ? 12 : 14,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '@${player.login}',
                        style: TextStyle(
                          color: UI.muted,
                          fontSize: isSmall ? 10 : 12,
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
                    color: UI.white,
                    fontSize: isSmall ? 12 : 14,
                    fontWeight: FontWeight.bold,
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

  Color _parseColor(String hex) {
    final value =
        int.tryParse(hex.replaceFirst('#', ''), radix: 16) ?? 0x3B82F6;
    return Color(0xFF000000 | value);
  }
}

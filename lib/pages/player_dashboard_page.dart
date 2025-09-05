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

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final players = await _repository.getPlayers();
      final groups = await _repository.getGroups();

      setState(() {
        _allPlayers = players;
        _groups = groups;
        _isLoading = false;
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildAchievementsSection(),
              const SizedBox(height: 24),
              _buildTeamsSection(),
              const SizedBox(height: 24),
              _buildRankingSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Панель игрока',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: UI.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Добро пожаловать, ${widget.player.name}!',
          style: const TextStyle(fontSize: 16, color: UI.white),
        ),
        const SizedBox(height: 16),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildActionButton(
          icon: Icons.person,
          text: 'Редактировать профиль',
          onTap: () => context.push('/profile', extra: widget.player),
        ),
        const SizedBox(height: 8),
        _buildActionButton(
          icon: Icons.visibility,
          text: 'Статистика',
          onTap: () => context.push('/stats', extra: widget.player),
        ),
        const SizedBox(height: 8),
        _buildActionButton(
          icon: Icons.exit_to_app,
          text: 'Выход',
          onTap: () => context.go('/'),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: UI.buttonHeight,
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
            Icon(icon, size: 20),
            const SizedBox(width: 12),
            Text(text),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.emoji_events, color: UI.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Мои достижения',
              style: TextStyle(
                fontSize: 18,
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
                title: 'Общие очки',
                value: widget.player.total_points.toString(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAchievementCard(
                title: 'Посещено тренировок',
                value: widget.player.attendance_count.toString(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAchievementCard({required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UI.card,
        borderRadius: BorderRadius.circular(UI.radiusLg),
        border: Border.all(color: UI.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: UI.muted, fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: UI.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamsSection() {
    final playerGroup = _groups.firstWhere(
      (group) => group.id == widget.player.group_id,
      orElse: () =>
          Group(id: '', name: 'Группа-1', created_at: '', updated_at: ''),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Команды',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: UI.primary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Нажмите на карточку команды, чтобы увидеть детальную информацию',
          style: TextStyle(color: UI.muted, fontSize: 14),
        ),
        const SizedBox(height: 12),
        _TeamCard(
          group: playerGroup,
          allPlayers: _allPlayers,
          onTap: () => context.push('/group-view', extra: playerGroup),
        ),
      ],
    );
  }

  Widget _buildRankingSection() {
    final sortedPlayers = List<Player>.from(_allPlayers)
      ..sort((a, b) => b.total_points.compareTo(a.total_points));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.emoji_events, color: UI.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Рейтинг игроков',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: UI.primary,
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
              _buildRankingHeader(),
              ...sortedPlayers.take(10).toList().asMap().entries.map((entry) {
                final index = entry.key;
                final player = entry.value;
                final isCurrentPlayer = player.id == widget.player.id;
                return _RankingRow(
                  position: index + 1,
                  player: player,
                  groups: _groups,
                  isHighlighted: isCurrentPlayer,
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRankingHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: UI.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              'Место',
              style: TextStyle(color: UI.muted, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Игрок',
              style: TextStyle(color: UI.muted, fontSize: 12),
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              'Очки',
              style: TextStyle(color: UI.muted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  const _TeamCard({
    required this.group,
    required this.allPlayers,
    required this.onTap,
  });

  final Group group;
  final List<Player> allPlayers;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final groupPlayers = allPlayers
        .where((p) => p.group_id == group.id)
        .toList();
    final averagePoints = groupPlayers.isNotEmpty
        ? groupPlayers.map((p) => p.total_points).reduce((a, b) => a + b) /
              groupPlayers.length
        : 0.0;

    final topPlayers = groupPlayers.take(2).toList();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
                Text(
                  group.name,
                  style: const TextStyle(
                    color: UI.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _TeamStat(
                    label: 'Игроков:',
                    value: groupPlayers.length.toString(),
                  ),
                ),
                Expanded(
                  child: _TeamStat(
                    label: 'Средние очки:',
                    value: averagePoints.toStringAsFixed(0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Топ игроки:',
              style: const TextStyle(color: UI.muted, fontSize: 14),
            ),
            const SizedBox(height: 8),
            ...topPlayers.asMap().entries.map((entry) {
              final index = entry.key;
              final player = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      index == 0 ? Icons.emoji_events : Icons.star,
                      color: index == 0 ? Colors.amber : UI.muted,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      player.name,
                      style: const TextStyle(color: UI.white, fontSize: 14),
                    ),
                    const Spacer(),
                    Text(
                      '${index + 1}',
                      style: const TextStyle(color: UI.muted, fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      player.total_points.toString(),
                      style: const TextStyle(color: UI.white, fontSize: 14),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class _TeamStat extends StatelessWidget {
  const _TeamStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: UI.muted, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: UI.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _RankingRow extends StatelessWidget {
  const _RankingRow({
    required this.position,
    required this.player,
    required this.groups,
    this.isHighlighted = false,
  });

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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlighted ? UI.border.withOpacity(0.3) : Colors.transparent,
        border: position < 3
            ? const Border(bottom: BorderSide(color: UI.border))
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Row(
              children: [
                Icon(
                  position == 1 ? Icons.emoji_events : Icons.star,
                  color: position == 1 ? Colors.amber : UI.muted,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '#$position',
                  style: const TextStyle(color: UI.white, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
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
                            width: 24,
                            height: 24,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildRankingFallbackAvatar(player),
                          )
                        : _buildRankingFallbackAvatar(player),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.name,
                        style: const TextStyle(
                          color: UI.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '@${player.login}',
                        style: const TextStyle(color: UI.muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  player.total_points.toString(),
                  style: const TextStyle(
                    color: UI.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    group.name,
                    style: const TextStyle(color: Colors.green, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingFallbackAvatar(Player player) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(color: UI.primary, shape: BoxShape.circle),
      child: Center(
        child: Text(
          player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: UI.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

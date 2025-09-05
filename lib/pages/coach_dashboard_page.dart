import 'package:flutter/material.dart';
import '../data/supabase_repository.dart';
import '../ui/ui_constants.dart';
import 'package:go_router/go_router.dart';
import '../models/group.dart';
import '../models/player.dart';
import '../widgets/group_selection_dialog.dart';
import '../widgets/training_schedule_dialog.dart';

class CoachDashboardPage extends StatefulWidget {
  const CoachDashboardPage({super.key});

  @override
  State<CoachDashboardPage> createState() => _CoachDashboardPageState();
}

class _CoachDashboardPageState extends State<CoachDashboardPage> {
  final repo = SupabaseRepository();
  bool loading = true;
  List<Group> groups = [];
  List<Player> players = [];
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final colorCtrl = TextEditingController(text: '#3B82F6');

  // Контроллеры для добавления игрока
  final playerNameCtrl = TextEditingController();
  final playerLoginCtrl = TextEditingController();
  final playerPasswordCtrl = TextEditingController();
  final playerBirthDateCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([repo.getGroups(), repo.getPlayers()]);
      setState(() {
        groups = results[0] as List<Group>;
        players = results[1] as List<Player>;
        loading = false;
      });
    } catch (_) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0C0B),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: UI.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        SizedBox(height: 16),
                        Text(
                          'Панель тренера',
                          style: TextStyle(
                            color: Color(0xFFFF8A00),
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Управляйте своей командой и мотивируйте игроков',
                          style: TextStyle(color: Color(0xFF9A9A9A)),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF24201E)),
                      backgroundColor: const Color(0xFF171412),
                    ),
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.logout, size: 16),
                    label: const Text('Выход'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Заголовок Команды
              const Center(
                child: Text(
                  'Команды',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Center(
                child: Text(
                  'Создайте команды и добавляйте игроков прямо в них',
                  style: TextStyle(color: Color(0xFF9A9A9A)),
                ),
              ),

              const SizedBox(height: 24),

              // Секция управления игроками
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: UI.card,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.people, color: Colors.white),
                        const SizedBox(width: 6),
                        const Expanded(
                          child: Text(
                            'Управление игроками',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _openAddPlayerDialog,
                              child: Container(
                                height: 32,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  gradient: UI.gradientPrimary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.person_add,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Добавить игрока',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: _openPlayersManagement,
                              child: Container(
                                height: 32,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: UI.card,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: UI.border),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.settings,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Управлять',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Всего игроков: ${players.length}',
                      style: const TextStyle(
                        color: Color(0xFF9A9A9A),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Без группы: ${players.where((p) => p.group_id == null).length}',
                      style: const TextStyle(
                        color: Color(0xFF9A9A9A),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Карточка списка команд
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: UI.card,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.groups, color: Colors.white),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Text(
                              'Команды',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _openCreateGroupDialog,
                            child: Container(
                              height: 32,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                gradient: UI.gradientPrimary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.add,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Добавить команду',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: groups.isEmpty
                            ? const Center(
                                child: Text(
                                  'Команды не найдены',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            : ListView.separated(
                                itemCount: groups.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final g = groups[index];
                                  final members = players
                                      .where((p) => p.group_id == g.id)
                                      .toList();
                                  final totalPoints = members.fold<int>(
                                    0,
                                    (s, p) => s + p.total_points,
                                  );

                                  return GestureDetector(
                                    onTap: () =>
                                        context.push('/group-view', extra: g),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFF24201E),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          // Левая цветная полоса
                                          Container(
                                            width: 4,
                                            height: 120,
                                            decoration: BoxDecoration(
                                              color: _parseColor(g.color),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                    topLeft: Radius.circular(8),
                                                    bottomLeft: Radius.circular(
                                                      8,
                                                    ),
                                                  ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 8,
                                                        height: 8,
                                                        decoration:
                                                            BoxDecoration(
                                                              color:
                                                                  _parseColor(
                                                                    g.color,
                                                                  ),
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Text(
                                                          g.name,
                                                          style:
                                                              const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 16,
                                                              ),
                                                        ),
                                                      ),
                                                      PopupMenuButton<String>(
                                                        color: const Color(
                                                          0xFF171412,
                                                        ),
                                                        icon: const Icon(
                                                          Icons.more_vert,
                                                          color: Colors.white,
                                                        ),
                                                        onSelected: (v) {
                                                          if (v == 'edit') {
                                                            _openEditGroupDialog(
                                                              g,
                                                            );
                                                          }
                                                          if (v == 'schedule') {
                                                            _openTrainingScheduleDialog(
                                                              g,
                                                            );
                                                          }
                                                          if (v == 'delete') {
                                                            _confirmDeleteGroup(
                                                              g,
                                                            );
                                                          }
                                                        },
                                                        itemBuilder: (context) => [
                                                          const PopupMenuItem(
                                                            value: 'edit',
                                                            child: Text(
                                                              'Редактировать',
                                                            ),
                                                          ),
                                                          const PopupMenuItem(
                                                            value: 'schedule',
                                                            child: Text(
                                                              'Расписание тренировок',
                                                            ),
                                                          ),
                                                          const PopupMenuItem(
                                                            value: 'delete',
                                                            child: Text(
                                                              'Удалить',
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Column(
                                                        children: const [
                                                          Icon(
                                                            Icons.person,
                                                            color: Color(
                                                              0xFFFF8A00,
                                                            ),
                                                          ),
                                                          SizedBox(height: 4),
                                                        ],
                                                      ),
                                                      Column(
                                                        children: [
                                                          Text(
                                                            '${members.length}',
                                                            style:
                                                                const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                          ),
                                                          const Text(
                                                            'Игроков',
                                                            style: TextStyle(
                                                              color: Color(
                                                                0xFF9A9A9A,
                                                              ),
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Column(
                                                        children: const [
                                                          Icon(
                                                            Icons.emoji_events,
                                                            color: Color(
                                                              0xFFFF8A00,
                                                            ),
                                                          ),
                                                          SizedBox(height: 4),
                                                        ],
                                                      ),
                                                      Column(
                                                        children: [
                                                          Text(
                                                            '$totalPoints',
                                                            style:
                                                                const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                          ),
                                                          const Text(
                                                            'Очков за месяц',
                                                            style: TextStyle(
                                                              color: Color(
                                                                0xFF9A9A9A,
                                                              ),
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  // Лидер команды
                                                  if (members.isNotEmpty)
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 6,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: UI.background,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          const Icon(
                                                            Icons.military_tech,
                                                            size: 14,
                                                            color: Color(
                                                              0xFFFF8A00,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 4,
                                                          ),
                                                          Text(
                                                            'Лидер команды',
                                                            style:
                                                                const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 12,
                                                                ),
                                                          ),
                                                          const SizedBox(
                                                            width: 4,
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              '${members.first.name} • ${members.first.total_points} очков за месяц',
                                                              style:
                                                                  const TextStyle(
                                                                    color: Color(
                                                                      0xFF9A9A9A,
                                                                    ),
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
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

  Color _parseColor(String hex) {
    final value =
        int.tryParse(hex.replaceFirst('#', ''), radix: 16) ?? 0x3B82F6;
    return Color(0xFF000000 | value);
  }

  Future<void> _openCreateGroupDialog() async {
    nameCtrl.clear();
    descCtrl.clear();
    colorCtrl.text = '#3B82F6';
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Новая команда'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Название'),
            ),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Описание'),
            ),
            TextField(
              controller: colorCtrl,
              decoration: const InputDecoration(labelText: 'Цвет (#RRGGBB)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              await repo.createGroup(
                name: nameCtrl.text.trim(),
                description: descCtrl.text.trim().isEmpty
                    ? null
                    : descCtrl.text.trim(),
                color: colorCtrl.text.trim().isEmpty
                    ? '#3B82F6'
                    : colorCtrl.text.trim(),
              );
              if (mounted) Navigator.pop(context);
              _load();
            },
            child: const Text('Создать'),
          ),
        ],
      ),
    );
  }

  Future<void> _openEditGroupDialog(Group g) async {
    nameCtrl.text = g.name;
    descCtrl.text = g.description ?? '';
    colorCtrl.text = g.color;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактировать команду'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Название'),
            ),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Описание'),
            ),
            TextField(
              controller: colorCtrl,
              decoration: const InputDecoration(labelText: 'Цвет (#RRGGBB)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () async {
              await repo.updateGroup(
                id: g.id,
                name: nameCtrl.text.trim(),
                description: descCtrl.text.trim(),
                color: colorCtrl.text.trim(),
              );
              if (mounted) Navigator.pop(context);
              _load();
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteGroup(Group g) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить команду?'),
        content: Text('Вы уверены, что хотите удалить "${g.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await repo.deleteGroup(g.id);
      _load();
    }
  }

  Future<void> _openAddPlayerDialog() async {
    playerNameCtrl.clear();
    playerLoginCtrl.clear();
    playerPasswordCtrl.clear();
    playerBirthDateCtrl.clear();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: UI.card,
        title: const Text(
          'Добавить игрока',
          style: TextStyle(color: UI.white, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: playerNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Имя игрока',
                labelStyle: TextStyle(color: UI.muted),
              ),
              style: const TextStyle(color: UI.white),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: playerLoginCtrl,
              decoration: const InputDecoration(
                labelText: 'Логин',
                labelStyle: TextStyle(color: UI.muted),
              ),
              style: const TextStyle(color: UI.white),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: playerPasswordCtrl,
              decoration: const InputDecoration(
                labelText: 'Пароль',
                labelStyle: TextStyle(color: UI.muted),
              ),
              style: const TextStyle(color: UI.white),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: playerBirthDateCtrl,
              decoration: const InputDecoration(
                labelText: 'Дата рождения (YYYY-MM-DD)',
                labelStyle: TextStyle(color: UI.muted),
              ),
              style: const TextStyle(color: UI.white),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Группа',
                labelStyle: TextStyle(color: UI.muted),
              ),
              dropdownColor: UI.card,
              value: null,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Без группы', style: TextStyle(color: UI.white)),
                ),
                ...groups.map(
                  (group) => DropdownMenuItem(
                    value: group.id,
                    child: Text(
                      group.name,
                      style: const TextStyle(color: UI.white),
                    ),
                  ),
                ),
              ],
              onChanged: (value) {
                // Сохраняем выбранную группу
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена', style: TextStyle(color: UI.muted)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (playerNameCtrl.text.trim().isEmpty ||
                  playerLoginCtrl.text.trim().isEmpty ||
                  playerPasswordCtrl.text.trim().isEmpty) {
                return;
              }

              await repo.addPlayer(
                name: playerNameCtrl.text.trim(),
                login: playerLoginCtrl.text.trim(),
                password: playerPasswordCtrl.text.trim(),
                birthDate: playerBirthDateCtrl.text.trim().isEmpty
                    ? null
                    : playerBirthDateCtrl.text.trim(),
                groupId: null, // Пока без группы, можно будет переместить потом
              );

              if (mounted) {
                Navigator.of(context).pop();
                _load();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: UI.primary,
              foregroundColor: UI.white,
            ),
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  Future<void> _openPlayersManagement() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: UI.card,
        title: const Text(
          'Управление игроками',
          style: TextStyle(color: UI.white, fontSize: 18),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: players.length,
            itemBuilder: (context, index) {
              final player = players[index];
              final playerGroup = player.group_id != null
                  ? groups.firstWhere(
                      (g) => g.id == player.group_id,
                      orElse: () => Group(
                        id: '',
                        name: 'Без группы',
                        created_at: '',
                        updated_at: '',
                      ),
                    )
                  : null;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: UI.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: UI.border),
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
                        child:
                            player.avatar_url != null &&
                                player.avatar_url!.isNotEmpty
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
                            style: const TextStyle(
                              color: UI.muted,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (playerGroup != null) ...[
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _parseColor(playerGroup.color),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  playerGroup.name,
                                  style: const TextStyle(
                                    color: UI.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ] else
                                const Text(
                                  'Без группы',
                                  style: TextStyle(
                                    color: UI.muted,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Кнопки управления
                    Row(
                      children: [
                        // Кнопка изменения группы
                        GestureDetector(
                          onTap: () => _changePlayerGroup(player),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: UI.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.swap_horiz,
                              color: UI.primary,
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Кнопка удаления игрока
                        GestureDetector(
                          onTap: () => _confirmDeletePlayer(player),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть', style: TextStyle(color: UI.muted)),
          ),
        ],
      ),
    );
  }

  Future<void> _changePlayerGroup(Player player) async {
    await showDialog(
      context: context,
      builder: (context) => GroupSelectionDialog(
        player: player,
        groups: groups,
        onGroupSelected: (group) async {
          await repo.updatePlayer(id: player.id, groupId: group?.id);
          _load();
        },
      ),
    );
  }

  Future<void> _confirmDeletePlayer(Player player) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: UI.card,
        title: const Text('Удалить игрока?', style: TextStyle(color: UI.white)),
        content: Text(
          'Вы уверены, что хотите удалить игрока "${player.name}"? Это действие нельзя отменить.',
          style: const TextStyle(color: UI.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена', style: TextStyle(color: UI.white)),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(UI.radiusSm),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Удалить', style: TextStyle(color: UI.white)),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Показываем индикатор загрузки
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        await repo.deletePlayer(player.id);
        await _load();
        if (mounted) {
          Navigator.pop(context); // Закрываем индикатор загрузки
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Игрок "${player.name}" удален'),
              backgroundColor: UI.primary,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Закрываем индикатор загрузки
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка при удалении игрока: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _openTrainingScheduleDialog(Group group) async {
    await showDialog(
      context: context,
      builder: (context) => TrainingScheduleDialog(
        group: group,
        onScheduleCreated: () {
          _load();
        },
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

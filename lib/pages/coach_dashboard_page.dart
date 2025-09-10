import 'package:flutter/material.dart';
import '../data/supabase_repository.dart';
import '../ui/ui_constants.dart';
import 'package:go_router/go_router.dart';
import '../models/group.dart';
import '../models/player.dart';
import '../widgets/player_details_dialog.dart';
// import '../widgets/training_schedule_dialog.dart';

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
  String selectedColor = '#3B82F6';

  // Предустановленные цвета для команд
  static const List<Map<String, dynamic>> predefinedColors = [
    {'name': 'Синий', 'value': '#3B82F6'},
    {'name': 'Красный', 'value': '#EF4444'},
    {'name': 'Зеленый', 'value': '#10B981'},
    {'name': 'Желтый', 'value': '#F59E0B'},
    {'name': 'Фиолетовый', 'value': '#8B5CF6'},
    {'name': 'Розовый', 'value': '#EC4899'},
    {'name': 'Оранжевый', 'value': '#F97316'},
    {'name': 'Бирюзовый', 'value': '#06B6D4'},
    {'name': 'Серый', 'value': '#6B7280'},
    {'name': 'Изумрудный', 'value': '#059669'},
  ];

  // Контроллеры для добавления игрока
  final playerFirstNameCtrl = TextEditingController();
  final playerLastNameCtrl = TextEditingController();
  final playerLoginCtrl = TextEditingController();
  final playerPasswordCtrl = TextEditingController();
  DateTime? selectedBirthDate;
  String? selectedGroupId;
  bool _obscurePlayerPassword = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _generateLogin(String firstName, String lastName) {
    // Генерируем логин на основе фамилии и имени
    final cleanFirstName = firstName.toLowerCase().replaceAll(
      RegExp(r'[^a-zа-я0-9]'),
      '',
    );
    final cleanLastName = lastName.toLowerCase().replaceAll(
      RegExp(r'[^a-zа-я0-9]'),
      '',
    );

    String baseLogin = '';
    if (cleanLastName.isNotEmpty) {
      baseLogin += cleanLastName.substring(
        0,
        cleanLastName.length > 4 ? 4 : cleanLastName.length,
      );
    }
    if (cleanFirstName.isNotEmpty) {
      baseLogin += cleanFirstName.substring(
        0,
        cleanFirstName.length > 3 ? 3 : cleanFirstName.length,
      );
    }

    if (baseLogin.isEmpty) {
      baseLogin = 'player';
    }

    final randomSuffix = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000))
        .toString();
    return '$baseLogin$randomSuffix';
  }

  String _generatePassword() {
    // Генерируем пароль из 6 цифр
    final random = DateTime.now().millisecondsSinceEpoch;
    return (100000 + (random % 900000)).toString();
  }

  void _updateLogin(StateSetter setDialogState) {
    // Автоматически генерируем логин при вводе фамилии или имени
    final firstName = playerFirstNameCtrl.text.trim();
    final lastName = playerLastNameCtrl.text.trim();

    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      playerLoginCtrl.text = _generateLogin(firstName, lastName);
      setDialogState(() {});
    }
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
          padding: UI.getScreenPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UI.isSmallScreen(context)
                  ? Column(
                      children: [
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Панель тренера',
                                style: TextStyle(
                                  color: UI.primary,
                                  fontSize: UI.getTitleFontSize(context),
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Color(0xFF24201E),
                                ),
                                backgroundColor: const Color(0xFF171412),
                              ),
                              onPressed: () => context.go('/'),
                              icon: const Icon(Icons.logout, size: 16),
                              label: const Text('Выход'),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 16),
                              Text(
                                'Панель тренера',
                                style: TextStyle(
                                  color: UI.primary,
                                  fontSize: UI.getTitleFontSize(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
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

              SizedBox(height: UI.isSmallScreen(context) ? 16 : 16),

              // Заголовок Команды
              Center(
                child: Text(
                  'Команды',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: UI.getSubtitleFontSize(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              SizedBox(height: UI.isSmallScreen(context) ? 16 : 24),

              // Секция управления игроками
              Container(
                padding: UI.getCardPadding(context),
                decoration: BoxDecoration(
                  color: UI.card,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UI.isSmallScreen(context)
                        ? Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.people, color: Colors.white),
                                  const SizedBox(width: 6),
                                  const Expanded(
                                    child: Text(
                                      'Управление игроками',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: _openAddPlayerDialog,
                                      child: Container(
                                        height: UI.getButtonHeight(context),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: UI.gradientPrimary,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: _openPlayersManagement,
                                      child: Container(
                                        height: UI.getButtonHeight(context),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: UI.card,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          border: Border.all(color: UI.border),
                                        ),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              const Icon(Icons.people, color: Colors.white),
                              const SizedBox(width: 6),
                              const Expanded(
                                child: Text(
                                  'Управление игроками',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
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
                      style: TextStyle(
                        color: UI.muted,
                        fontSize: UI.getBodyFontSize(context),
                      ),
                    ),
                    Text(
                      'Без группы: ${players.where((p) => p.group_id == null).length}',
                      style: TextStyle(
                        color: UI.muted,
                        fontSize: UI.getBodyFontSize(context),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Карточка списка команд
              Expanded(
                child: Container(
                  padding: UI.getCardPadding(context),
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
                              height: UI.getButtonHeight(context),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                gradient: UI.gradientPrimary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.add,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    UI.isSmallScreen(context)
                                        ? 'Добавить'
                                        : 'Добавить команду',
                                    style: const TextStyle(
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
                            ? Center(
                                child: Text(
                                  'Команды не найдены',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: UI.getBodyFontSize(context),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const ClampingScrollPhysics(),
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
                                          color: _parseColor(g.color),
                                          width: 2,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: UI.getCardPadding(
                                                context,
                                              ),
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
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: UI
                                                                .getBodyFontSize(
                                                                  context,
                                                                ),
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
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
                                                          // if (v == 'schedule') {
                                                          //   _openTrainingScheduleDialog(
                                                          //     g,
                                                          //   );
                                                          // }
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
                                                          // const PopupMenuItem(
                                                          //   value: 'schedule',
                                                          //   child: Text(
                                                          //     'Расписание тренировок',
                                                          //   ),
                                                          // ),
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
                                                  UI.isSmallScreen(context)
                                                      ? Column(
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              children: [
                                                                Column(
                                                                  children: [
                                                                    const Icon(
                                                                      Icons
                                                                          .person,
                                                                      color: Color(
                                                                        0xFFFF8A00,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 4,
                                                                    ),
                                                                    Text(
                                                                      '${members.length}',
                                                                      style: const TextStyle(
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
                                                                        fontSize:
                                                                            12,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Column(
                                                                  children: [
                                                                    const Icon(
                                                                      Icons
                                                                          .emoji_events,
                                                                      color: Color(
                                                                        0xFFFF8A00,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 4,
                                                                    ),
                                                                    Text(
                                                                      '$totalPoints',
                                                                      style: const TextStyle(
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
                                                                        fontSize:
                                                                            12,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        )
                                                      : Row(
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
                                                                SizedBox(
                                                                  height: 4,
                                                                ),
                                                              ],
                                                            ),
                                                            Column(
                                                              children: [
                                                                Text(
                                                                  '${members.length}',
                                                                  style: const TextStyle(
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
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Column(
                                                              children: const [
                                                                Icon(
                                                                  Icons
                                                                      .emoji_events,
                                                                  color: Color(
                                                                    0xFFFF8A00,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 4,
                                                                ),
                                                              ],
                                                            ),
                                                            Column(
                                                              children: [
                                                                Text(
                                                                  '$totalPoints',
                                                                  style: const TextStyle(
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
                                                                    fontSize:
                                                                        12,
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
    selectedColor = '#3B82F6';
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: UI.card,
          title: const Text(
            'Новая команда',
            style: TextStyle(color: UI.white, fontSize: 18),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Название команды',
                      labelStyle: TextStyle(color: UI.muted),
                    ),
                    style: const TextStyle(color: UI.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Выберите цвет:',
                    style: TextStyle(
                      color: UI.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: predefinedColors.map((colorData) {
                      final isSelected = selectedColor == colorData['value'];
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            selectedColor = colorData['value'];
                          });
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _parseColor(colorData['value']),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 24,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    predefinedColors.firstWhere(
                      (color) => color['value'] == selectedColor,
                    )['name'],
                    style: const TextStyle(color: UI.muted, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена', style: TextStyle(color: UI.muted)),
            ),
            FilledButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;

                try {
                  final newGroup = await repo.createGroup(
                    name: nameCtrl.text.trim(),
                    color: selectedColor,
                  );

                  if (mounted) {
                    Navigator.pop(context);
                    _load();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Команда успешно создана'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Предлагаем добавить игрока в новую команду
                    _showAddPlayerToNewTeamDialog(newGroup.id);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Ошибка при создании команды: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: UI.primary,
                foregroundColor: UI.white,
              ),
              child: const Text('Создать'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openEditGroupDialog(Group g) async {
    nameCtrl.text = g.name;
    selectedColor = g.color;
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: UI.card,
          title: const Text(
            'Редактировать команду',
            style: TextStyle(color: UI.white, fontSize: 18),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Название команды',
                      labelStyle: TextStyle(color: UI.muted),
                    ),
                    style: const TextStyle(color: UI.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Выберите цвет:',
                    style: TextStyle(
                      color: UI.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: predefinedColors.map((colorData) {
                      final isSelected = selectedColor == colorData['value'];
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            selectedColor = colorData['value'];
                          });
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _parseColor(colorData['value']),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 24,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    predefinedColors.firstWhere(
                      (color) => color['value'] == selectedColor,
                    )['name'],
                    style: const TextStyle(color: UI.muted, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена', style: TextStyle(color: UI.muted)),
            ),
            FilledButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;

                try {
                  await repo.updateGroup(
                    id: g.id,
                    name: nameCtrl.text.trim(),
                    color: selectedColor,
                  );

                  if (mounted) {
                    Navigator.pop(context);
                    _load();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Команда успешно обновлена'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Ошибка при обновлении команды: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: UI.primary,
                foregroundColor: UI.white,
              ),
              child: const Text('Сохранить'),
            ),
          ],
        ),
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

  Future<void> _showAddPlayerToNewTeamDialog(String newGroupId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: UI.card,
        title: const Text(
          'Добавить игрока в команду?',
          style: TextStyle(color: UI.white, fontSize: 18),
        ),
        content: const Text(
          'Хотите добавить игрока в только что созданную команду?',
          style: TextStyle(color: UI.muted, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Позже', style: TextStyle(color: UI.muted)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: UI.primary,
              foregroundColor: UI.white,
            ),
            child: const Text('Добавить игрока'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _openAddPlayerDialog(defaultGroupId: newGroupId);
    }
  }

  Future<void> _openAddPlayerDialog({String? defaultGroupId}) async {
    playerFirstNameCtrl.clear();
    playerLastNameCtrl.clear();
    playerLoginCtrl.clear();
    playerPasswordCtrl.text =
        _generatePassword(); // Автоматически генерируем пароль
    selectedBirthDate = null;
    selectedGroupId = defaultGroupId;
    _obscurePlayerPassword = true;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: UI.card,
          title: const Text(
            'Добавить игрока',
            style: TextStyle(color: UI.white, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: playerLastNameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Фамилия',
                        labelStyle: const TextStyle(color: UI.muted),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: UI.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: UI.primary),
                        ),
                        filled: true,
                        fillColor: UI.card,
                      ),
                      style: const TextStyle(color: UI.white),
                      onChanged: (value) {
                        _updateLogin(setDialogState);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: playerFirstNameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Имя',
                        labelStyle: const TextStyle(color: UI.muted),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: UI.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: UI.primary),
                        ),
                        filled: true,
                        fillColor: UI.card,
                      ),
                      style: const TextStyle(color: UI.white),
                      onChanged: (value) {
                        _updateLogin(setDialogState);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: playerLoginCtrl,
                      decoration: InputDecoration(
                        labelText: 'Логин',
                        labelStyle: const TextStyle(color: UI.muted),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: UI.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: UI.primary),
                        ),
                        filled: true,
                        fillColor: UI.card,
                      ),
                      style: const TextStyle(color: UI.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      _updateLogin(setDialogState);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UI.primary,
                      foregroundColor: UI.white,
                      minimumSize: const Size(80, 40),
                    ),
                    child: const Text('Генерировать'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: playerPasswordCtrl,
                      decoration: InputDecoration(
                        labelText: 'Пароль',
                        labelStyle: const TextStyle(color: UI.muted),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: UI.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: UI.primary),
                        ),
                        filled: true,
                        fillColor: UI.card,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePlayerPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: UI.muted,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              _obscurePlayerPassword = !_obscurePlayerPassword;
                            });
                          },
                        ),
                      ),
                      style: const TextStyle(color: UI.white),
                      obscureText: _obscurePlayerPassword,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      playerPasswordCtrl.text = _generatePassword();
                      setDialogState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UI.primary,
                      foregroundColor: UI.white,
                      minimumSize: const Size(80, 40),
                    ),
                    child: const Text('Генерировать'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate:
                        selectedBirthDate ??
                        DateTime.now().subtract(const Duration(days: 365 * 18)),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: UI.primary,
                            onPrimary: UI.white,
                            surface: UI.card,
                            onSurface: UI.white,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (date != null) {
                    setDialogState(() {
                      selectedBirthDate = date;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: UI.card,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: UI.muted.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: UI.muted,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        selectedBirthDate != null
                            ? '${selectedBirthDate!.day.toString().padLeft(2, '0')}.${selectedBirthDate!.month.toString().padLeft(2, '0')}.${selectedBirthDate!.year}'
                            : 'Выберите дату рождения',
                        style: TextStyle(
                          color: selectedBirthDate != null
                              ? UI.white
                              : UI.muted,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Группа',
                  labelStyle: TextStyle(color: UI.muted),
                ),
                dropdownColor: UI.card,
                initialValue: selectedGroupId,
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text(
                      'Без группы',
                      style: TextStyle(color: UI.white),
                    ),
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
                  setDialogState(() {
                    selectedGroupId = value;
                  });
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
                final firstName = playerFirstNameCtrl.text.trim();
                final lastName = playerLastNameCtrl.text.trim();

                if (firstName.isEmpty ||
                    lastName.isEmpty ||
                    playerLoginCtrl.text.trim().isEmpty ||
                    playerPasswordCtrl.text.trim().isEmpty) {
                  return;
                }

                try {
                  await repo.addPlayer(
                    name: '$lastName $firstName',
                    login: playerLoginCtrl.text.trim(),
                    password: playerPasswordCtrl.text.trim(),
                    birthDate: selectedBirthDate != null
                        ? '${selectedBirthDate!.year}-${selectedBirthDate!.month.toString().padLeft(2, '0')}-${selectedBirthDate!.day.toString().padLeft(2, '0')}'
                        : null,
                    groupId: selectedGroupId,
                  );

                  if (mounted) {
                    Navigator.of(context).pop();
                    _load();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Игрок успешно добавлен'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Ошибка при создании игрока: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
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
      ),
    );
  }

  Future<void> _openPlayersManagement() async {
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
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

                return GestureDetector(
                  onTap: () => _showPlayerDetails(player),
                  child: Container(
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
                                    errorBuilder:
                                        (context, error, stackTrace) =>
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
                              onTap: () async {
                                await _changePlayerGroup(player);
                                setDialogState(() {}); // Обновляем диалог
                              },
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
                              onTap: () async {
                                await _confirmDeletePlayer(player);
                                setDialogState(() {}); // Обновляем диалог
                              },
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
      ),
    );
  }

  Future<void> _changePlayerGroup(Player player) async {
    selectedGroupId = player.group_id;
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: UI.card,
          title: Text(
            'Переместить ${player.name}',
            style: const TextStyle(color: UI.white, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Выберите команду',
                  labelStyle: TextStyle(color: UI.muted),
                ),
                dropdownColor: UI.card,
                initialValue: selectedGroupId,
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text(
                      'Без группы',
                      style: TextStyle(color: UI.white),
                    ),
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
                  setDialogState(() {
                    selectedGroupId = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена', style: TextStyle(color: UI.muted)),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  print(
                    'Обновляем игрока ${player.name} с groupId: $selectedGroupId',
                  );
                  await repo.updatePlayer(
                    id: player.id,
                    name: player.name,
                    birthDate: player.birth_date,
                    login: player.login,
                    password: player.password,
                    avatarUrl: player.avatar_url,
                    groupId: selectedGroupId,
                  );

                  if (mounted) {
                    Navigator.of(context).pop();

                    // Мгновенно обновляем локальные данные
                    setState(() {
                      final playerIndex = players.indexWhere(
                        (p) => p.id == player.id,
                      );
                      if (playerIndex != -1) {
                        players[playerIndex] = Player(
                          id: player.id,
                          name: player.name,
                          birth_date: player.birth_date,
                          login: player.login,
                          password: player.password,
                          avatar_url: player.avatar_url,
                          group_id: selectedGroupId,
                          total_points: player.total_points,
                          created_at: player.created_at,
                          updated_at: player.updated_at,
                        );
                      }
                    });

                    // Затем обновляем данные с сервера
                    _load();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Игрок перемещен в команду${selectedGroupId != null ? ' (ID: $selectedGroupId)' : ' (удален из группы)'}',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  print('Ошибка при обновлении игрока: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Ошибка при перемещении игрока: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: UI.primary,
                foregroundColor: UI.white,
              ),
              child: const Text('Переместить'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlayerDetails(Player player) {
    showDialog(
      context: context,
      builder: (context) => PlayerDetailsDialog(player: player),
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

  // Future<void> _openTrainingScheduleDialog(Group group) async {
  //   await showDialog(
  //     context: context,
  //     builder: (context) => TrainingScheduleDialog(
  //       group: group,
  //       onScheduleCreated: () {
  //         _load();
  //       },
  //     ),
  //   );
  // }

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

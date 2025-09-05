import 'package:flutter/material.dart';
import '../ui/ui_constants.dart';

import '../data/supabase_repository.dart';
import '../models/group.dart';
import '../models/player.dart';
import '../models/training_session.dart';
import '../models/attendance.dart';

class GroupViewPage extends StatefulWidget {
  const GroupViewPage({super.key, required this.group});

  final Group group;

  @override
  State<GroupViewPage> createState() => _GroupViewPageState();
}

class _GroupViewPageState extends State<GroupViewPage> {
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
  void initState() {
    super.initState();
    _hScroll = ScrollController();
    _vScroll = ScrollController();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final start = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final end = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);
    final p = await repo.getPlayers(groupId: widget.group.id);
    final ts = await repo.getTrainingsInRange(start, end);
    final a = await repo.getAttendanceForSessions(ts.map((t) => t.id).toList());
    setState(() {
      players = p;
      trainings = ts;
      attendanceMap = {for (final r in a) '${r.session_id}_${r.player_id}': r};
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

  Player? get _leader {
    if (players.isEmpty) return null;
    final copy = [...players];
    copy.sort((a, b) => _monthlyTotal(b.id).compareTo(_monthlyTotal(a.id)));
    return copy.first;
  }

  Future<void> _editTrainingDate(TrainingSession t) async {
    final ctrl = TextEditingController(text: t.date);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Изменить дату тренировки'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'YYYY-MM-DD'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await repo.updateTrainingDate(
          sessionId: t.id,
          date: DateTime.parse(ctrl.text),
        );
        _load();
      } catch (_) {}
    }
  }

  Future<void> _deleteTraining(TrainingSession t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить тренировку?'),
        content: Text('"${t.title}"'),
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
      await repo.deleteTrainingSession(t.id);
      _load();
    }
  }

  Future<void> _editPoints({
    required Player player,
    required TrainingSession training,
  }) async {
    final current = _pointsFor(player.id, training.id);
    final ctrl = TextEditingController(text: '$current');
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Очки: ${player.name} — ${training.title}'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Введите очки'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
    if (ok == true) {
      final val = int.tryParse(ctrl.text) ?? 0;
      await repo.updateAttendancePoints(
        sessionId: training.id,
        playerId: player.id,
        points: val,
      );
      // refresh only this cell
      setState(() {
        final key = '${training.id}_${player.id}';
        attendanceMap[key] = Attendance(
          id: attendanceMap[key]?.id ?? '',
          player_id: player.id,
          session_id: training.id,
          attended: val > 0,
          points: val,
          created_at:
              attendanceMap[key]?.created_at ??
              DateTime.now().toIso8601String(),
          training_sessions: training,
        );
      });
    }
  }

  Future<void> _managePlayers() async {
    final nameCtrl = TextEditingController();
    final loginCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text('Игроки команды'),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: 'Имя'),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: loginCtrl,
                        decoration: const InputDecoration(labelText: 'Логин'),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: passCtrl,
                        decoration: const InputDecoration(labelText: 'Пароль'),
                        obscureText: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () async {
                      if (nameCtrl.text.trim().isEmpty ||
                          loginCtrl.text.trim().isEmpty ||
                          passCtrl.text.isEmpty) {
                        return;
                      }
                      await repo.addPlayer(
                        name: nameCtrl.text.trim(),
                        login: loginCtrl.text.trim(),
                        password: passCtrl.text,
                        groupId: widget.group.id,
                      );
                      nameCtrl.clear();
                      loginCtrl.clear();
                      passCtrl.clear();
                      final p = await repo.getPlayers(groupId: widget.group.id);
                      setState(() {
                        players = p;
                      });
                      setLocal(() {});
                    },
                    child: const Text('Добавить игрока'),
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: players.isEmpty
                      ? const Text('Игроки не найдены')
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: players.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final p = players[i];
                            return ListTile(
                              title: Text(p.name),
                              subtitle: Text('@${p.login}'),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.remove_circle,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  await repo.removePlayerFromGroup(p.id);
                                  final updated = await repo.getPlayers(
                                    groupId: widget.group.id,
                                  );
                                  setState(() {
                                    players = updated;
                                  });
                                  setLocal(() {});
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть'),
            ),
          ],
        ),
      ),
    );
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

  @override
  void dispose() {
    _hScroll.dispose();
    _vScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UI.background,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Заголовок с индикатором и названием группы
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Color(
                              int.parse(
                                widget.group.color.replaceFirst('#', '0xFF'),
                              ),
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.group.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Кнопки действий
                    Column(
                      children: [
                        // Добавить игрока
                        GestureDetector(
                          onTap: _managePlayers,
                          child: Container(
                            height: UI.buttonHeight,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: UI.gradientPrimary,
                              borderRadius: BorderRadius.circular(UI.radiusSm),
                            ),
                            child: const Center(
                              child: Text(
                                'Добавить игрока',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Настройки
                        GestureDetector(
                          onTap: () {}, // TODO: реализовать
                          child: Container(
                            height: UI.buttonHeight,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: UI.card,
                              border: Border.all(color: UI.border),
                              borderRadius: BorderRadius.circular(UI.radiusSm),
                            ),
                            child: const Center(
                              child: Text(
                                'Настройки',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Закрыть
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: UI.buttonHeight,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: UI.card,
                              border: Border.all(color: UI.border),
                              borderRadius: BorderRadius.circular(UI.radiusSm),
                            ),
                            child: const Center(
                              child: Text(
                                'Закрыть',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Блок статистики
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 64,
                            decoration: BoxDecoration(
                              color: UI.card,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.emoji_events,
                                  color: UI.primary,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${players.fold<int>(0, (s, p) => s + _monthlyTotal(p.id))}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const Text(
                                  'Очки за месяц',
                                  style: TextStyle(
                                    color: Color(0xFF9A9A9A),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (players.isNotEmpty)
                          Expanded(
                            child: Container(
                              height: 64,
                              decoration: BoxDecoration(
                                color: const Color(0xFF171412),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.military_tech,
                                    color: UI.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _leader?.name ?? '-',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    _leader == null
                                        ? ''
                                        : '${_monthlyTotal(_leader!.id)} очков за месяц',
                                    style: const TextStyle(
                                      color: Color(0xFF9A9A9A),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Фильтр месяц и кнопки
                    Row(
                      children: [
                        const Text(
                          'Месяц:',
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<DateTime>(
                          dropdownColor: const Color(0xFF171412),
                          value: selectedMonth,
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
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }),
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => selectedMonth = v);
                            _load();
                          },
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () async {
                            final session = await repo.createTrainingSession(
                              date: DateTime.now(),
                              title: 'Тренировка ${DateTime.now().day}',
                            );
                            await repo.insertAttendanceBatch(
                              sessionId: session.id,
                              records: [
                                for (final p in players)
                                  {
                                    'player_id': p.id,
                                    'attended': true,
                                    'points': 1,
                                  },
                              ],
                            );
                            _load();
                          },
                          child: Container(
                            height: UI.buttonHeight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              gradient: UI.gradientPrimary,
                              borderRadius: BorderRadius.circular(UI.radiusSm),
                            ),
                            child: const Center(
                              child: Text(
                                'Тренировка',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: UI.border),
                            backgroundColor: UI.card,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(UI.radiusSm),
                            ),
                          ),
                          onPressed: _managePlayers,
                          child: const Text('Игроки'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Таблица
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(UI.radiusSm),
                        child: Container(
                          decoration: BoxDecoration(
                            color: UI.card,
                            border: Border.all(color: UI.border),
                            borderRadius: BorderRadius.circular(UI.radiusSm),
                          ),
                          child: Scrollbar(
                            controller: _hScroll,
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              controller: _hScroll,
                              scrollDirection: Axis.horizontal,
                              child: DataTableTheme(
                                data: DataTableThemeData(
                                  headingRowColor: MaterialStateProperty.all(
                                    UI.card,
                                  ),
                                  headingTextStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  dataRowColor: MaterialStateProperty.all(
                                    UI.background,
                                  ),
                                  dataTextStyle: const TextStyle(
                                    color: Colors.white,
                                  ),
                                  dividerThickness: 0.5,
                                  dataRowMinHeight: 40,
                                  dataRowMaxHeight: 40,
                                  headingRowHeight: 44,
                                ),
                                child: DataTable(
                                  columnSpacing: 24,
                                  horizontalMargin: 12,
                                  columns: [
                                    const DataColumn(label: Text('Игрок')),
                                    ...trainings.map(
                                      (t) => DataColumn(
                                        label: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(t.title),
                                            const SizedBox(width: 6),
                                            InkWell(
                                              onTap: () => _editTrainingDate(t),
                                              child: const Icon(
                                                Icons.edit,
                                                size: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            InkWell(
                                              onTap: () => _deleteTraining(t),
                                              child: const Icon(
                                                Icons.delete,
                                                size: 16,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const DataColumn(label: Text('Итого')),
                                  ],
                                  rows: [
                                    for (final p
                                        in (players..sort(
                                          (a, b) => _monthlyTotal(
                                            b.id,
                                          ).compareTo(_monthlyTotal(a.id)),
                                        )))
                                      DataRow(
                                        color: p.id == _leader?.id
                                            ? MaterialStateProperty.all(
                                                const Color(0x1AFF8A00),
                                              )
                                            : null,
                                        cells: [
                                          DataCell(
                                            Row(
                                              children: [
                                                if (p.id == _leader?.id)
                                                  const Icon(
                                                    Icons.military_tech,
                                                    color: UI.primary,
                                                    size: 16,
                                                  ),
                                                if (p.id == _leader?.id)
                                                  const SizedBox(width: 4),
                                                Text(p.name),
                                              ],
                                            ),
                                          ),
                                          ...trainings.map(
                                            (t) => DataCell(
                                              Text('${_pointsFor(p.id, t.id)}'),
                                              onTap: () => _editPoints(
                                                player: p,
                                                training: t,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text('${_monthlyTotal(p.id)}'),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
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
}

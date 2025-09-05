import 'package:flutter/material.dart';
import '../models/group.dart';
import '../ui/ui_constants.dart';

class TrainingScheduleDialog extends StatefulWidget {
  const TrainingScheduleDialog({
    super.key,
    required this.group,
    this.onScheduleCreated,
  });

  final Group group;
  final VoidCallback? onScheduleCreated;

  @override
  State<TrainingScheduleDialog> createState() => _TrainingScheduleDialogState();
}

class _TrainingScheduleDialogState extends State<TrainingScheduleDialog> {
  final titleCtrl = TextEditingController();
  final startTimeCtrl = TextEditingController();
  final endTimeCtrl = TextEditingController();

  List<int> selectedWeekdays = [];

  final List<Map<String, dynamic>> weekdays = [
    {'value': 1, 'name': 'Понедельник', 'short': 'Пн'},
    {'value': 2, 'name': 'Вторник', 'short': 'Вт'},
    {'value': 3, 'name': 'Среда', 'short': 'Ср'},
    {'value': 4, 'name': 'Четверг', 'short': 'Чт'},
    {'value': 5, 'name': 'Пятница', 'short': 'Пт'},
    {'value': 6, 'name': 'Суббота', 'short': 'Сб'},
    {'value': 7, 'name': 'Воскресенье', 'short': 'Вс'},
  ];

  @override
  void initState() {
    super.initState();
    startTimeCtrl.text = '18:00';
    endTimeCtrl.text = '19:30';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: UI.card,
      title: Text(
        'Расписание тренировок - ${widget.group.name}',
        style: const TextStyle(color: UI.white, fontSize: 18),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Название тренировки
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Название тренировки',
                labelStyle: TextStyle(color: UI.muted),
              ),
              style: const TextStyle(color: UI.white),
            ),
            const SizedBox(height: 16),

            // Время тренировки
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: startTimeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Начало (HH:MM)',
                      labelStyle: TextStyle(color: UI.muted),
                    ),
                    style: const TextStyle(color: UI.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: endTimeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Конец (HH:MM)',
                      labelStyle: TextStyle(color: UI.muted),
                    ),
                    style: const TextStyle(color: UI.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Дни недели
            const Text(
              'Дни недели:',
              style: TextStyle(
                color: UI.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Сетка дней недели
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: weekdays.length,
              itemBuilder: (context, index) {
                final day = weekdays[index];
                final isSelected = selectedWeekdays.contains(day['value']);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedWeekdays.remove(day['value']);
                      } else {
                        selectedWeekdays.add(day['value']);
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? UI.primary : UI.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? UI.primary : UI.border,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        day['short'],
                        style: TextStyle(
                          color: isSelected ? UI.white : UI.muted,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Информация о создании тренировок
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: UI.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: UI.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: UI.primary, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Тренировки будут автоматически создаваться в выбранные дни недели',
                      style: TextStyle(color: UI.muted, fontSize: 12),
                    ),
                  ),
                ],
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
          onPressed: selectedWeekdays.isEmpty || titleCtrl.text.trim().isEmpty
              ? null
              : () async {
                  // Здесь будет логика создания расписания
                  if (widget.onScheduleCreated != null) {
                    widget.onScheduleCreated!();
                  }
                  Navigator.of(context).pop();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: UI.primary,
            foregroundColor: UI.white,
          ),
          child: const Text('Создать расписание'),
        ),
      ],
    );
  }
}

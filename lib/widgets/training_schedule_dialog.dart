import 'package:flutter/material.dart';
import '../models/group.dart';
import '../ui/ui_constants.dart';
import '../data/supabase_repository.dart';

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
  final repo = SupabaseRepository();

  List<int> selectedWeekdays = [];
  bool _isLoading = false;

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

    // Добавляем слушатели для обновления состояния кнопки
    titleCtrl.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    titleCtrl.removeListener(_updateButtonState);
    titleCtrl.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {
      // Обновляем состояние для перерисовки кнопки
    });
  }

  bool get _canCreateSchedule {
    return !_isLoading &&
        selectedWeekdays.isNotEmpty &&
        titleCtrl.text.trim().isNotEmpty;
  }

  String _getButtonHint() {
    if (titleCtrl.text.trim().isEmpty) {
      return 'Введите адрес тренировки';
    }
    if (selectedWeekdays.isEmpty) {
      return 'Выберите дни недели';
    }
    return '';
  }

  Future<void> _createSchedule() async {
    if (selectedWeekdays.isEmpty || titleCtrl.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await repo.createTrainingSchedule(
        groupId: widget.group.id,
        title: titleCtrl.text.trim(),
        weekdays: selectedWeekdays,
        startTime: '18:00',
        endTime: '19:30',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Расписание для группы "${widget.group.name}" создано',
            ),
            backgroundColor: UI.primary,
          ),
        );

        if (widget.onScheduleCreated != null) {
          widget.onScheduleCreated!();
        }

        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при создании расписания: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: UI.card,
      title: Text(
        'Расписание тренировок - ${widget.group.name}',
        style: TextStyle(
          color: UI.white,
          fontSize: UI.getSubtitleFontSize(context),
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Адрес тренировки
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: UI.white),
                decoration: InputDecoration(
                  labelText: 'Адрес тренировки',
                  labelStyle: const TextStyle(color: UI.muted),
                  filled: true,
                  fillColor: UI.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(UI.radiusSm),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Дни недели
              Text(
                'Дни недели:',
                style: TextStyle(
                  color: UI.white,
                  fontSize: UI.getBodyFontSize(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Сетка дней недели
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: UI.isSmallScreen(context) ? 2 : 3,
                  childAspectRatio: UI.isSmallScreen(context) ? 2.5 : 2,
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
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(
            'Отмена',
            style: TextStyle(
              color: UI.muted,
              fontSize: UI.getBodyFontSize(context),
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: _canCreateSchedule ? _createSchedule : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canCreateSchedule ? UI.primary : UI.muted,
                foregroundColor: UI.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(UI.radiusSm),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Создать расписание',
                      style: TextStyle(fontSize: UI.getBodyFontSize(context)),
                    ),
            ),
            if (!_canCreateSchedule && !_isLoading) ...[
              const SizedBox(height: 8),
              Text(
                _getButtonHint(),
                style: TextStyle(
                  color: UI.muted,
                  fontSize: UI.isSmallScreen(context) ? 10 : 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

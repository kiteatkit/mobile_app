import 'package:flutter/material.dart';
import '../models/group.dart';
import '../models/scheduled_training.dart';
import '../ui/ui_constants.dart';
import '../data/supabase_repository.dart';

class ScheduledTrainingsDialog extends StatefulWidget {
  const ScheduledTrainingsDialog({
    super.key,
    required this.group,
    this.onTrainingCreated,
  });

  final Group group;
  final VoidCallback? onTrainingCreated;

  @override
  State<ScheduledTrainingsDialog> createState() =>
      _ScheduledTrainingsDialogState();
}

class _ScheduledTrainingsDialogState extends State<ScheduledTrainingsDialog> {
  final repo = SupabaseRepository();
  bool _isLoading = true;
  List<ScheduledTraining> _scheduledTrainings = [];

  @override
  void initState() {
    super.initState();
    _loadScheduledTrainings();
  }

  Future<void> _loadScheduledTrainings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final trainings = await repo.getScheduledTrainings(
        groupId: widget.group.id,
      );

      setState(() {
        _scheduledTrainings = trainings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при загрузке расписания: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    const weekdays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return '${weekdays[date.weekday - 1]}, ${date.day}.${date.month}.${date.year}';
  }

  String _formatTime(String time) {
    return time;
  }

  Future<void> _createTraining(ScheduledTraining scheduledTraining) async {
    try {
      await repo.createTrainingFromScheduled(
        scheduledTraining: scheduledTraining,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Тренировка "${scheduledTraining.title}" создана'),
            backgroundColor: UI.primary,
          ),
        );

        if (widget.onTrainingCreated != null) {
          widget.onTrainingCreated!();
        }

        // Перезагружаем список
        await _loadScheduledTrainings();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при создании тренировки: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteScheduledTraining(
    ScheduledTraining scheduledTraining,
  ) async {
    try {
      await repo.deleteScheduledTraining(scheduledTraining.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Запланированная тренировка "${scheduledTraining.title}" удалена',
            ),
            backgroundColor: UI.primary,
          ),
        );

        // Перезагружаем список
        await _loadScheduledTrainings();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при удалении тренировки: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final isSmallScreen = screenWidth < 600;

    return Dialog(
      backgroundColor: UI.card,
      child: Container(
        width: isSmallScreen ? screenWidth * 0.98 : 700,
        height: isSmallScreen ? screenHeight * 0.8 : 600,
        padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Заголовок
            Row(
              children: [
                Icon(Icons.schedule, color: UI.primary, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Очередь тренировок - ${widget.group.name}',
                    style: TextStyle(
                      color: UI.white,
                      fontSize: UI.getSubtitleFontSize(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: UI.muted),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Контент
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: UI.primary),
                    )
                  : _scheduledTrainings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.schedule, color: UI.muted, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'Нет запланированных тренировок',
                            style: TextStyle(
                              color: UI.muted,
                              fontSize: UI.getBodyFontSize(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Создайте расписание для группы',
                            style: TextStyle(
                              color: UI.muted.withOpacity(0.7),
                              fontSize: UI.isSmallScreen(context) ? 12 : 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _scheduledTrainings.length,
                      itemBuilder: (context, index) {
                        final training = _scheduledTrainings[index];
                        final date = DateTime.parse(training.date);
                        final isPast = date.isBefore(
                          DateTime.now().subtract(const Duration(days: 1)),
                        );

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                          decoration: BoxDecoration(
                            color: UI.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isPast
                                  ? UI.muted.withOpacity(0.3)
                                  : UI.border,
                            ),
                          ),
                          child: isSmallScreen
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Заголовок с иконкой
                                    Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: isPast
                                                ? UI.muted.withOpacity(0.2)
                                                : UI.primary.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.calendar_today,
                                            color: isPast
                                                ? UI.muted
                                                : UI.primary,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            training.title,
                                            style: TextStyle(
                                              color: isPast
                                                  ? UI.muted
                                                  : UI.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // Дата и время
                                    Text(
                                      _formatDate(date),
                                      style: TextStyle(
                                        color: isPast
                                            ? UI.muted.withOpacity(0.7)
                                            : UI.muted,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${_formatTime(training.start_time)} - ${_formatTime(training.end_time)}',
                                      style: TextStyle(
                                        color: isPast
                                            ? UI.muted.withOpacity(0.7)
                                            : UI.muted,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // Кнопки управления для мобильной версии
                                    if (!isPast) ...[
                                      GestureDetector(
                                        onTap: () => _createTraining(training),
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: UI.gradientPrimary,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.add,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Создать',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      GestureDetector(
                                        onTap: () =>
                                            _deleteScheduledTraining(training),
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Удалить',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ] else
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: UI.muted.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          'Прошло',
                                          style: TextStyle(
                                            color: UI.muted,
                                            fontSize: 12,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    // Иконка календаря
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: isPast
                                            ? UI.muted.withOpacity(0.2)
                                            : UI.primary.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.calendar_today,
                                        color: isPast ? UI.muted : UI.primary,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),

                                    // Информация о тренировке
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            training.title,
                                            style: TextStyle(
                                              color: isPast
                                                  ? UI.muted
                                                  : UI.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _formatDate(date),
                                            style: TextStyle(
                                              color: isPast
                                                  ? UI.muted.withOpacity(0.7)
                                                  : UI.muted,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${_formatTime(training.start_time)} - ${_formatTime(training.end_time)}',
                                            style: TextStyle(
                                              color: isPast
                                                  ? UI.muted.withOpacity(0.7)
                                                  : UI.muted,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Кнопки управления
                                    if (!isPast)
                                      isSmallScreen
                                          ? Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                GestureDetector(
                                                  onTap: () =>
                                                      _createTraining(training),
                                                  child: Container(
                                                    width: double.infinity,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 10,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      gradient:
                                                          UI.gradientPrimary,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Icon(
                                                          Icons.add,
                                                          color: Colors.white,
                                                          size: 16,
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          'Создать',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                GestureDetector(
                                                  onTap: () =>
                                                      _deleteScheduledTraining(
                                                        training,
                                                      ),
                                                  child: Container(
                                                    width: double.infinity,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 10,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Icon(
                                                          Icons.delete,
                                                          color: Colors.red,
                                                          size: 16,
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          'Удалить',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                GestureDetector(
                                                  onTap: () =>
                                                      _createTraining(training),
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 8,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      gradient:
                                                          UI.gradientPrimary,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        const Icon(
                                                          Icons.add,
                                                          color: Colors.white,
                                                          size: 16,
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          'Создать',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                GestureDetector(
                                                  onTap: () =>
                                                      _deleteScheduledTraining(
                                                        training,
                                                      ),
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: const Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                      size: 16,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                    else
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: UI.muted.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          'Прошло',
                                          style: TextStyle(
                                            color: UI.muted,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            // Кнопки внизу
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UI.muted.withOpacity(0.2),
                      foregroundColor: UI.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Закрыть'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _loadScheduledTrainings,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Обновить'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UI.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

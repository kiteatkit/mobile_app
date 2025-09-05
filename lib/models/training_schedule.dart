import 'package:freezed_annotation/freezed_annotation.dart';

part 'training_schedule.freezed.dart';
part 'training_schedule.g.dart';

@freezed
abstract class TrainingSchedule with _$TrainingSchedule {
  const factory TrainingSchedule({
    required String id,
    required String group_id,
    required String title,
    required List<int> weekdays, // 1-7 (понедельник-воскресенье)
    required String start_time, // HH:MM
    required String end_time, // HH:MM
    required String created_at,
    required String updated_at,
  }) = _TrainingSchedule;

  factory TrainingSchedule.fromJson(Map<String, dynamic> json) =>
      _$TrainingScheduleFromJson(json);
}

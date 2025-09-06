import 'package:freezed_annotation/freezed_annotation.dart';

part 'scheduled_training.freezed.dart';
part 'scheduled_training.g.dart';

@freezed
abstract class ScheduledTraining with _$ScheduledTraining {
  const factory ScheduledTraining({
    required String id,
    required String group_id,
    required String date,
    required String title,
    required String start_time,
    required String end_time,
    required String schedule_id,
    required String created_at,
  }) = _ScheduledTraining;

  factory ScheduledTraining.fromJson(Map<String, dynamic> json) =>
      _$ScheduledTrainingFromJson(json);
}

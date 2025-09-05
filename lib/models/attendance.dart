import 'package:freezed_annotation/freezed_annotation.dart';
import 'training_session.dart';

part 'attendance.freezed.dart';
part 'attendance.g.dart';

@freezed
abstract class Attendance with _$Attendance {
  const factory Attendance({
    required String id,
    required String player_id,
    required String session_id,
    @Default(false) bool attended,
    @Default(0) int points,
    required String created_at,
    TrainingSession? training_sessions,
  }) = _Attendance;

  factory Attendance.fromJson(Map<String, dynamic> json) =>
      _$AttendanceFromJson(json);
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Attendance _$AttendanceFromJson(Map<String, dynamic> json) => _Attendance(
  id: json['id'] as String,
  player_id: json['player_id'] as String,
  session_id: json['session_id'] as String,
  attended: json['attended'] as bool? ?? false,
  points: (json['points'] as num?)?.toInt() ?? 0,
  created_at: json['created_at'] as String,
  training_sessions: json['training_sessions'] == null
      ? null
      : TrainingSession.fromJson(
          json['training_sessions'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$AttendanceToJson(_Attendance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'player_id': instance.player_id,
      'session_id': instance.session_id,
      'attended': instance.attended,
      'points': instance.points,
      'created_at': instance.created_at,
      'training_sessions': instance.training_sessions,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scheduled_training.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ScheduledTraining _$ScheduledTrainingFromJson(Map<String, dynamic> json) =>
    _ScheduledTraining(
      id: json['id'] as String,
      group_id: json['group_id'] as String,
      date: json['date'] as String,
      title: json['title'] as String,
      start_time: json['start_time'] as String,
      end_time: json['end_time'] as String,
      schedule_id: json['schedule_id'] as String,
      created_at: json['created_at'] as String,
    );

Map<String, dynamic> _$ScheduledTrainingToJson(_ScheduledTraining instance) =>
    <String, dynamic>{
      'id': instance.id,
      'group_id': instance.group_id,
      'date': instance.date,
      'title': instance.title,
      'start_time': instance.start_time,
      'end_time': instance.end_time,
      'schedule_id': instance.schedule_id,
      'created_at': instance.created_at,
    };

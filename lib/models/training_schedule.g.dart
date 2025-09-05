// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrainingSchedule _$TrainingScheduleFromJson(Map<String, dynamic> json) =>
    _TrainingSchedule(
      id: json['id'] as String,
      group_id: json['group_id'] as String,
      title: json['title'] as String,
      weekdays: (json['weekdays'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      start_time: json['start_time'] as String,
      end_time: json['end_time'] as String,
      created_at: json['created_at'] as String,
      updated_at: json['updated_at'] as String,
    );

Map<String, dynamic> _$TrainingScheduleToJson(_TrainingSchedule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'group_id': instance.group_id,
      'title': instance.title,
      'weekdays': instance.weekdays,
      'start_time': instance.start_time,
      'end_time': instance.end_time,
      'created_at': instance.created_at,
      'updated_at': instance.updated_at,
    };

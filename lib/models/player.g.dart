// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Player _$PlayerFromJson(Map<String, dynamic> json) => _Player(
  id: json['id'] as String,
  name: json['name'] as String,
  birth_date: json['birth_date'] as String?,
  login: json['login'] as String,
  password: json['password'] as String?,
  total_points: (json['total_points'] as num?)?.toInt() ?? 0,
  attendance_count: (json['attendance_count'] as num?)?.toInt() ?? 0,
  avatar_url: json['avatar_url'] as String?,
  group_id: json['group_id'] as String?,
  group: json['group'] == null
      ? null
      : Group.fromJson(json['group'] as Map<String, dynamic>),
  created_at: json['created_at'] as String,
  updated_at: json['updated_at'] as String,
);

Map<String, dynamic> _$PlayerToJson(_Player instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'birth_date': instance.birth_date,
  'login': instance.login,
  'password': instance.password,
  'total_points': instance.total_points,
  'attendance_count': instance.attendance_count,
  'avatar_url': instance.avatar_url,
  'group_id': instance.group_id,
  'group': instance.group,
  'created_at': instance.created_at,
  'updated_at': instance.updated_at,
};

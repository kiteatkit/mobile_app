// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Coach _$CoachFromJson(Map<String, dynamic> json) => _Coach(
  id: json['id'] as String,
  name: json['name'] as String,
  login: json['login'] as String,
  password: json['password'] as String?,
  avatar_url: json['avatar_url'] as String?,
  created_at: json['created_at'] as String,
  updated_at: json['updated_at'] as String,
);

Map<String, dynamic> _$CoachToJson(_Coach instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'login': instance.login,
  'password': instance.password,
  'avatar_url': instance.avatar_url,
  'created_at': instance.created_at,
  'updated_at': instance.updated_at,
};

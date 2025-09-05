// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Group _$GroupFromJson(Map<String, dynamic> json) => _Group(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  color: json['color'] as String? ?? '#3B82F6',
  created_at: json['created_at'] as String,
  updated_at: json['updated_at'] as String,
);

Map<String, dynamic> _$GroupToJson(_Group instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'color': instance.color,
  'created_at': instance.created_at,
  'updated_at': instance.updated_at,
};

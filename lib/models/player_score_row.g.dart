// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_score_row.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlayerScoreRow _$PlayerScoreRowFromJson(Map<String, dynamic> json) =>
    _PlayerScoreRow(
      player: Player.fromJson(json['player'] as Map<String, dynamic>),
      trainingScores: Map<String, int>.from(json['trainingScores'] as Map),
      averageScore: (json['averageScore'] as num).toDouble(),
      isTopPlayer: json['isTopPlayer'] as bool,
    );

Map<String, dynamic> _$PlayerScoreRowToJson(_PlayerScoreRow instance) =>
    <String, dynamic>{
      'player': instance.player,
      'trainingScores': instance.trainingScores,
      'averageScore': instance.averageScore,
      'isTopPlayer': instance.isTopPlayer,
    };

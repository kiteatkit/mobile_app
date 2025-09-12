import 'package:freezed_annotation/freezed_annotation.dart';
import 'player.dart';

part 'player_score_row.freezed.dart';
part 'player_score_row.g.dart';

@freezed
abstract class PlayerScoreRow with _$PlayerScoreRow {
  const factory PlayerScoreRow({
    required Player player,
    required Map<String, int> trainingScores, // trainingId -> points
    required double averageScore,
    required bool isTopPlayer,
  }) = _PlayerScoreRow;

  factory PlayerScoreRow.fromJson(Map<String, dynamic> json) =>
      _$PlayerScoreRowFromJson(json);
}

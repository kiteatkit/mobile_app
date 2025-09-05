import 'package:freezed_annotation/freezed_annotation.dart';
import 'group.dart';

part 'player.freezed.dart';
part 'player.g.dart';

@freezed
abstract class Player with _$Player {
  const factory Player({
    required String id,
    required String name,
    String? birth_date,
    required String login,
    String? password,
    @Default(0) int total_points,
    @Default(0) int attendance_count,
    String? avatar_url,
    String? group_id,
    Group? group,
    required String created_at,
    required String updated_at,
  }) = _Player;

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
}

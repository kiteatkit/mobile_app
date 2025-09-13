import 'package:freezed_annotation/freezed_annotation.dart';

part 'coach.freezed.dart';
part 'coach.g.dart';

@freezed
abstract class Coach with _$Coach {
  const factory Coach({
    required String id,
    required String name,
    required String login,
    String? password,
    String? avatar_url,
    required String created_at,
    required String updated_at,
  }) = _Coach;

  factory Coach.fromJson(Map<String, dynamic> json) => _$CoachFromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'training_session.freezed.dart';
part 'training_session.g.dart';

@freezed
abstract class TrainingSession with _$TrainingSession {
  const factory TrainingSession({
    required String id,
    required String date,
    required String title,
    required String created_at,
  }) = _TrainingSession;

  factory TrainingSession.fromJson(Map<String, dynamic> json) =>
      _$TrainingSessionFromJson(json);
}

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Attendance {

 String get id; String get player_id; String get session_id; bool get attended; int get points; String get created_at; TrainingSession? get training_sessions;
/// Create a copy of Attendance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceCopyWith<Attendance> get copyWith => _$AttendanceCopyWithImpl<Attendance>(this as Attendance, _$identity);

  /// Serializes this Attendance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Attendance&&(identical(other.id, id) || other.id == id)&&(identical(other.player_id, player_id) || other.player_id == player_id)&&(identical(other.session_id, session_id) || other.session_id == session_id)&&(identical(other.attended, attended) || other.attended == attended)&&(identical(other.points, points) || other.points == points)&&(identical(other.created_at, created_at) || other.created_at == created_at)&&(identical(other.training_sessions, training_sessions) || other.training_sessions == training_sessions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,player_id,session_id,attended,points,created_at,training_sessions);

@override
String toString() {
  return 'Attendance(id: $id, player_id: $player_id, session_id: $session_id, attended: $attended, points: $points, created_at: $created_at, training_sessions: $training_sessions)';
}


}

/// @nodoc
abstract mixin class $AttendanceCopyWith<$Res>  {
  factory $AttendanceCopyWith(Attendance value, $Res Function(Attendance) _then) = _$AttendanceCopyWithImpl;
@useResult
$Res call({
 String id, String player_id, String session_id, bool attended, int points, String created_at, TrainingSession? training_sessions
});


$TrainingSessionCopyWith<$Res>? get training_sessions;

}
/// @nodoc
class _$AttendanceCopyWithImpl<$Res>
    implements $AttendanceCopyWith<$Res> {
  _$AttendanceCopyWithImpl(this._self, this._then);

  final Attendance _self;
  final $Res Function(Attendance) _then;

/// Create a copy of Attendance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? player_id = null,Object? session_id = null,Object? attended = null,Object? points = null,Object? created_at = null,Object? training_sessions = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,player_id: null == player_id ? _self.player_id : player_id // ignore: cast_nullable_to_non_nullable
as String,session_id: null == session_id ? _self.session_id : session_id // ignore: cast_nullable_to_non_nullable
as String,attended: null == attended ? _self.attended : attended // ignore: cast_nullable_to_non_nullable
as bool,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,created_at: null == created_at ? _self.created_at : created_at // ignore: cast_nullable_to_non_nullable
as String,training_sessions: freezed == training_sessions ? _self.training_sessions : training_sessions // ignore: cast_nullable_to_non_nullable
as TrainingSession?,
  ));
}
/// Create a copy of Attendance
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrainingSessionCopyWith<$Res>? get training_sessions {
    if (_self.training_sessions == null) {
    return null;
  }

  return $TrainingSessionCopyWith<$Res>(_self.training_sessions!, (value) {
    return _then(_self.copyWith(training_sessions: value));
  });
}
}


/// Adds pattern-matching-related methods to [Attendance].
extension AttendancePatterns on Attendance {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Attendance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Attendance() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Attendance value)  $default,){
final _that = this;
switch (_that) {
case _Attendance():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Attendance value)?  $default,){
final _that = this;
switch (_that) {
case _Attendance() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String player_id,  String session_id,  bool attended,  int points,  String created_at,  TrainingSession? training_sessions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Attendance() when $default != null:
return $default(_that.id,_that.player_id,_that.session_id,_that.attended,_that.points,_that.created_at,_that.training_sessions);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String player_id,  String session_id,  bool attended,  int points,  String created_at,  TrainingSession? training_sessions)  $default,) {final _that = this;
switch (_that) {
case _Attendance():
return $default(_that.id,_that.player_id,_that.session_id,_that.attended,_that.points,_that.created_at,_that.training_sessions);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String player_id,  String session_id,  bool attended,  int points,  String created_at,  TrainingSession? training_sessions)?  $default,) {final _that = this;
switch (_that) {
case _Attendance() when $default != null:
return $default(_that.id,_that.player_id,_that.session_id,_that.attended,_that.points,_that.created_at,_that.training_sessions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Attendance implements Attendance {
  const _Attendance({required this.id, required this.player_id, required this.session_id, this.attended = false, this.points = 0, required this.created_at, this.training_sessions});
  factory _Attendance.fromJson(Map<String, dynamic> json) => _$AttendanceFromJson(json);

@override final  String id;
@override final  String player_id;
@override final  String session_id;
@override@JsonKey() final  bool attended;
@override@JsonKey() final  int points;
@override final  String created_at;
@override final  TrainingSession? training_sessions;

/// Create a copy of Attendance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceCopyWith<_Attendance> get copyWith => __$AttendanceCopyWithImpl<_Attendance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttendanceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Attendance&&(identical(other.id, id) || other.id == id)&&(identical(other.player_id, player_id) || other.player_id == player_id)&&(identical(other.session_id, session_id) || other.session_id == session_id)&&(identical(other.attended, attended) || other.attended == attended)&&(identical(other.points, points) || other.points == points)&&(identical(other.created_at, created_at) || other.created_at == created_at)&&(identical(other.training_sessions, training_sessions) || other.training_sessions == training_sessions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,player_id,session_id,attended,points,created_at,training_sessions);

@override
String toString() {
  return 'Attendance(id: $id, player_id: $player_id, session_id: $session_id, attended: $attended, points: $points, created_at: $created_at, training_sessions: $training_sessions)';
}


}

/// @nodoc
abstract mixin class _$AttendanceCopyWith<$Res> implements $AttendanceCopyWith<$Res> {
  factory _$AttendanceCopyWith(_Attendance value, $Res Function(_Attendance) _then) = __$AttendanceCopyWithImpl;
@override @useResult
$Res call({
 String id, String player_id, String session_id, bool attended, int points, String created_at, TrainingSession? training_sessions
});


@override $TrainingSessionCopyWith<$Res>? get training_sessions;

}
/// @nodoc
class __$AttendanceCopyWithImpl<$Res>
    implements _$AttendanceCopyWith<$Res> {
  __$AttendanceCopyWithImpl(this._self, this._then);

  final _Attendance _self;
  final $Res Function(_Attendance) _then;

/// Create a copy of Attendance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? player_id = null,Object? session_id = null,Object? attended = null,Object? points = null,Object? created_at = null,Object? training_sessions = freezed,}) {
  return _then(_Attendance(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,player_id: null == player_id ? _self.player_id : player_id // ignore: cast_nullable_to_non_nullable
as String,session_id: null == session_id ? _self.session_id : session_id // ignore: cast_nullable_to_non_nullable
as String,attended: null == attended ? _self.attended : attended // ignore: cast_nullable_to_non_nullable
as bool,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,created_at: null == created_at ? _self.created_at : created_at // ignore: cast_nullable_to_non_nullable
as String,training_sessions: freezed == training_sessions ? _self.training_sessions : training_sessions // ignore: cast_nullable_to_non_nullable
as TrainingSession?,
  ));
}

/// Create a copy of Attendance
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrainingSessionCopyWith<$Res>? get training_sessions {
    if (_self.training_sessions == null) {
    return null;
  }

  return $TrainingSessionCopyWith<$Res>(_self.training_sessions!, (value) {
    return _then(_self.copyWith(training_sessions: value));
  });
}
}

// dart format on

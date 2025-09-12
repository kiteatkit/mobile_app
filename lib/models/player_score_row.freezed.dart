// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player_score_row.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlayerScoreRow {

 Player get player; Map<String, int> get trainingScores;// trainingId -> points
 double get averageScore; bool get isTopPlayer;
/// Create a copy of PlayerScoreRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerScoreRowCopyWith<PlayerScoreRow> get copyWith => _$PlayerScoreRowCopyWithImpl<PlayerScoreRow>(this as PlayerScoreRow, _$identity);

  /// Serializes this PlayerScoreRow to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerScoreRow&&(identical(other.player, player) || other.player == player)&&const DeepCollectionEquality().equals(other.trainingScores, trainingScores)&&(identical(other.averageScore, averageScore) || other.averageScore == averageScore)&&(identical(other.isTopPlayer, isTopPlayer) || other.isTopPlayer == isTopPlayer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,player,const DeepCollectionEquality().hash(trainingScores),averageScore,isTopPlayer);

@override
String toString() {
  return 'PlayerScoreRow(player: $player, trainingScores: $trainingScores, averageScore: $averageScore, isTopPlayer: $isTopPlayer)';
}


}

/// @nodoc
abstract mixin class $PlayerScoreRowCopyWith<$Res>  {
  factory $PlayerScoreRowCopyWith(PlayerScoreRow value, $Res Function(PlayerScoreRow) _then) = _$PlayerScoreRowCopyWithImpl;
@useResult
$Res call({
 Player player, Map<String, int> trainingScores, double averageScore, bool isTopPlayer
});


$PlayerCopyWith<$Res> get player;

}
/// @nodoc
class _$PlayerScoreRowCopyWithImpl<$Res>
    implements $PlayerScoreRowCopyWith<$Res> {
  _$PlayerScoreRowCopyWithImpl(this._self, this._then);

  final PlayerScoreRow _self;
  final $Res Function(PlayerScoreRow) _then;

/// Create a copy of PlayerScoreRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? player = null,Object? trainingScores = null,Object? averageScore = null,Object? isTopPlayer = null,}) {
  return _then(_self.copyWith(
player: null == player ? _self.player : player // ignore: cast_nullable_to_non_nullable
as Player,trainingScores: null == trainingScores ? _self.trainingScores : trainingScores // ignore: cast_nullable_to_non_nullable
as Map<String, int>,averageScore: null == averageScore ? _self.averageScore : averageScore // ignore: cast_nullable_to_non_nullable
as double,isTopPlayer: null == isTopPlayer ? _self.isTopPlayer : isTopPlayer // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of PlayerScoreRow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayerCopyWith<$Res> get player {
  
  return $PlayerCopyWith<$Res>(_self.player, (value) {
    return _then(_self.copyWith(player: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlayerScoreRow].
extension PlayerScoreRowPatterns on PlayerScoreRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayerScoreRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayerScoreRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayerScoreRow value)  $default,){
final _that = this;
switch (_that) {
case _PlayerScoreRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayerScoreRow value)?  $default,){
final _that = this;
switch (_that) {
case _PlayerScoreRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Player player,  Map<String, int> trainingScores,  double averageScore,  bool isTopPlayer)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayerScoreRow() when $default != null:
return $default(_that.player,_that.trainingScores,_that.averageScore,_that.isTopPlayer);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Player player,  Map<String, int> trainingScores,  double averageScore,  bool isTopPlayer)  $default,) {final _that = this;
switch (_that) {
case _PlayerScoreRow():
return $default(_that.player,_that.trainingScores,_that.averageScore,_that.isTopPlayer);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Player player,  Map<String, int> trainingScores,  double averageScore,  bool isTopPlayer)?  $default,) {final _that = this;
switch (_that) {
case _PlayerScoreRow() when $default != null:
return $default(_that.player,_that.trainingScores,_that.averageScore,_that.isTopPlayer);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlayerScoreRow implements PlayerScoreRow {
  const _PlayerScoreRow({required this.player, required final  Map<String, int> trainingScores, required this.averageScore, required this.isTopPlayer}): _trainingScores = trainingScores;
  factory _PlayerScoreRow.fromJson(Map<String, dynamic> json) => _$PlayerScoreRowFromJson(json);

@override final  Player player;
 final  Map<String, int> _trainingScores;
@override Map<String, int> get trainingScores {
  if (_trainingScores is EqualUnmodifiableMapView) return _trainingScores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_trainingScores);
}

// trainingId -> points
@override final  double averageScore;
@override final  bool isTopPlayer;

/// Create a copy of PlayerScoreRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerScoreRowCopyWith<_PlayerScoreRow> get copyWith => __$PlayerScoreRowCopyWithImpl<_PlayerScoreRow>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayerScoreRowToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayerScoreRow&&(identical(other.player, player) || other.player == player)&&const DeepCollectionEquality().equals(other._trainingScores, _trainingScores)&&(identical(other.averageScore, averageScore) || other.averageScore == averageScore)&&(identical(other.isTopPlayer, isTopPlayer) || other.isTopPlayer == isTopPlayer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,player,const DeepCollectionEquality().hash(_trainingScores),averageScore,isTopPlayer);

@override
String toString() {
  return 'PlayerScoreRow(player: $player, trainingScores: $trainingScores, averageScore: $averageScore, isTopPlayer: $isTopPlayer)';
}


}

/// @nodoc
abstract mixin class _$PlayerScoreRowCopyWith<$Res> implements $PlayerScoreRowCopyWith<$Res> {
  factory _$PlayerScoreRowCopyWith(_PlayerScoreRow value, $Res Function(_PlayerScoreRow) _then) = __$PlayerScoreRowCopyWithImpl;
@override @useResult
$Res call({
 Player player, Map<String, int> trainingScores, double averageScore, bool isTopPlayer
});


@override $PlayerCopyWith<$Res> get player;

}
/// @nodoc
class __$PlayerScoreRowCopyWithImpl<$Res>
    implements _$PlayerScoreRowCopyWith<$Res> {
  __$PlayerScoreRowCopyWithImpl(this._self, this._then);

  final _PlayerScoreRow _self;
  final $Res Function(_PlayerScoreRow) _then;

/// Create a copy of PlayerScoreRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? player = null,Object? trainingScores = null,Object? averageScore = null,Object? isTopPlayer = null,}) {
  return _then(_PlayerScoreRow(
player: null == player ? _self.player : player // ignore: cast_nullable_to_non_nullable
as Player,trainingScores: null == trainingScores ? _self._trainingScores : trainingScores // ignore: cast_nullable_to_non_nullable
as Map<String, int>,averageScore: null == averageScore ? _self.averageScore : averageScore // ignore: cast_nullable_to_non_nullable
as double,isTopPlayer: null == isTopPlayer ? _self.isTopPlayer : isTopPlayer // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of PlayerScoreRow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayerCopyWith<$Res> get player {
  
  return $PlayerCopyWith<$Res>(_self.player, (value) {
    return _then(_self.copyWith(player: value));
  });
}
}

// dart format on

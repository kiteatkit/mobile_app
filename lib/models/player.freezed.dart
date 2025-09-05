// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Player {

 String get id; String get name; String? get birth_date; String get login; String? get password; int get total_points; int get attendance_count; String? get avatar_url; String? get group_id; Group? get group; String get created_at; String get updated_at;
/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerCopyWith<Player> get copyWith => _$PlayerCopyWithImpl<Player>(this as Player, _$identity);

  /// Serializes this Player to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Player&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.birth_date, birth_date) || other.birth_date == birth_date)&&(identical(other.login, login) || other.login == login)&&(identical(other.password, password) || other.password == password)&&(identical(other.total_points, total_points) || other.total_points == total_points)&&(identical(other.attendance_count, attendance_count) || other.attendance_count == attendance_count)&&(identical(other.avatar_url, avatar_url) || other.avatar_url == avatar_url)&&(identical(other.group_id, group_id) || other.group_id == group_id)&&(identical(other.group, group) || other.group == group)&&(identical(other.created_at, created_at) || other.created_at == created_at)&&(identical(other.updated_at, updated_at) || other.updated_at == updated_at));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,birth_date,login,password,total_points,attendance_count,avatar_url,group_id,group,created_at,updated_at);

@override
String toString() {
  return 'Player(id: $id, name: $name, birth_date: $birth_date, login: $login, password: $password, total_points: $total_points, attendance_count: $attendance_count, avatar_url: $avatar_url, group_id: $group_id, group: $group, created_at: $created_at, updated_at: $updated_at)';
}


}

/// @nodoc
abstract mixin class $PlayerCopyWith<$Res>  {
  factory $PlayerCopyWith(Player value, $Res Function(Player) _then) = _$PlayerCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? birth_date, String login, String? password, int total_points, int attendance_count, String? avatar_url, String? group_id, Group? group, String created_at, String updated_at
});


$GroupCopyWith<$Res>? get group;

}
/// @nodoc
class _$PlayerCopyWithImpl<$Res>
    implements $PlayerCopyWith<$Res> {
  _$PlayerCopyWithImpl(this._self, this._then);

  final Player _self;
  final $Res Function(Player) _then;

/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? birth_date = freezed,Object? login = null,Object? password = freezed,Object? total_points = null,Object? attendance_count = null,Object? avatar_url = freezed,Object? group_id = freezed,Object? group = freezed,Object? created_at = null,Object? updated_at = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,birth_date: freezed == birth_date ? _self.birth_date : birth_date // ignore: cast_nullable_to_non_nullable
as String?,login: null == login ? _self.login : login // ignore: cast_nullable_to_non_nullable
as String,password: freezed == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String?,total_points: null == total_points ? _self.total_points : total_points // ignore: cast_nullable_to_non_nullable
as int,attendance_count: null == attendance_count ? _self.attendance_count : attendance_count // ignore: cast_nullable_to_non_nullable
as int,avatar_url: freezed == avatar_url ? _self.avatar_url : avatar_url // ignore: cast_nullable_to_non_nullable
as String?,group_id: freezed == group_id ? _self.group_id : group_id // ignore: cast_nullable_to_non_nullable
as String?,group: freezed == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as Group?,created_at: null == created_at ? _self.created_at : created_at // ignore: cast_nullable_to_non_nullable
as String,updated_at: null == updated_at ? _self.updated_at : updated_at // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GroupCopyWith<$Res>? get group {
    if (_self.group == null) {
    return null;
  }

  return $GroupCopyWith<$Res>(_self.group!, (value) {
    return _then(_self.copyWith(group: value));
  });
}
}


/// Adds pattern-matching-related methods to [Player].
extension PlayerPatterns on Player {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Player value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Player() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Player value)  $default,){
final _that = this;
switch (_that) {
case _Player():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Player value)?  $default,){
final _that = this;
switch (_that) {
case _Player() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? birth_date,  String login,  String? password,  int total_points,  int attendance_count,  String? avatar_url,  String? group_id,  Group? group,  String created_at,  String updated_at)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Player() when $default != null:
return $default(_that.id,_that.name,_that.birth_date,_that.login,_that.password,_that.total_points,_that.attendance_count,_that.avatar_url,_that.group_id,_that.group,_that.created_at,_that.updated_at);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? birth_date,  String login,  String? password,  int total_points,  int attendance_count,  String? avatar_url,  String? group_id,  Group? group,  String created_at,  String updated_at)  $default,) {final _that = this;
switch (_that) {
case _Player():
return $default(_that.id,_that.name,_that.birth_date,_that.login,_that.password,_that.total_points,_that.attendance_count,_that.avatar_url,_that.group_id,_that.group,_that.created_at,_that.updated_at);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? birth_date,  String login,  String? password,  int total_points,  int attendance_count,  String? avatar_url,  String? group_id,  Group? group,  String created_at,  String updated_at)?  $default,) {final _that = this;
switch (_that) {
case _Player() when $default != null:
return $default(_that.id,_that.name,_that.birth_date,_that.login,_that.password,_that.total_points,_that.attendance_count,_that.avatar_url,_that.group_id,_that.group,_that.created_at,_that.updated_at);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Player implements Player {
  const _Player({required this.id, required this.name, this.birth_date, required this.login, this.password, this.total_points = 0, this.attendance_count = 0, this.avatar_url, this.group_id, this.group, required this.created_at, required this.updated_at});
  factory _Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? birth_date;
@override final  String login;
@override final  String? password;
@override@JsonKey() final  int total_points;
@override@JsonKey() final  int attendance_count;
@override final  String? avatar_url;
@override final  String? group_id;
@override final  Group? group;
@override final  String created_at;
@override final  String updated_at;

/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerCopyWith<_Player> get copyWith => __$PlayerCopyWithImpl<_Player>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Player&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.birth_date, birth_date) || other.birth_date == birth_date)&&(identical(other.login, login) || other.login == login)&&(identical(other.password, password) || other.password == password)&&(identical(other.total_points, total_points) || other.total_points == total_points)&&(identical(other.attendance_count, attendance_count) || other.attendance_count == attendance_count)&&(identical(other.avatar_url, avatar_url) || other.avatar_url == avatar_url)&&(identical(other.group_id, group_id) || other.group_id == group_id)&&(identical(other.group, group) || other.group == group)&&(identical(other.created_at, created_at) || other.created_at == created_at)&&(identical(other.updated_at, updated_at) || other.updated_at == updated_at));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,birth_date,login,password,total_points,attendance_count,avatar_url,group_id,group,created_at,updated_at);

@override
String toString() {
  return 'Player(id: $id, name: $name, birth_date: $birth_date, login: $login, password: $password, total_points: $total_points, attendance_count: $attendance_count, avatar_url: $avatar_url, group_id: $group_id, group: $group, created_at: $created_at, updated_at: $updated_at)';
}


}

/// @nodoc
abstract mixin class _$PlayerCopyWith<$Res> implements $PlayerCopyWith<$Res> {
  factory _$PlayerCopyWith(_Player value, $Res Function(_Player) _then) = __$PlayerCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? birth_date, String login, String? password, int total_points, int attendance_count, String? avatar_url, String? group_id, Group? group, String created_at, String updated_at
});


@override $GroupCopyWith<$Res>? get group;

}
/// @nodoc
class __$PlayerCopyWithImpl<$Res>
    implements _$PlayerCopyWith<$Res> {
  __$PlayerCopyWithImpl(this._self, this._then);

  final _Player _self;
  final $Res Function(_Player) _then;

/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? birth_date = freezed,Object? login = null,Object? password = freezed,Object? total_points = null,Object? attendance_count = null,Object? avatar_url = freezed,Object? group_id = freezed,Object? group = freezed,Object? created_at = null,Object? updated_at = null,}) {
  return _then(_Player(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,birth_date: freezed == birth_date ? _self.birth_date : birth_date // ignore: cast_nullable_to_non_nullable
as String?,login: null == login ? _self.login : login // ignore: cast_nullable_to_non_nullable
as String,password: freezed == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String?,total_points: null == total_points ? _self.total_points : total_points // ignore: cast_nullable_to_non_nullable
as int,attendance_count: null == attendance_count ? _self.attendance_count : attendance_count // ignore: cast_nullable_to_non_nullable
as int,avatar_url: freezed == avatar_url ? _self.avatar_url : avatar_url // ignore: cast_nullable_to_non_nullable
as String?,group_id: freezed == group_id ? _self.group_id : group_id // ignore: cast_nullable_to_non_nullable
as String?,group: freezed == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as Group?,created_at: null == created_at ? _self.created_at : created_at // ignore: cast_nullable_to_non_nullable
as String,updated_at: null == updated_at ? _self.updated_at : updated_at // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GroupCopyWith<$Res>? get group {
    if (_self.group == null) {
    return null;
  }

  return $GroupCopyWith<$Res>(_self.group!, (value) {
    return _then(_self.copyWith(group: value));
  });
}
}

// dart format on

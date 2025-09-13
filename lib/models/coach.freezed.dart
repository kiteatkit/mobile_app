// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'coach.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Coach {

 String get id; String get name; String get login; String? get password; String? get avatar_url; String get created_at; String get updated_at;
/// Create a copy of Coach
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoachCopyWith<Coach> get copyWith => _$CoachCopyWithImpl<Coach>(this as Coach, _$identity);

  /// Serializes this Coach to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Coach&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.login, login) || other.login == login)&&(identical(other.password, password) || other.password == password)&&(identical(other.avatar_url, avatar_url) || other.avatar_url == avatar_url)&&(identical(other.created_at, created_at) || other.created_at == created_at)&&(identical(other.updated_at, updated_at) || other.updated_at == updated_at));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,login,password,avatar_url,created_at,updated_at);

@override
String toString() {
  return 'Coach(id: $id, name: $name, login: $login, password: $password, avatar_url: $avatar_url, created_at: $created_at, updated_at: $updated_at)';
}


}

/// @nodoc
abstract mixin class $CoachCopyWith<$Res>  {
  factory $CoachCopyWith(Coach value, $Res Function(Coach) _then) = _$CoachCopyWithImpl;
@useResult
$Res call({
 String id, String name, String login, String? password, String? avatar_url, String created_at, String updated_at
});




}
/// @nodoc
class _$CoachCopyWithImpl<$Res>
    implements $CoachCopyWith<$Res> {
  _$CoachCopyWithImpl(this._self, this._then);

  final Coach _self;
  final $Res Function(Coach) _then;

/// Create a copy of Coach
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? login = null,Object? password = freezed,Object? avatar_url = freezed,Object? created_at = null,Object? updated_at = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,login: null == login ? _self.login : login // ignore: cast_nullable_to_non_nullable
as String,password: freezed == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String?,avatar_url: freezed == avatar_url ? _self.avatar_url : avatar_url // ignore: cast_nullable_to_non_nullable
as String?,created_at: null == created_at ? _self.created_at : created_at // ignore: cast_nullable_to_non_nullable
as String,updated_at: null == updated_at ? _self.updated_at : updated_at // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Coach].
extension CoachPatterns on Coach {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Coach value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Coach() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Coach value)  $default,){
final _that = this;
switch (_that) {
case _Coach():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Coach value)?  $default,){
final _that = this;
switch (_that) {
case _Coach() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String login,  String? password,  String? avatar_url,  String created_at,  String updated_at)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Coach() when $default != null:
return $default(_that.id,_that.name,_that.login,_that.password,_that.avatar_url,_that.created_at,_that.updated_at);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String login,  String? password,  String? avatar_url,  String created_at,  String updated_at)  $default,) {final _that = this;
switch (_that) {
case _Coach():
return $default(_that.id,_that.name,_that.login,_that.password,_that.avatar_url,_that.created_at,_that.updated_at);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String login,  String? password,  String? avatar_url,  String created_at,  String updated_at)?  $default,) {final _that = this;
switch (_that) {
case _Coach() when $default != null:
return $default(_that.id,_that.name,_that.login,_that.password,_that.avatar_url,_that.created_at,_that.updated_at);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Coach implements Coach {
  const _Coach({required this.id, required this.name, required this.login, this.password, this.avatar_url, required this.created_at, required this.updated_at});
  factory _Coach.fromJson(Map<String, dynamic> json) => _$CoachFromJson(json);

@override final  String id;
@override final  String name;
@override final  String login;
@override final  String? password;
@override final  String? avatar_url;
@override final  String created_at;
@override final  String updated_at;

/// Create a copy of Coach
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoachCopyWith<_Coach> get copyWith => __$CoachCopyWithImpl<_Coach>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CoachToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Coach&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.login, login) || other.login == login)&&(identical(other.password, password) || other.password == password)&&(identical(other.avatar_url, avatar_url) || other.avatar_url == avatar_url)&&(identical(other.created_at, created_at) || other.created_at == created_at)&&(identical(other.updated_at, updated_at) || other.updated_at == updated_at));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,login,password,avatar_url,created_at,updated_at);

@override
String toString() {
  return 'Coach(id: $id, name: $name, login: $login, password: $password, avatar_url: $avatar_url, created_at: $created_at, updated_at: $updated_at)';
}


}

/// @nodoc
abstract mixin class _$CoachCopyWith<$Res> implements $CoachCopyWith<$Res> {
  factory _$CoachCopyWith(_Coach value, $Res Function(_Coach) _then) = __$CoachCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String login, String? password, String? avatar_url, String created_at, String updated_at
});




}
/// @nodoc
class __$CoachCopyWithImpl<$Res>
    implements _$CoachCopyWith<$Res> {
  __$CoachCopyWithImpl(this._self, this._then);

  final _Coach _self;
  final $Res Function(_Coach) _then;

/// Create a copy of Coach
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? login = null,Object? password = freezed,Object? avatar_url = freezed,Object? created_at = null,Object? updated_at = null,}) {
  return _then(_Coach(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,login: null == login ? _self.login : login // ignore: cast_nullable_to_non_nullable
as String,password: freezed == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String?,avatar_url: freezed == avatar_url ? _self.avatar_url : avatar_url // ignore: cast_nullable_to_non_nullable
as String?,created_at: null == created_at ? _self.created_at : created_at // ignore: cast_nullable_to_non_nullable
as String,updated_at: null == updated_at ? _self.updated_at : updated_at // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'training_schedule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrainingSchedule {

 String get id; String get group_id; String get title; List<int> get weekdays;// 1-7 (понедельник-воскресенье)
 String get start_time;// HH:MM
 String get end_time;// HH:MM
 String get created_at; String get updated_at;
/// Create a copy of TrainingSchedule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrainingScheduleCopyWith<TrainingSchedule> get copyWith => _$TrainingScheduleCopyWithImpl<TrainingSchedule>(this as TrainingSchedule, _$identity);

  /// Serializes this TrainingSchedule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrainingSchedule&&(identical(other.id, id) || other.id == id)&&(identical(other.group_id, group_id) || other.group_id == group_id)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.weekdays, weekdays)&&(identical(other.start_time, start_time) || other.start_time == start_time)&&(identical(other.end_time, end_time) || other.end_time == end_time)&&(identical(other.created_at, created_at) || other.created_at == created_at)&&(identical(other.updated_at, updated_at) || other.updated_at == updated_at));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,group_id,title,const DeepCollectionEquality().hash(weekdays),start_time,end_time,created_at,updated_at);

@override
String toString() {
  return 'TrainingSchedule(id: $id, group_id: $group_id, title: $title, weekdays: $weekdays, start_time: $start_time, end_time: $end_time, created_at: $created_at, updated_at: $updated_at)';
}


}

/// @nodoc
abstract mixin class $TrainingScheduleCopyWith<$Res>  {
  factory $TrainingScheduleCopyWith(TrainingSchedule value, $Res Function(TrainingSchedule) _then) = _$TrainingScheduleCopyWithImpl;
@useResult
$Res call({
 String id, String group_id, String title, List<int> weekdays, String start_time, String end_time, String created_at, String updated_at
});




}
/// @nodoc
class _$TrainingScheduleCopyWithImpl<$Res>
    implements $TrainingScheduleCopyWith<$Res> {
  _$TrainingScheduleCopyWithImpl(this._self, this._then);

  final TrainingSchedule _self;
  final $Res Function(TrainingSchedule) _then;

/// Create a copy of TrainingSchedule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? group_id = null,Object? title = null,Object? weekdays = null,Object? start_time = null,Object? end_time = null,Object? created_at = null,Object? updated_at = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,group_id: null == group_id ? _self.group_id : group_id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,weekdays: null == weekdays ? _self.weekdays : weekdays // ignore: cast_nullable_to_non_nullable
as List<int>,start_time: null == start_time ? _self.start_time : start_time // ignore: cast_nullable_to_non_nullable
as String,end_time: null == end_time ? _self.end_time : end_time // ignore: cast_nullable_to_non_nullable
as String,created_at: null == created_at ? _self.created_at : created_at // ignore: cast_nullable_to_non_nullable
as String,updated_at: null == updated_at ? _self.updated_at : updated_at // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TrainingSchedule].
extension TrainingSchedulePatterns on TrainingSchedule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrainingSchedule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrainingSchedule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrainingSchedule value)  $default,){
final _that = this;
switch (_that) {
case _TrainingSchedule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrainingSchedule value)?  $default,){
final _that = this;
switch (_that) {
case _TrainingSchedule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String group_id,  String title,  List<int> weekdays,  String start_time,  String end_time,  String created_at,  String updated_at)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrainingSchedule() when $default != null:
return $default(_that.id,_that.group_id,_that.title,_that.weekdays,_that.start_time,_that.end_time,_that.created_at,_that.updated_at);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String group_id,  String title,  List<int> weekdays,  String start_time,  String end_time,  String created_at,  String updated_at)  $default,) {final _that = this;
switch (_that) {
case _TrainingSchedule():
return $default(_that.id,_that.group_id,_that.title,_that.weekdays,_that.start_time,_that.end_time,_that.created_at,_that.updated_at);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String group_id,  String title,  List<int> weekdays,  String start_time,  String end_time,  String created_at,  String updated_at)?  $default,) {final _that = this;
switch (_that) {
case _TrainingSchedule() when $default != null:
return $default(_that.id,_that.group_id,_that.title,_that.weekdays,_that.start_time,_that.end_time,_that.created_at,_that.updated_at);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrainingSchedule implements TrainingSchedule {
  const _TrainingSchedule({required this.id, required this.group_id, required this.title, required final  List<int> weekdays, required this.start_time, required this.end_time, required this.created_at, required this.updated_at}): _weekdays = weekdays;
  factory _TrainingSchedule.fromJson(Map<String, dynamic> json) => _$TrainingScheduleFromJson(json);

@override final  String id;
@override final  String group_id;
@override final  String title;
 final  List<int> _weekdays;
@override List<int> get weekdays {
  if (_weekdays is EqualUnmodifiableListView) return _weekdays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_weekdays);
}

// 1-7 (понедельник-воскресенье)
@override final  String start_time;
// HH:MM
@override final  String end_time;
// HH:MM
@override final  String created_at;
@override final  String updated_at;

/// Create a copy of TrainingSchedule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrainingScheduleCopyWith<_TrainingSchedule> get copyWith => __$TrainingScheduleCopyWithImpl<_TrainingSchedule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrainingScheduleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrainingSchedule&&(identical(other.id, id) || other.id == id)&&(identical(other.group_id, group_id) || other.group_id == group_id)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._weekdays, _weekdays)&&(identical(other.start_time, start_time) || other.start_time == start_time)&&(identical(other.end_time, end_time) || other.end_time == end_time)&&(identical(other.created_at, created_at) || other.created_at == created_at)&&(identical(other.updated_at, updated_at) || other.updated_at == updated_at));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,group_id,title,const DeepCollectionEquality().hash(_weekdays),start_time,end_time,created_at,updated_at);

@override
String toString() {
  return 'TrainingSchedule(id: $id, group_id: $group_id, title: $title, weekdays: $weekdays, start_time: $start_time, end_time: $end_time, created_at: $created_at, updated_at: $updated_at)';
}


}

/// @nodoc
abstract mixin class _$TrainingScheduleCopyWith<$Res> implements $TrainingScheduleCopyWith<$Res> {
  factory _$TrainingScheduleCopyWith(_TrainingSchedule value, $Res Function(_TrainingSchedule) _then) = __$TrainingScheduleCopyWithImpl;
@override @useResult
$Res call({
 String id, String group_id, String title, List<int> weekdays, String start_time, String end_time, String created_at, String updated_at
});




}
/// @nodoc
class __$TrainingScheduleCopyWithImpl<$Res>
    implements _$TrainingScheduleCopyWith<$Res> {
  __$TrainingScheduleCopyWithImpl(this._self, this._then);

  final _TrainingSchedule _self;
  final $Res Function(_TrainingSchedule) _then;

/// Create a copy of TrainingSchedule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? group_id = null,Object? title = null,Object? weekdays = null,Object? start_time = null,Object? end_time = null,Object? created_at = null,Object? updated_at = null,}) {
  return _then(_TrainingSchedule(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,group_id: null == group_id ? _self.group_id : group_id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,weekdays: null == weekdays ? _self._weekdays : weekdays // ignore: cast_nullable_to_non_nullable
as List<int>,start_time: null == start_time ? _self.start_time : start_time // ignore: cast_nullable_to_non_nullable
as String,end_time: null == end_time ? _self.end_time : end_time // ignore: cast_nullable_to_non_nullable
as String,created_at: null == created_at ? _self.created_at : created_at // ignore: cast_nullable_to_non_nullable
as String,updated_at: null == updated_at ? _self.updated_at : updated_at // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

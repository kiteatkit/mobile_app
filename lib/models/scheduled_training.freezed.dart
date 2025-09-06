// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scheduled_training.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ScheduledTraining {

 String get id; String get group_id; String get date; String get title; String get start_time; String get end_time; String get schedule_id; String get created_at;
/// Create a copy of ScheduledTraining
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduledTrainingCopyWith<ScheduledTraining> get copyWith => _$ScheduledTrainingCopyWithImpl<ScheduledTraining>(this as ScheduledTraining, _$identity);

  /// Serializes this ScheduledTraining to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduledTraining&&(identical(other.id, id) || other.id == id)&&(identical(other.group_id, group_id) || other.group_id == group_id)&&(identical(other.date, date) || other.date == date)&&(identical(other.title, title) || other.title == title)&&(identical(other.start_time, start_time) || other.start_time == start_time)&&(identical(other.end_time, end_time) || other.end_time == end_time)&&(identical(other.schedule_id, schedule_id) || other.schedule_id == schedule_id)&&(identical(other.created_at, created_at) || other.created_at == created_at));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,group_id,date,title,start_time,end_time,schedule_id,created_at);

@override
String toString() {
  return 'ScheduledTraining(id: $id, group_id: $group_id, date: $date, title: $title, start_time: $start_time, end_time: $end_time, schedule_id: $schedule_id, created_at: $created_at)';
}


}

/// @nodoc
abstract mixin class $ScheduledTrainingCopyWith<$Res>  {
  factory $ScheduledTrainingCopyWith(ScheduledTraining value, $Res Function(ScheduledTraining) _then) = _$ScheduledTrainingCopyWithImpl;
@useResult
$Res call({
 String id, String group_id, String date, String title, String start_time, String end_time, String schedule_id, String created_at
});




}
/// @nodoc
class _$ScheduledTrainingCopyWithImpl<$Res>
    implements $ScheduledTrainingCopyWith<$Res> {
  _$ScheduledTrainingCopyWithImpl(this._self, this._then);

  final ScheduledTraining _self;
  final $Res Function(ScheduledTraining) _then;

/// Create a copy of ScheduledTraining
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? group_id = null,Object? date = null,Object? title = null,Object? start_time = null,Object? end_time = null,Object? schedule_id = null,Object? created_at = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,group_id: null == group_id ? _self.group_id : group_id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,start_time: null == start_time ? _self.start_time : start_time // ignore: cast_nullable_to_non_nullable
as String,end_time: null == end_time ? _self.end_time : end_time // ignore: cast_nullable_to_non_nullable
as String,schedule_id: null == schedule_id ? _self.schedule_id : schedule_id // ignore: cast_nullable_to_non_nullable
as String,created_at: null == created_at ? _self.created_at : created_at // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ScheduledTraining].
extension ScheduledTrainingPatterns on ScheduledTraining {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScheduledTraining value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScheduledTraining() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScheduledTraining value)  $default,){
final _that = this;
switch (_that) {
case _ScheduledTraining():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScheduledTraining value)?  $default,){
final _that = this;
switch (_that) {
case _ScheduledTraining() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String group_id,  String date,  String title,  String start_time,  String end_time,  String schedule_id,  String created_at)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScheduledTraining() when $default != null:
return $default(_that.id,_that.group_id,_that.date,_that.title,_that.start_time,_that.end_time,_that.schedule_id,_that.created_at);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String group_id,  String date,  String title,  String start_time,  String end_time,  String schedule_id,  String created_at)  $default,) {final _that = this;
switch (_that) {
case _ScheduledTraining():
return $default(_that.id,_that.group_id,_that.date,_that.title,_that.start_time,_that.end_time,_that.schedule_id,_that.created_at);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String group_id,  String date,  String title,  String start_time,  String end_time,  String schedule_id,  String created_at)?  $default,) {final _that = this;
switch (_that) {
case _ScheduledTraining() when $default != null:
return $default(_that.id,_that.group_id,_that.date,_that.title,_that.start_time,_that.end_time,_that.schedule_id,_that.created_at);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScheduledTraining implements ScheduledTraining {
  const _ScheduledTraining({required this.id, required this.group_id, required this.date, required this.title, required this.start_time, required this.end_time, required this.schedule_id, required this.created_at});
  factory _ScheduledTraining.fromJson(Map<String, dynamic> json) => _$ScheduledTrainingFromJson(json);

@override final  String id;
@override final  String group_id;
@override final  String date;
@override final  String title;
@override final  String start_time;
@override final  String end_time;
@override final  String schedule_id;
@override final  String created_at;

/// Create a copy of ScheduledTraining
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScheduledTrainingCopyWith<_ScheduledTraining> get copyWith => __$ScheduledTrainingCopyWithImpl<_ScheduledTraining>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScheduledTrainingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScheduledTraining&&(identical(other.id, id) || other.id == id)&&(identical(other.group_id, group_id) || other.group_id == group_id)&&(identical(other.date, date) || other.date == date)&&(identical(other.title, title) || other.title == title)&&(identical(other.start_time, start_time) || other.start_time == start_time)&&(identical(other.end_time, end_time) || other.end_time == end_time)&&(identical(other.schedule_id, schedule_id) || other.schedule_id == schedule_id)&&(identical(other.created_at, created_at) || other.created_at == created_at));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,group_id,date,title,start_time,end_time,schedule_id,created_at);

@override
String toString() {
  return 'ScheduledTraining(id: $id, group_id: $group_id, date: $date, title: $title, start_time: $start_time, end_time: $end_time, schedule_id: $schedule_id, created_at: $created_at)';
}


}

/// @nodoc
abstract mixin class _$ScheduledTrainingCopyWith<$Res> implements $ScheduledTrainingCopyWith<$Res> {
  factory _$ScheduledTrainingCopyWith(_ScheduledTraining value, $Res Function(_ScheduledTraining) _then) = __$ScheduledTrainingCopyWithImpl;
@override @useResult
$Res call({
 String id, String group_id, String date, String title, String start_time, String end_time, String schedule_id, String created_at
});




}
/// @nodoc
class __$ScheduledTrainingCopyWithImpl<$Res>
    implements _$ScheduledTrainingCopyWith<$Res> {
  __$ScheduledTrainingCopyWithImpl(this._self, this._then);

  final _ScheduledTraining _self;
  final $Res Function(_ScheduledTraining) _then;

/// Create a copy of ScheduledTraining
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? group_id = null,Object? date = null,Object? title = null,Object? start_time = null,Object? end_time = null,Object? schedule_id = null,Object? created_at = null,}) {
  return _then(_ScheduledTraining(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,group_id: null == group_id ? _self.group_id : group_id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,start_time: null == start_time ? _self.start_time : start_time // ignore: cast_nullable_to_non_nullable
as String,end_time: null == end_time ? _self.end_time : end_time // ignore: cast_nullable_to_non_nullable
as String,schedule_id: null == schedule_id ? _self.schedule_id : schedule_id // ignore: cast_nullable_to_non_nullable
as String,created_at: null == created_at ? _self.created_at : created_at // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

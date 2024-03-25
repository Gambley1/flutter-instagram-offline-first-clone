// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_options_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PostOptionsSettings {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            ValueSetter<String> onPostDelete, ValueSetter<PostBlock> onPostEdit)
        owner,
    required TResult Function() viewer,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ValueSetter<String> onPostDelete,
            ValueSetter<PostBlock> onPostEdit)?
        owner,
    TResult? Function()? viewer,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ValueSetter<String> onPostDelete,
            ValueSetter<PostBlock> onPostEdit)?
        owner,
    TResult Function()? viewer,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Owner value) owner,
    required TResult Function(Viewer value) viewer,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Owner value)? owner,
    TResult? Function(Viewer value)? viewer,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Owner value)? owner,
    TResult Function(Viewer value)? viewer,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PostOptionsSettingsCopyWith<$Res> {
  factory $PostOptionsSettingsCopyWith(
          PostOptionsSettings value, $Res Function(PostOptionsSettings) then) =
      _$PostOptionsSettingsCopyWithImpl<$Res, PostOptionsSettings>;
}

/// @nodoc
class _$PostOptionsSettingsCopyWithImpl<$Res, $Val extends PostOptionsSettings>
    implements $PostOptionsSettingsCopyWith<$Res> {
  _$PostOptionsSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$OwnerImplCopyWith<$Res> {
  factory _$$OwnerImplCopyWith(
          _$OwnerImpl value, $Res Function(_$OwnerImpl) then) =
      __$$OwnerImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {ValueSetter<String> onPostDelete, ValueSetter<PostBlock> onPostEdit});
}

/// @nodoc
class __$$OwnerImplCopyWithImpl<$Res>
    extends _$PostOptionsSettingsCopyWithImpl<$Res, _$OwnerImpl>
    implements _$$OwnerImplCopyWith<$Res> {
  __$$OwnerImplCopyWithImpl(
      _$OwnerImpl _value, $Res Function(_$OwnerImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? onPostDelete = null,
    Object? onPostEdit = null,
  }) {
    return _then(_$OwnerImpl(
      onPostDelete: null == onPostDelete
          ? _value.onPostDelete
          : onPostDelete // ignore: cast_nullable_to_non_nullable
              as ValueSetter<String>,
      onPostEdit: null == onPostEdit
          ? _value.onPostEdit
          : onPostEdit // ignore: cast_nullable_to_non_nullable
              as ValueSetter<PostBlock>,
    ));
  }
}

/// @nodoc

class _$OwnerImpl extends Owner {
  const _$OwnerImpl({required this.onPostDelete, required this.onPostEdit})
      : super._();

  @override
  final ValueSetter<String> onPostDelete;
  @override
  final ValueSetter<PostBlock> onPostEdit;

  @override
  String toString() {
    return 'PostOptionsSettings.owner(onPostDelete: $onPostDelete, onPostEdit: $onPostEdit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OwnerImpl &&
            (identical(other.onPostDelete, onPostDelete) ||
                other.onPostDelete == onPostDelete) &&
            (identical(other.onPostEdit, onPostEdit) ||
                other.onPostEdit == onPostEdit));
  }

  @override
  int get hashCode => Object.hash(runtimeType, onPostDelete, onPostEdit);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OwnerImplCopyWith<_$OwnerImpl> get copyWith =>
      __$$OwnerImplCopyWithImpl<_$OwnerImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            ValueSetter<String> onPostDelete, ValueSetter<PostBlock> onPostEdit)
        owner,
    required TResult Function() viewer,
  }) {
    return owner(onPostDelete, onPostEdit);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ValueSetter<String> onPostDelete,
            ValueSetter<PostBlock> onPostEdit)?
        owner,
    TResult? Function()? viewer,
  }) {
    return owner?.call(onPostDelete, onPostEdit);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ValueSetter<String> onPostDelete,
            ValueSetter<PostBlock> onPostEdit)?
        owner,
    TResult Function()? viewer,
    required TResult orElse(),
  }) {
    if (owner != null) {
      return owner(onPostDelete, onPostEdit);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Owner value) owner,
    required TResult Function(Viewer value) viewer,
  }) {
    return owner(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Owner value)? owner,
    TResult? Function(Viewer value)? viewer,
  }) {
    return owner?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Owner value)? owner,
    TResult Function(Viewer value)? viewer,
    required TResult orElse(),
  }) {
    if (owner != null) {
      return owner(this);
    }
    return orElse();
  }
}

abstract class Owner extends PostOptionsSettings {
  const factory Owner(
      {required final ValueSetter<String> onPostDelete,
      required final ValueSetter<PostBlock> onPostEdit}) = _$OwnerImpl;
  const Owner._() : super._();

  ValueSetter<String> get onPostDelete;
  ValueSetter<PostBlock> get onPostEdit;
  @JsonKey(ignore: true)
  _$$OwnerImplCopyWith<_$OwnerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ViewerImplCopyWith<$Res> {
  factory _$$ViewerImplCopyWith(
          _$ViewerImpl value, $Res Function(_$ViewerImpl) then) =
      __$$ViewerImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ViewerImplCopyWithImpl<$Res>
    extends _$PostOptionsSettingsCopyWithImpl<$Res, _$ViewerImpl>
    implements _$$ViewerImplCopyWith<$Res> {
  __$$ViewerImplCopyWithImpl(
      _$ViewerImpl _value, $Res Function(_$ViewerImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$ViewerImpl extends Viewer {
  const _$ViewerImpl() : super._();

  @override
  String toString() {
    return 'PostOptionsSettings.viewer()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ViewerImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            ValueSetter<String> onPostDelete, ValueSetter<PostBlock> onPostEdit)
        owner,
    required TResult Function() viewer,
  }) {
    return viewer();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ValueSetter<String> onPostDelete,
            ValueSetter<PostBlock> onPostEdit)?
        owner,
    TResult? Function()? viewer,
  }) {
    return viewer?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ValueSetter<String> onPostDelete,
            ValueSetter<PostBlock> onPostEdit)?
        owner,
    TResult Function()? viewer,
    required TResult orElse(),
  }) {
    if (viewer != null) {
      return viewer();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Owner value) owner,
    required TResult Function(Viewer value) viewer,
  }) {
    return viewer(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Owner value)? owner,
    TResult? Function(Viewer value)? viewer,
  }) {
    return viewer?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Owner value)? owner,
    TResult Function(Viewer value)? viewer,
    required TResult orElse(),
  }) {
    if (viewer != null) {
      return viewer(this);
    }
    return orElse();
  }
}

abstract class Viewer extends PostOptionsSettings {
  const factory Viewer() = _$ViewerImpl;
  const Viewer._() : super._();
}

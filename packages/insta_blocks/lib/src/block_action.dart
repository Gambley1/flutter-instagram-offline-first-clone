import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'block_action.g.dart';

/// The different types of actions.
enum BlockActionType {
  /// A navigation action represents an internal navigation to the provided uri.
  navigation,

  /// An unknown action type.
  unknown,
}

/// The extension on [BlockAction] which provides a method to execute the
/// action.
extension BlockActionX on BlockAction {
  /// Executes the action.
  FutureOr<void> when({
    FutureOr<void> Function(NavigateToPostAuthorProfileAction)?
        navigateToPostAuthor,
    FutureOr<void> Function(NavigateToSponsoredPostAuthorProfileAction)?
        navigateToSponsoredPostAuthor,
    FutureOr<void> Function()? unknown,
  }) =>
      switch (type) {
        NavigateToPostAuthorProfileAction.identifier =>
          navigateToPostAuthor?.call(this as NavigateToPostAuthorProfileAction),
        NavigateToSponsoredPostAuthorProfileAction.identifier =>
          navigateToSponsoredPostAuthor
              ?.call(this as NavigateToSponsoredPostAuthorProfileAction),
        _ => unknown?.call(),
      };
}

/// {@template block_action}
/// A class which represents an action that can occur
/// when interacting with a block.
/// {@endtemplate}
abstract class BlockAction {
  /// {@macro block_action}
  const BlockAction({
    required this.type,
    required this.actionType,
  });

  /// The type key used to identify the type of this action.
  final String type;

  /// The type of this action.
  final BlockActionType actionType;

  /// Converts the current instance to a `Map<String, dynamic>`.
  Map<String, dynamic> toJson();

  /// Deserialize [json] into a [BlockAction] instance.
  /// Returns [UnknownBlockAction] when the [json] is not a recognized type.
  static BlockAction fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    switch (type) {
      case NavigateToPostAuthorProfileAction.identifier:
        return NavigateToPostAuthorProfileAction.fromJson(json);
      case NavigateToSponsoredPostAuthorProfileAction.identifier:
        return NavigateToSponsoredPostAuthorProfileAction.fromJson(json);
    }
    return const UnknownBlockAction();
  }
}

/// {@template navigate_to_post_author_profile_action}
/// A block action which represents navigation to the author with [authorId].
/// {@endtemplate}
@JsonSerializable()
class NavigateToPostAuthorProfileAction
    with EquatableMixin
    implements BlockAction {
  /// {@macro navigate_to_post_author_profile_action}
  const NavigateToPostAuthorProfileAction({
    required this.authorId,
    this.type = NavigateToPostAuthorProfileAction.identifier,
  });

  /// Converts a `Map<String, dynamic>`
  /// into a [NavigateToPostAuthorProfileAction] instance.
  factory NavigateToPostAuthorProfileAction.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$NavigateToPostAuthorProfileActionFromJson(json);

  /// The identifier of this block action.
  static const identifier = '__navigate_to_author__';

  /// The id of the author profile to navigate to.
  final String authorId;

  @override
  BlockActionType get actionType => BlockActionType.navigation;

  @override
  final String type;

  @override
  Map<String, dynamic> toJson() =>
      _$NavigateToPostAuthorProfileActionToJson(this);

  @override
  List<Object?> get props => [type, actionType, authorId];
}

/// {@template navigate_to_sponsored_post_author_profile_action}
/// A block action which represents navigation to the sponsored author
/// with [authorId].
/// {@endtemplate}
@JsonSerializable()
class NavigateToSponsoredPostAuthorProfileAction
    with EquatableMixin
    implements BlockAction {
  /// {@macro navigate_to_sponsored_post_author_profile_action}
  const NavigateToSponsoredPostAuthorProfileAction({
    required this.authorId,
    required this.promoPreviewImageUrl,
    required this.promoUrl,
    this.type = NavigateToSponsoredPostAuthorProfileAction.identifier,
  });

  /// Converts a `Map<String, dynamic>`
  /// into a [NavigateToPostAuthorProfileAction] instance.
  factory NavigateToSponsoredPostAuthorProfileAction.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$NavigateToSponsoredPostAuthorProfileActionFromJson(json);

  /// The identifier of this block action.
  static const identifier = '__navigate_to_sponsored_author__';

  /// The id of the sponsored author profile to navigate to.
  final String authorId;

  /// The image url of the mini-promo that displayed at the bottom
  /// of profile screen.
  final String promoPreviewImageUrl;

  /// The mini-promo url that navigates user to the promoted website.
  final String promoUrl;

  @override
  BlockActionType get actionType => BlockActionType.navigation;

  @override
  final String type;

  @override
  Map<String, dynamic> toJson() =>
      _$NavigateToSponsoredPostAuthorProfileActionToJson(this);

  @override
  List<Object?> get props => [type, actionType, authorId];
}

/// {@template unknown_block_action}
/// A block action which represents an unknown type.
/// {@endtemplate}
@JsonSerializable()
class UnknownBlockAction with EquatableMixin implements BlockAction {
  /// {@macro unknown_block_action}
  const UnknownBlockAction({
    this.type = UnknownBlockAction.identifier,
  });

  /// Converts a `Map<String, dynamic>` into a [UnknownBlockAction] instance.
  factory UnknownBlockAction.fromJson(Map<String, dynamic> json) =>
      _$UnknownBlockActionFromJson(json);

  /// The identifier of this block action.
  static const identifier = '__unknown__';

  @override
  BlockActionType get actionType => BlockActionType.unknown;

  @override
  final String type;

  @override
  Map<String, dynamic> toJson() => _$UnknownBlockActionToJson(this);

  @override
  List<Object?> get props => [type, actionType];
}

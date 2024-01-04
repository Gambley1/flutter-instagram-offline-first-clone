// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:shared/shared.dart';

@immutable
class Post {
  /// {@macro post}
  const Post({
    required this.id,
    required this.author,
    required this.caption,
    required this.type,
    required this.mediaUrl,
    required this.publishedAt,
    required this.imagesUrl,
    required this.isOwner,
    required this.avatarUrl,
    required this.username,
    required this.fullName,
    this.updatedAt,
    this.subscribed,
    this.wasSubscribed,
  });

  factory Post.fromRow(
    Map<String, dynamic> row, {
    required String author,
    int? subscribed,
  }) {
    final isOwner = row['user_id'] == author;
    final isSubscribed = subscribed == 1 || isOwner;
    final wasSubscribed = isSubscribed;
    final username = row['username'] as String?;
    final fullName = row['full_name'] as String?;
    final avatarUrl = row['avatar_url'] as String?;

    return Post(
      id: row['id'] as String,
      author: row['user_id'] as String,
      caption: row['caption'] as String,
      type: row['type'] as String,
      mediaUrl: row['media_url'] as String,
      publishedAt: DateTime.parse(row['created_at'] as String),
      updatedAt: row['updated_at'] == null
          ? null
          : DateTime.parse(row['updated_at'] as String),
      imagesUrl:
          (jsonDecode(row['images_url'] as String) as List).cast<String>(),
      isOwner: isOwner,
      subscribed: isSubscribed,
      wasSubscribed: wasSubscribed,
      avatarUrl: avatarUrl ?? '',
      username: username ?? '',
      fullName: fullName ?? '',
    );
  }

  final String id;
  final String author;
  final String caption;
  final String type;
  final String mediaUrl;
  final DateTime publishedAt;
  final DateTime? updatedAt;
  final List<String> imagesUrl;
  final bool isOwner;
  final bool? subscribed;
  final bool? wasSubscribed;
  final String avatarUrl;
  final String username;
  final String fullName;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'author': {
        'id': author,
        'username': username,
        'full_name': fullName,
        'avatar_url': avatarUrl,
      },
      'caption': caption,
      'type': type,
      'mediaUrl': mediaUrl,
      'publishedAt': publishedAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'imageUrls': imagesUrl,
      'is_owner': isOwner.toInt,
    };
  }

  String toJson() => json.encode(toMap());
}

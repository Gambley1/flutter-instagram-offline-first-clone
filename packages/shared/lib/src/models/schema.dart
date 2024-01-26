import 'package:powersync/powersync.dart';

/// Global schema in local async SQLite database.
const schema = Schema([
  Table(
    'profiles',
    [
      Column.text('full_name'),
      Column.text('email'),
      Column.text('username'),
      Column.text('avatar_url'),
      Column.text('push_token'),
    ],
  ),
  Table(
    'posts',
    [
      Column.text('user_id'),
      Column.text('created_at'),
      Column.text('caption'),
      Column.text('updated_at'),
      Column.text('media'),
    ],
    indexes: [
      Index('user', [IndexedColumn('user_id')]),
    ],
  ),
  Table(
    'videos',
    [
      Column.text('owner_id'),
      Column.text('url'),
      Column.text('blur_hash'),
      Column.text('first_frame_url'),
    ],
    indexes: [
      Index('user', [IndexedColumn('owner_id')]),
    ],
  ),
  Table(
    'images',
    [
      Column.text('owner_id'),
      Column.text('url'),
      Column.text('blur_hash'),
    ],
    indexes: [
      Index('user', [IndexedColumn('owner_id')]),
    ],
  ),
  Table(
    'likes',
    [
      Column.text('user_id'),
      Column.text('comment_id'),
      Column.text('post_id'),
    ],
    indexes: [
      Index('user', [IndexedColumn('user_id')]),
      Index('post', [IndexedColumn('post_id')]),
      Index('comment', [IndexedColumn('comment_id')]),
    ],
  ),
  Table(
    'comments',
    [
      Column.text('post_id'),
      Column.text('user_id'),
      Column.text('content'),
      Column.text('created_at'),
      Column.text('replied_to_comment_id'),
    ],
    indexes: [
      Index('user', [IndexedColumn('user_id')]),
      Index('post', [IndexedColumn('post_id')]),
      Index('comment', [IndexedColumn('replied_to_comment_id')]),
    ],
  ),
  Table(
    'conversations',
    [
      Column.text('type'),
      Column.text('name'),
      Column.text('created_at'),
      Column.text('updated_at'),
    ],
  ),
  Table(
    'participants',
    [
      Column.text('user_id'),
      Column.text('conversation_id'),
    ],
    indexes: [
      Index('conversation', [IndexedColumn('conversation_id')]),
      Index('user', [IndexedColumn('user_id')]),
    ],
  ),
  Table(
    'messages',
    [
      Column.text('conversation_id'),
      Column.text('from_id'),
      Column.text('type'),
      Column.text('message'),
      Column.text('reply_message_id'),
      Column.text('created_at'),
      Column.text('updated_at'),
      Column.integer('is_read'),
      Column.integer('is_deleted'),
      Column.integer('is_edited'),
      Column.text('reply_message_username'),
      Column.text('reply_message_attachment_url'),
      Column.text('shared_post_id'),
    ],
    indexes: [
      Index('conversation', [IndexedColumn('conversation_id')]),
      Index('user', [IndexedColumn('from_id')]),
      Index('message', [IndexedColumn('reply_message_id')]),
      Index('post', [IndexedColumn('shared_post_id')]),
    ],
  ),
  Table(
    'attachments',
    [
      Column.text('message_id'),
      Column.text('title'),
      Column.text('text'),
      Column.text('title_link'),
      Column.text('image_url'),
      Column.text('thumb_url'),
      Column.text('author_name'),
      Column.text('author_link'),
      Column.text('asset_url'),
      Column.text('og_scrape_url'),
      Column.text('type'),
    ],
    indexes: [
      Index('message', [IndexedColumn('message_id')]),
    ],
  ),
  Table(
    'subscriptions',
    [
      Column.text('subscriber_id'),
      Column.text('subscribed_to_id'),
    ],
    indexes: [
      Index(
        'user',
        [IndexedColumn('subscriber_id'), IndexedColumn('subscribed_to_id')],
      ),
    ],
  ),
  Table(
    'stories',
    [
      Column.text('user_id'),
      Column.text('content_type'),
      Column.text('content_url'),
      Column.integer('duration'),
      Column.text('created_at'),
      Column.text('expires_at'),
    ],
    indexes: [
      Index('user', [IndexedColumn('user_id')]),
    ],
  ),
]);

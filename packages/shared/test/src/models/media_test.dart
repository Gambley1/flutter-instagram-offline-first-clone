import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';

void main() {
  final posts = [
    {
      'id': 'b6faca71-061c-4f05-93f0-d164baacca3d',
      'author': {
        'id': '67c36f68-3b92-4e11-89e9-cd7a22f3c37b',
        'username': 'emil.zulufov',
        'avatar_url':
            'https://wefeasvyrksvvywqgchk.supabase.co/storage/v1/object/public/avatars/126a526e-0ada-4144-90aa-30a4d3185844/avatar?t=1699129094691',
        'is_confirmed': true,
      },
      'created_at': '2023-11-09T00:00:00.000',
      'media': [
        {
          'media_id': uuid.v4(),
          'url':
              'https://blog.nursing.com/hs-fs/hubfs/visual%20nursing%20app.webp?width=1080&height=1080&name=visual%20nursing%20app.webp',
          'type': ImageMedia.identifier,
        },
      ],
      'caption': 'Hello world, this is a sponsored block #1',
      'action': {
        'author_id': '67c36f68-3b92-4e11-89e9-cd7a22f3c37b',
        'promo_preview_image_url':
            'https://instagram.fala5-2.fna.fbcdn.net/v/t51.2885-19/349043288_799972341566680_146016102643359969_n.jpg?stp=dst-jpg_s320x320&_nc_ht=instagram.fala5-2.fna.fbcdn.net&_nc_cat=104&_nc_ohc=sEVHyymBefkAX9i3zYg&edm=AOQ1c0wBAAAA&ccb=7-5&oh=00_AfBiQuXJ5iIIVb8qP-_RfY8a6gADNgP_PLsQEhqdhM8DRA&oe=6552BA94&_nc_sid=8b3546',
        'promo_url': 'https://www.instagram.com/zulu_em/',
        'type': '__navigate_to_sponsored_author__',
      },
      'type': '__post_sponsored__',
    },
    {
      'id': '0bcf4fa1-2a58-4809-b07b-5654e32e6fc2',
      'author': {
        'id': '67c36f68-3b92-4e11-89e9-cd7a22f3c37b',
        'username': 'emil.zulufov',
        'avatar_url':
            'https://wefeasvyrksvvywqgchk.supabase.co/storage/v1/object/public/avatars/126a526e-0ada-4144-90aa-30a4d3185844/avatar?t=1699129094691',
        'is_confirmed': true,
      },
      'created_at': '2023-11-09T00:00:00.000',
      'media': [
        {
          'media_id': uuid.v4(),
          'url':
              'https://images.squarespace-cdn.com/content/v1/54222358e4b0ef23d87a996b/1659992618857-S3ZIJIAT0V659W9HFTEF/3.png',
          'type': ImageMedia.identifier,
        },
      ],
      'caption': 'Hello world, this is a sponsored block #2',
      'action': {
        'author_id': '67c36f68-3b92-4e11-89e9-cd7a22f3c37b',
        'promo_preview_image_url':
            'https://instagram.fala5-2.fna.fbcdn.net/v/t51.2885-19/349043288_799972341566680_146016102643359969_n.jpg?stp=dst-jpg_s320x320&_nc_ht=instagram.fala5-2.fna.fbcdn.net&_nc_cat=104&_nc_ohc=sEVHyymBefkAX9i3zYg&edm=AOQ1c0wBAAAA&ccb=7-5&oh=00_AfBiQuXJ5iIIVb8qP-_RfY8a6gADNgP_PLsQEhqdhM8DRA&oe=6552BA94&_nc_sid=8b3546',
        'promo_url': 'https://www.instagram.com/zulu_em/',
        'type': '__navigate_to_sponsored_author__',
      },
      'type': '__post_sponsored__',
    },
    {
      'id': '4071ae1f-7e64-43d7-9763-4ced3b84dcfc',
      'author': {
        'id': '67c36f68-3b92-4e11-89e9-cd7a22f3c37b',
        'username': 'emil.zulufov',
        'avatar_url':
            'https://wefeasvyrksvvywqgchk.supabase.co/storage/v1/object/public/avatars/126a526e-0ada-4144-90aa-30a4d3185844/avatar?t=1699129094691',
        'is_confirmed': true,
      },
      'created_at': '2023-11-09T00:00:00.000',
      'media': [
        {
          'media_id': uuid.v4(),
          'url':
              'https://global.discourse-cdn.com/business7/uploads/adalo/original/2X/b/bc2fa4e8174f0b997c0a0f4167fe6895ae3092c4.jpeg',
          'type': ImageMedia.identifier,
        },
      ],
      'caption': 'Hello world, this is a sponsored block #3',
      'action': {
        'author_id': '67c36f68-3b92-4e11-89e9-cd7a22f3c37b',
        'promo_preview_image_url':
            'https://instagram.fala5-2.fna.fbcdn.net/v/t51.2885-19/349043288_799972341566680_146016102643359969_n.jpg?stp=dst-jpg_s320x320&_nc_ht=instagram.fala5-2.fna.fbcdn.net&_nc_cat=104&_nc_ohc=sEVHyymBefkAX9i3zYg&edm=AOQ1c0wBAAAA&ccb=7-5&oh=00_AfBiQuXJ5iIIVb8qP-_RfY8a6gADNgP_PLsQEhqdhM8DRA&oe=6552BA94&_nc_sid=8b3546',
        'promo_url': 'https://www.instagram.com/zulu_em/',
        'type': '__navigate_to_sponsored_author__',
      },
      'type': '__post_sponsored__',
    },
    {
      'id': '4f6a8b3f-07f6-4b33-a9fe-2420f750fe31',
      'author': {
        'id': '67c36f68-3b92-4e11-89e9-cd7a22f3c37b',
        'username': 'emil.zulufov',
        'avatar_url':
            'https://wefeasvyrksvvywqgchk.supabase.co/storage/v1/object/public/avatars/126a526e-0ada-4144-90aa-30a4d3185844/avatar?t=1699129094691',
        'is_confirmed': true,
      },
      'created_at': '2023-11-09T00:00:00.000',
      'media': [
        {
          'media_id': uuid.v4(),
          'url':
              'https://images.squarespace-cdn.com/content/v1/54222358e4b0ef23d87a996b/1659992618857-S3ZIJIAT0V659W9HFTEF/3.png',
          'type': ImageMedia.identifier,
        },
      ],
      'caption': 'Hello world, this is a sponsored block #4',
      'action': {
        'author_id': '67c36f68-3b92-4e11-89e9-cd7a22f3c37b',
        'promo_preview_image_url':
            'https://instagram.fala5-2.fna.fbcdn.net/v/t51.2885-19/349043288_799972341566680_146016102643359969_n.jpg?stp=dst-jpg_s320x320&_nc_ht=instagram.fala5-2.fna.fbcdn.net&_nc_cat=104&_nc_ohc=sEVHyymBefkAX9i3zYg&edm=AOQ1c0wBAAAA&ccb=7-5&oh=00_AfBiQuXJ5iIIVb8qP-_RfY8a6gADNgP_PLsQEhqdhM8DRA&oe=6552BA94&_nc_sid=8b3546',
        'promo_url': 'https://www.instagram.com/zulu_em/',
        'type': '__navigate_to_sponsored_author__',
      },
      'type': '__post_sponsored__',
    }
  ];

  final mockPostJsonString = <String, dynamic>{
    'id': 'post_mock_id_123',
    'created_at': DateTime.now().toIso8601String(),
    'caption': '',
    'user_id': '123',
    'avatar_url': '123',
    'username': 'Emil',
    'media': [
      {
        'media_id': 'abc',
        'url': 'image_url_123',
        'type': '__image_media__',
      },
      {
        'media_id': 'abc',
        'url': 'image_url_123',
        'type': '__video_media__',
      },
    ],
  };
  test('media de-serialization', () {
    final media = Media.fromJson(
      (mockPostJsonString['media'] as List<Map<String, String>>)[0],
    );
    logD(media.toJson());
  });

  test('de-serialize sponsored blocks', () {
    final sponsoredBlocks =
        List<InstaBlock>.from(posts.map(PostSponsoredBlock.fromJson));
    logD(sponsoredBlocks.map((e) => e.toJson()).toList());
  });
}

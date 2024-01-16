import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared/shared.dart';

/// Extensions on [String].
extension StringExtension on String {
  /// Returns the capitalized string
  String get capitalize =>
      isNotEmpty ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';

  /// Get websiteName from `hostName`.
  String? get getWebsiteName {
    switch (toLowerCase()) {
      case 'reddit':
        return 'Reddit';
      case 'youtube':
        return 'Youtube';
      case 'wikipedia':
        return 'Wikipedia';
      case 'twitter':
        return 'Twitter';
      case 'facebook':
        return 'Facebook';
      case 'amazon':
        return 'Amazon';
      case 'yelp':
        return 'Yelp';
      case 'imdb':
        return 'IMDB';
      case 'pinterest':
        return 'Pinterest';
      case 'tripadvisor':
        return 'TripAdvisor';
      case 'instagram':
        return 'Instagram';
      case 'walmart':
        return 'Walmart';
      case 'craigslist':
        return 'Craigslist';
      case 'ebay':
        return 'eBay';
      case 'linkedin':
        return 'LinkedIn';
      case 'google':
        return 'Google';
      case 'apple':
        return 'Apple';
      default:
        return null;
    }
  }

  /// Returns whether the string contains only emoji's or not.
  ///
  ///  Emojis guidelines
  ///  1 to 3 emojis: big size with no text bubble.
  ///  4+ emojis or emojis+text: standard size with text bubble.
  bool get isOnlyEmoji {
    final trimmedString = trim();
    if (trimmedString.isEmpty) return false;
    if (trimmedString.characters.length > 3) return false;
    final emojiRegex = RegExp(
      r'^(\u00a9|\u00ae|\u200d|[\ufe00-\ufe0f]|[\u2600-\u27FF]|[\u2300-\u2bFF]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])+$',
      multiLine: true,
      caseSensitive: false,
    );
    return emojiRegex.hasMatch(trimmedString);
  }

  /// returns the media type from the passed file name.
  MediaType? get mediaType {
    if (toLowerCase().endsWith('heic')) {
      return MediaType.parse('image/heic');
    } else {
      final mimeType = lookupMimeType(this);
      if (mimeType == null) return null;
      return MediaType.parse(mimeType);
    }
  }

  // Returns a resized imageUrl with the given [width], [height], [resize]
  /// and [crop] if it is from Stream CDN or Dashboard.
  String getResizedImageUrl({
    double width = 400,
    double height = 400,
    String /*clip|crop|scale|fill*/ resize = 'clip',
    String /*center|top|bottom|left|right*/ crop = 'center',
  }) {
    final uri = Uri.parse(this);
    final host = uri.host;

    final fromStreamCDN = host.endsWith('stream-io-cdn.com');
    final fromStreamDashboard = host.endsWith('stream-cloud-uploads.imgix.net');

    if (!fromStreamCDN && !fromStreamDashboard) {
      return this;
    }

    final queryParameters = {...uri.queryParameters};

    if (fromStreamCDN) {
      if (queryParameters['h'].isNullOrMatches('*') &&
          queryParameters['w'].isNullOrMatches('*') &&
          queryParameters['crop'].isNullOrMatches('*') &&
          queryParameters['resize'].isNullOrMatches('*')) {
        queryParameters['h'] = height.floor().toString();
        queryParameters['w'] = width.floor().toString();
        queryParameters['crop'] = crop;
        queryParameters['resize'] = resize;
      }
    } else if (fromStreamDashboard) {
      queryParameters['height'] = height.floor().toString();
      queryParameters['width'] = width.floor().toString();
      queryParameters['fit'] = crop;
    }

    return uri.replace(queryParameters: queryParameters).toString();
  }
}

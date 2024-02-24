import 'package:ogp_data_extract/ogp_data_extract.dart';
import 'package:shared/shared.dart';

/// Model response for an Open Graph attachment
class OGAttachment {
  /// {@macro og_attachment}
  const OGAttachment({
    required this.ogScrapeUrl,
    required this.assetUrl,
    required this.authorLink,
    required this.authorName,
    required this.imageUrl,
    required this.text,
    required this.thumbUrl,
    required this.title,
    required this.titleLink,
    required this.type,
    required this.imageHeight,
    required this.imageWidth,
  });

  /// Create a new instance from an [OgpData].
  factory OGAttachment.fromOgpAttachment({
    required OgpData ogp,
    String? ogScrapeUrl,
  }) =>
      OGAttachment(
        ogScrapeUrl: ogp.url ?? ogScrapeUrl,
        assetUrl: ogp.image,
        authorLink: ogp.countryName,
        authorName: ogp.siteName,
        imageUrl: ogp.image,
        imageHeight: ogp.imageHeight?.parse.toInt(),
        imageWidth: ogp.imageWidth?.parse.toInt(),
        text: ogp.description,
        thumbUrl: ogp.image,
        title: ogp.title,
        titleLink: ogp.url,
        type: AttachmentType.urlPreview.value,
      );

  /// The original URL that was used to scrape this attachment.
  final String? ogScrapeUrl;

  /// The URL of the asset.
  final String? assetUrl;

  /// The URL of the author.
  final String? authorLink;

  /// The name of the author.
  final String? authorName;

  /// The URL of the image.
  final String? imageUrl;

  /// The height of the image(if exists).
  final int? imageHeight;

  /// The width of the image(if exists).
  final int? imageWidth;

  /// The text of the attachment.
  final String? text;

  /// The URL of the thumbnail.
  final String? thumbUrl;

  /// The title of the attachment.
  final String? title;

  /// The URL of the title.
  final String? titleLink;

  /// The type of the attachment.
  ///
  /// 'video' | 'audio' | 'image'
  final String? type;
}

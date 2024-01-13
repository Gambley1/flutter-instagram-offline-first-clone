// ignore_for_file:  sort_constructors_first
// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart' hide Size;
import 'package:shared/shared.dart';

// Useful extensions on [Attachment].
extension OriginalSizeX on Attachment {
  /// Returns the size of the attachment if it is an image or giffy.
  /// Otherwise, returns null.
  Size? get originalSize {
    // Return null if the attachment is not an image or giffy.
    if (type != AttachmentType.image.value &&
        type != AttachmentType.giphy.value) {
      return null;
    }

    // Calculate size locally if the attachment is not uploaded yet.
    final file = this.file;
    if (file != null) {
      ImageInput? input;
      if (file.bytes != null) {
        input = MemoryInput(file.bytes!);
      } else if (file.path != null) {
        input = FileInput(File(file.path!));
      }

      // Return null if the file does not contain enough information.
      if (input == null) return null;

      try {
        final size = ImageSizeGetter.getSize(input);
        if (size.needRotate) {
          return Size(size.height.toDouble(), size.width.toDouble());
        }
        return Size(size.width.toDouble(), size.height.toDouble());
      } catch (e, stk) {
        logE('Error getting image size: $e\n$stk');
        return null;
      }
    }

    // Otherwise, use the size provided by the server.
    final width = originalWidth;
    final height = originalHeight;
    if (width == null || height == null) return null;
    return Size(width.toDouble(), height.toDouble());
  }
}

enum AttachmentType {
  image('image'),
  file('file'),
  giphy('giphy'),
  video('video'),
  audio('audio'),
  urlPreview('url_preview');

  const AttachmentType(this.value);

  final String value;
}

extension on String? {
  AttachmentType? get toAttachmentType {
    for (final type in AttachmentType.values) {
      if (type.value == this) {
        return type;
      }
    }
    return null;
  }
}

/// The class that contains the information about an attachment
class Attachment extends Equatable {
  /// Constructor used for json serialization
  Attachment({
    String? id,
    String? type,
    this.titleLink,
    String? title,
    this.thumbUrl,
    this.text,
    this.pretext,
    this.ogScrapeUrl,
    this.imageUrl,
    this.footerIcon,
    this.footer,
    this.fields,
    this.fallback,
    this.color,
    this.authorName,
    this.authorLink,
    this.authorIcon,
    this.assetUrl,
    this.originalWidth,
    this.originalHeight,
    Map<String, Object?> extraData = const {},
    this.file,
    UploadState? uploadState,
  })  : id = id ?? UidGenerator.v4(),
        _type = type,
        title = title ?? file?.name,
        _uploadState = uploadState,
        localUri = file?.path != null ? Uri.parse(file!.path!) : null,
        // For backwards compatibility,
        // set 'file_size', 'mime_type' in [extraData].
        extraData = {
          ...extraData,
          if (file?.size != null) 'file_size': file?.size,
          if (file?.mediaType != null) 'mime_type': file?.mediaType?.mimeType,
        };

  factory Attachment.fromOGAttachment(OGAttachment ogAttachment) => Attachment(
        // If the type is not specified, we default to urlPreview.
        type: AttachmentType.urlPreview.value,
        title: ogAttachment.title,
        titleLink: ogAttachment.titleLink,
        text: ogAttachment.text,
        imageUrl: ogAttachment.imageUrl,
        thumbUrl: ogAttachment.thumbUrl,
        authorName: ogAttachment.authorName,
        authorLink: ogAttachment.authorLink,
        assetUrl: ogAttachment.assetUrl,
        ogScrapeUrl: ogAttachment.ogScrapeUrl,
        uploadState: const UploadState.success(),
      );

  ///The attachment type based on the URL resource. This can be: audio,
  ///image or video
  String? get type {
    // If the attachment contains titleLink but is not of type giphy, we
    // consider it as a urlPreview.
    if (_type != AttachmentType.giphy.value && titleLink != null) {
      return AttachmentType.urlPreview.value;
    }

    return _type;
  }

  final String? _type;

  /// The raw attachment type.
  String? get rawType => _type;

  ///The link to which the attachment message points to.
  final String? titleLink;

  /// The attachment title
  final String? title;

  /// The URL to the attached file thumbnail. You can use this to represent the
  /// attached link.
  final String? thumbUrl;

  /// The attachment text. It will be displayed in the channel next to the
  /// original message.
  final String? text;

  /// Optional text that appears above the attachment block
  final String? pretext;

  /// The original URL that was used to scrape this attachment.
  final String? ogScrapeUrl;

  /// The URL to the attached image. This is present for URL pointing to an
  /// image article (eg. Unsplash)
  final String? imageUrl;
  final String? footerIcon;
  final String? footer;
  final dynamic fields;
  final String? fallback;
  final String? color;

  /// The name of the author.
  final String? authorName;
  final String? authorLink;
  final String? authorIcon;

  /// The URL to the audio, video or image related to the URL.
  final String? assetUrl;

  /// The original width of the attached image.
  final int? originalWidth;

  /// The original height of the attached image.
  final int? originalHeight;

  final Uri? localUri;

  /// The file present inside this attachment.
  final AttachmentFile? file;

  /// The current upload state of the attachment
  UploadState get uploadState {
    if (_uploadState case final state?) return state;

    return ((assetUrl != null || imageUrl != null || thumbUrl != null)
        ? const UploadState.success()
        : const UploadState.preparing());
  }

  final UploadState? _uploadState;

  /// Map of custom channel extraData
  final Map<String, Object?> extraData;

  /// The attachment ID.
  ///
  /// This is created locally for uniquely identifying a attachment.
  final String id;

  /// Shortcut for file size.
  ///
  /// {@macro fileSize}
  int? get fileSize => extraData['file_size'] as int?;

  /// Shortcut for file mimeType.
  ///
  /// {@macro mimeType}
  String? get mimeType => extraData['mime_type'] as String?;

  Attachment copyWith({
    String? id,
    String? type,
    String? titleLink,
    String? title,
    String? thumbUrl,
    String? text,
    String? pretext,
    String? ogScrapeUrl,
    String? imageUrl,
    String? footerIcon,
    String? footer,
    dynamic fields,
    String? fallback,
    String? color,
    String? authorName,
    String? authorLink,
    String? authorIcon,
    String? assetUrl,
    int? originalWidth,
    int? originalHeight,
    AttachmentFile? file,
    // UploadState? uploadState,
    Map<String, Object?>? extraData,
  }) =>
      Attachment(
        id: id ?? this.id,
        type: type ?? this.type,
        titleLink: titleLink ?? this.titleLink,
        title: title ?? this.title,
        thumbUrl: thumbUrl ?? this.thumbUrl,
        text: text ?? this.text,
        pretext: pretext ?? this.pretext,
        ogScrapeUrl: ogScrapeUrl ?? this.ogScrapeUrl,
        imageUrl: imageUrl ?? this.imageUrl,
        footerIcon: footerIcon ?? this.footerIcon,
        footer: footer ?? this.footer,
        fields: fields ?? this.fields,
        fallback: fallback ?? this.fallback,
        color: color ?? this.color,
        authorName: authorName ?? this.authorName,
        authorLink: authorLink ?? this.authorLink,
        authorIcon: authorIcon ?? this.authorIcon,
        assetUrl: assetUrl ?? this.assetUrl,
        originalWidth: originalWidth ?? this.originalWidth,
        originalHeight: originalHeight ?? this.originalHeight,
        file: file ?? this.file,
        // uploadState: uploadState ?? this.uploadState,
        extraData: extraData ?? this.extraData,
      );

  @override
  List<Object?> get props => [
        id,
        type,
        titleLink,
        title,
        thumbUrl,
        text,
        pretext,
        ogScrapeUrl,
        imageUrl,
        footerIcon,
        footer,
        fields,
        fallback,
        color,
        authorName,
        authorLink,
        authorIcon,
        assetUrl,
        originalWidth,
        originalHeight,
        file,
        // uploadState,
        extraData,
      ];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': type,
      'title_link': titleLink,
      'title': title,
      'thumb_url': thumbUrl,
      'text': text,
      'pretext': pretext,
      'og_scrape_url': ogScrapeUrl,
      'image_url': imageUrl,
      'footer_icon': footerIcon,
      'footer': footer,
      'fields': fields,
      'fallback': fallback,
      'color': color,
      'author_name': authorName,
      'author_link': authorLink,
      'author_icon': authorIcon,
      'asset_url': assetUrl,
      'original_width': originalWidth,
      'original_height': originalHeight,
      'file': file?.toMap(),
      'upload_state': _uploadState?.toJson(),
      'extra_data': extraData,
      'id': id,
    };
  }

  String toJson() => json.encode(toMap());

  factory Attachment.fromMap(Map<String, dynamic> map) {
    return Attachment(
      id: map['id'] as String,
      type: (map['type'] as String?).toAttachmentType?.value,
      titleLink: map['title_link'] as String?,
      title: map['title'] as String?,
      thumbUrl: map['thumb_url'] as String?,
      text: map['text'] as String?,
      pretext: map['pretext'] as String?,
      ogScrapeUrl: map['og_scrape_url'] as String?,
      imageUrl: map['image_url'] as String?,
      footerIcon: map['footer_ccon'] as String?,
      footer: map['footer'] as String?,
      fields: map['fields'] as dynamic,
      fallback: map['fallback'] as String?,
      color: map['color'] as String?,
      authorName: map['author_name'] as String?,
      authorLink: map['author_link'] as String?,
      authorIcon: map['author_icon'] as String?,
      assetUrl: map['asset_url'] as String?,
      originalWidth: map['original_width'] as int?,
      originalHeight: map['original_height'] as int?,
      file: map['file'] != null
          ? AttachmentFile.fromMap(map['file'] as Map<String, dynamic>)
          : null,
    );
  }

  factory Attachment.fromRow(Map<String, dynamic> row) {
    return Attachment(
      id: row['attachment_id'] as String,
      type: (row['attachment_type'] as String?).toAttachmentType?.value,
      titleLink: row['attachment_title_link'] as String?,
      title: row['attachment_title'] as String?,
      thumbUrl: row['attachment_thumb_url'] as String?,
      text: row['attachment_text'] as String?,
      pretext: row['attachment_pretext'] as String?,
      ogScrapeUrl: row['attachment_og_scrape_url'] as String?,
      imageUrl: row['attachment_image_url'] as String?,
      footerIcon: row['attachment_footer_ccon'] as String?,
      footer: row['attachment_footer'] as String?,
      fields: row['attachment_fields'] as dynamic,
      fallback: row['attachment_fallback'] as String?,
      color: row['attachment_color'] as String?,
      authorName: row['attachment_author_name'] as String?,
      authorLink: row['attachment_author_link'] as String?,
      authorIcon: row['attachment_author_icon'] as String?,
      assetUrl: row['attachment_asset_url'] as String?,
      originalWidth: row['attachment_original_width'] as int?,
      originalHeight: row['attachment_original_height'] as int?,
      file: row['attachment_file'] != null
          ? AttachmentFile.fromMap(row['file'] as Map<String, dynamic>)
          : null,
    );
  }

  factory Attachment.fromJson(String source) =>
      Attachment.fromMap(json.decode(source) as Map<String, dynamic>);
}

part of 'attachment_widget_builder.dart';

/// {@template mixedAttachmentBuilder}
/// A widget builder for Mixed attachment type.
///
/// This builder is used when a message contains a mix of media type and file
/// or url preview attachments.
///
/// This builder will render first the url preview or file attachment and then
/// the media attachments.
/// {@endtemplate}
class MixedAttachmentBuilder extends AttachmentWidgetBuilder {
  /// {@macro mixedAttachmentBuilder}
  MixedAttachmentBuilder({
    this.padding = const EdgeInsets.all(AppSpacing.xxs),
    AttachmentWidgetTapCallback? onAttachmentTap,
  })  : _imageAttachmentBuilder = ImageAttachmentBuilder(
          padding: EdgeInsets.zero,
          onAttachmentTap: onAttachmentTap,
        ),
        _urlAttachmentBuilder = UrlAttachmentBuilder(
          padding: EdgeInsets.zero,
          onAttachmentTap: onAttachmentTap,
        );

  /// The padding to apply to the mixed attachment widget.
  final EdgeInsetsGeometry padding;

  late final AttachmentWidgetBuilder _imageAttachmentBuilder;
  late final AttachmentWidgetBuilder _videoAttachmentBuilder;
  late final AttachmentWidgetBuilder _giphyAttachmentBuilder;
  late final AttachmentWidgetBuilder _galleryAttachmentBuilder;
  late final AttachmentWidgetBuilder _fileAttachmentBuilder;
  late final AttachmentWidgetBuilder _urlAttachmentBuilder;

  @override
  bool canHandle(
    Message message,
    Map<String, List<Attachment>> attachments,
  ) {
    final types = attachments.keys;

    final containsImage = types.contains(AttachmentType.image.value);
    final containsVideo = types.contains(AttachmentType.video.value);
    final containsGiphy = types.contains(AttachmentType.giphy.value);
    final containsFile = types.contains(AttachmentType.file.value);
    final containsUrlPreview = types.contains(AttachmentType.urlPreview.value);

    final containsMedia = containsImage || containsVideo || containsGiphy;

    return containsMedia && containsFile ||
        containsMedia && containsUrlPreview ||
        containsFile && containsUrlPreview ||
        containsMedia && containsFile && containsUrlPreview;
  }

  @override
  Widget build(
    BuildContext context,
    Message message,
    Map<String, List<Attachment>> attachments,
  ) {
    assert(debugAssertCanHandle(message, attachments), '');

    final urls = attachments[AttachmentType.urlPreview.value];
    final files = attachments[AttachmentType.file.value];
    final images = attachments[AttachmentType.image.value];
    final videos = attachments[AttachmentType.video.value];
    final giphys = attachments[AttachmentType.giphy.value];

    final shouldBuildGallery = [...?images, ...?videos, ...?giphys].length > 1;

    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (urls != null)
            _urlAttachmentBuilder.build(context, message, {
              AttachmentType.urlPreview.value: urls,
            }),
          if (files != null)
            _fileAttachmentBuilder.build(context, message, {
              AttachmentType.file.value: files,
            }),
          if (shouldBuildGallery)
            _galleryAttachmentBuilder.build(context, message, {
              if (images != null) AttachmentType.image.value: images,
              if (videos != null) AttachmentType.video.value: videos,
              if (giphys != null) AttachmentType.giphy.value: giphys,
            })
          else if (images != null && images.length == 1)
            _imageAttachmentBuilder.build(context, message, {
              AttachmentType.image.value: images,
            })
          else if (videos != null && videos.length == 1)
            _videoAttachmentBuilder.build(context, message, {
              AttachmentType.video.value: videos,
            })
          else if (giphys != null && giphys.length == 1)
            _giphyAttachmentBuilder.build(context, message, {
              AttachmentType.giphy.value: giphys,
            }),
        ].insertBetween(
          SizedBox(height: padding.vertical / 2),
        ),
      ),
    );
  }
}

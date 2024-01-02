import 'package:shared/shared.dart';

/// The [AttachmentPackage] class is basically meant to wrap
/// individual attachments with their corresponding message
class AttachmentPackage {
  /// Default constructor to prepare an [AttachmentPackage] object
  AttachmentPackage({
    required this.attachment,
    required this.message,
  });

  /// This is the individual attachment
  final Attachment attachment;

  /// This is the message that the attachment belongs to
  /// The message object may have attachment(s) other than the one packaged
  final Message message;
}

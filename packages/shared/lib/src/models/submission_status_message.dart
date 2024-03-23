/// {@template submission_status_message}
/// The `SubmissionStatusMessage` class represents a message that can be
/// displayed to the user to indicate the status of a submission.
/// {@endtemplate}
class SubmissionStatusMessage {
  /// {@macro submission_status_message}
  const SubmissionStatusMessage({
    required this.title,
    this.description,
  });

  /// {@macro submission_status_message.generic_error}
  const SubmissionStatusMessage.genericError()
      : this(
          title: 'Something went wrong! Try again later.',
        );

  /// {@macro submission_status_message.network_error}
  const SubmissionStatusMessage.networkError()
      : this(
          title: 'Internet connection error!',
          description: 'Check your internet connection and try again.',
        );

  /// The title for the status message. This will be shown prominently.
  final String title;

  /// The optional description for additional details about the status.
  final String? description;
}

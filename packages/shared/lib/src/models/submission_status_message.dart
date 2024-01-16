// ignore_for_file: public_member_api_docs

class SubmissionStatusMessage {
  const SubmissionStatusMessage({
    required this.title,
    this.description,
  });

  const SubmissionStatusMessage.genericError()
      : this(
          title: 'Something went wrong! Try again later.',
        );

  const SubmissionStatusMessage.networkError()
      : this(
          title: 'Internet connection error!',
          description: 'Check your internet connection and try again.',
        );

  final String title;
  final String? description;
}

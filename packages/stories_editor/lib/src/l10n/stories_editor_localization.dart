class StoriesEditorLocalization {
  factory StoriesEditorLocalization() => _instance;

  StoriesEditorLocalization._();

  static final StoriesEditorLocalization _instance =
      StoriesEditorLocalization._();

  void init(
      {StoriesEditorLocalizationDelegate? storiesEditorLocalizationDelegate}) {
    if (storiesEditorLocalizationDelegate != null) {
      delegate = storiesEditorLocalizationDelegate;
    }
  }

  StoriesEditorLocalizationDelegate delegate =
      const StoriesEditorLocalizationDelegate();
}

class StoriesEditorLocalizationDelegate {
  const StoriesEditorLocalizationDelegate({
    this.successfullySavedText = 'Successfully saved',
    this.errorText = 'Error',
    this.uploadText = 'Upload',
    this.tapToTypeText = 'Tap to type...',
    this.cancelText = 'Cancel',
    this.doneText = 'Done',
    this.discardEditsText = 'Discard Edits?',
    this.loseAllEditsText =
        "If you go back now, you'll loose all the edits you've made.",
    this.discardText = 'Discard',
    this.draftEmpty = 'Draft empty',
    this.saveDraft = 'Save Draft',
  });

  final String uploadText;
  final String successfullySavedText;
  final String errorText;
  final String tapToTypeText;
  final String cancelText;
  final String doneText;
  final String discardEditsText;
  final String loseAllEditsText;
  final String discardText;
  final String draftEmpty;
  final String saveDraft;
}

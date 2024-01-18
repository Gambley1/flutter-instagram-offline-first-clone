class TabsTexts {
  final String videoText;
  final String photoText;
  final String galleryText;
  final String deletingText;

  /// [limitingText] if the maximumSelection = 10 it will be "The limit is 10 photos or videos."
  String? limitingText;
  final String holdButtonText;
  final String clearImagesText;
  final String notFoundingCameraText;
  final String noImagesFounded;
  final String acceptAllPermissions;

  TabsTexts({
    this.videoText = "VIDEO",
    this.photoText = "PHOTO",
    this.clearImagesText = "Clear selected images",
    this.galleryText = "GALLERY",
    this.deletingText = "DELETE",
    this.limitingText,
    this.notFoundingCameraText = "No secondary camera found",
    this.holdButtonText = "Press and hold to record",
    this.noImagesFounded = "There is no images",
    this.acceptAllPermissions = "Failed! accept all access permissions.",
  });
}

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

class FollowButton extends StatelessWidget {
  const FollowButton({
    required this.isSubscribed,
    required this.wasSubscribed,
    required this.subscribe,
    super.key,
  });

  final bool isSubscribed;
  final bool wasSubscribed;
  final VoidCallback subscribe;

  static const _unfollowedText = 'Follow';
  static const _followedText = 'Following';

  @override
  Widget build(BuildContext context) {
    String? followingStatus() {
      if (!wasSubscribed && isSubscribed) {
        return _followedText;
      }
      if (!wasSubscribed && !isSubscribed) {
        return _unfollowedText;
      }
      if (wasSubscribed && !isSubscribed) {
        return _unfollowedText;
      }
      return null;
    }

    return followingStatus() == null
        ? const SizedBox.shrink()
        : Tappable(
            onTap: subscribe,
            child: Container(
              decoration: BoxDecoration(
                color: context.customReversedAdaptiveColor(
                  light: Colors.grey.shade300,
                  dark: Colors.grey.shade700,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
              child: Text(
                followingStatus()!,
                style: context.labelLarge,
              ),
            ),
          );
  }
}

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

class SubscribeButton extends StatelessWidget {
  const SubscribeButton({
    required this.isSubscribed,
    required this.wasSubscribed,
    required this.subscribe,
    super.key,
  });

  final bool isSubscribed;
  final bool wasSubscribed;
  final VoidCallback subscribe;

  static const _unsubscribedText = 'Subscribe';
  static const _subscribedText = 'Subscriptions';

  @override
  Widget build(BuildContext context) {
    String? text() {
      if (!wasSubscribed && isSubscribed) {
        return _subscribedText;
      }
      if (!wasSubscribed && !isSubscribed) {
        return _unsubscribedText;
      }
      if (wasSubscribed && !isSubscribed) {
        return _unsubscribedText;
      }
      return null;
    }

    return text() == null
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
                text()!,
                style: context.labelLarge,
              ),
            ),
          );
  }
}

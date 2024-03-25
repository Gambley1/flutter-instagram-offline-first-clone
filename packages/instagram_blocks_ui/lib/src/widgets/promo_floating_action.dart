import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'
    hide NumDurationExtensions;
import 'package:instagram_blocks_ui/src/attachments/index.dart';
import 'package:shared/shared.dart';
import 'package:sprung/sprung.dart';
import 'package:url_launcher/url_launcher.dart';

class PromoFloatingAction extends StatelessWidget {
  const PromoFloatingAction({
    required this.url,
    required this.promoImageUrl,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final String url;
  final String promoImageUrl;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final splittedUrl = url.split('/')[2];
    final shortenWebsite = splittedUrl.contains('www')
        ? splittedUrl.replaceAll('www', '').replaceFirst('.', '')
        : splittedUrl;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Tappable(
        color: AppColors.blue,
        borderRadius: 4,
        animationEffect: TappableAnimationEffect.none,
        onTap: () => launchUrl(Uri.parse(url)),
        child: ListTile(
          leading: ImageAttachmentThumbnail(
            image: Attachment(
              imageUrl:
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Instagram_icon.png/600px-Instagram_icon.png',
            ),
            width: 42,
            borderRadius: 2,
            withPlaceholder: false,
          ),
          horizontalTitleGap: AppSpacing.sm,
          title: Text(
            title,
            style: context.bodyLarge?.copyWith(fontWeight: AppFontWeight.bold),
          ),
          subtitle: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '$subtitle '),
                TextSpan(
                  text: shortenWebsite,
                  style: context.labelLarge,
                ),
              ],
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: AppSize.iconSizeSmall,
          ),
        ),
      ),
    ).animate().moveY(
          duration: 650.ms,
          begin: 200,
          end: 0,
          curve: Sprung.custom(damping: 12, stiffness: 65),
        );
  }
}

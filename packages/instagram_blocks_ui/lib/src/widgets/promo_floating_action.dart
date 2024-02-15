import 'package:app_ui/app_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
        color: Colors.blue.shade400,
        borderRadius: 4,
        animationEffect: TappableAnimationEffect.none,
        onTap: () => launchUrl(Uri.parse(url)),
        child: ListTile(
          leading: Container(
            width: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              image: const DecorationImage(
                image: CachedNetworkImageProvider(
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Instagram_icon.png/600px-Instagram_icon.png',
                  cacheKey:
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Instagram_icon.png/600px-Instagram_icon.png',
                ),
              ),
            ),
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

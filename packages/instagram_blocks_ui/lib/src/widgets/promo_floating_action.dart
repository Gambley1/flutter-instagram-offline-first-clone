import 'package:app_ui/app_ui.dart';
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
      padding: const EdgeInsets.all(10),
      child: Tappable(
        color: Colors.blue.shade400,
        borderRadius: 4,
        animationEffect: TappableAnimationEffect.none,
        onTap: () => launchUrl(Uri.parse(url)),
        child: ListTile(
          leading: Container(
            width: 42,
            padding: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              image: DecorationImage(
                image: NetworkImage(
                  promoImageUrl,
                ),
              ),
            ),
          ),
          title: Text(
            title,
            style: context.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(
            '$subtitle $shortenWebsite',
            style: context.labelLarge?.copyWith(fontWeight: FontWeight.w700),
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

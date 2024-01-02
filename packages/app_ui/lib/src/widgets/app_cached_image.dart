// // ignore_for_file: avoid_multiple_declarations_per_line, unused_element

// import 'dart:math' show Random;

// import 'package:app_ui/app_ui.dart';
// import 'package:cached_network_image/cached_network_image.dart'
//     show CachedNetworkImage;
// import 'package:flutter/material.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// enum CacheImageType {
//   bigImage,
//   smallImage,
//   smallImageWithNoShimmer,
// }

// enum InkEffect {
//   withEffect,
//   noEffect,
// }

// const _smallCacheKey = 'smallImageCacheKey';
// const _smallCacheKeyWithoutShimmer = 'smallImageCacheKeyWithoutShimmer';
// const _bigCacheKey = 'bigImageCacheKey';

// Config _config({required String cacheKeyName, int stalePerioud = 1}) => Config(
//       cacheKeyName,
//       maxNrOfCacheObjects: 60,
//       stalePeriod: Duration(
//         days: stalePerioud,
//       ),
//     );

// CacheManager _defaultCacheManager(String cackeKeyName) => CacheManager(
//       _config(cacheKeyName: cackeKeyName),
//     );

// class CachedImage extends StatelessWidget {
//   CachedImage({
//     required this.imageUrl,
//     required this.imageType,
//     this.inkEffect = InkEffect.noEffect,
//     super.key,
//     this.width = 100,
//     this.height = 100,
//     this.shimmerHeight,
//     this.shimmerWidth,
//     this.bottom = 0,
//     this.left = 20,
//     this.top = 20,
//     this.right = 0,
//     this.radius = defaultBorderRadius,
//     this.sizeXMark = 18,
//     this.sizeSimpleIcon = 32,
//     this.onTap,
//     this.onTapBorderRadius = defaultBorderRadius,
//     this.placeIdToParse = '',
//     this.heroTag = '',
//     this.restaurantName = '',
//     this.borderRadius,
//   });

//   final String imageUrl, placeIdToParse, heroTag, restaurantName;
//   final double? shimmerWidth, shimmerHeight;
//   final double height,
//       width,
//       top,
//       left,
//       right,
//       bottom,
//       sizeXMark,
//       sizeSimpleIcon,
//       radius,
//       onTapBorderRadius;
//   final CacheImageType imageType;
//   final InkEffect inkEffect;
//   final VoidCallback? onTap;
//   final BorderRadius? borderRadius;

//   late final hasInkEffect = inkEffect == InkEffect.withEffect;

//   late final isSmallImage = imageType == CacheImageType.smallImage;
//   late final isSmallImageWithNoShimmer =
//       imageType == CacheImageType.smallImageWithNoShimmer;
//   late final isBigImage = imageType == CacheImageType.bigImage;
//   late final hasOnTapFunction = onTap != null;

//   final colorList = [
//     Colors.brown.withOpacity(.9),
//     Colors.black.withOpacity(.9),
//     Colors.cyan.withOpacity(.8),
//     Colors.green.withOpacity(.8),
//     Colors.indigo.withOpacity(.9),
//   ];

//   Color _getRandomColor() {
//     final placeId = placeIdToParse.replaceAll(RegExp(r'[^\d]'), '');
//     final index = int.tryParse(placeId) ?? 1;
//     final random = Random(index);
//     return colorList[random.nextInt(colorList.length)];
//   }

//   Container _buildErrorEmpty(
//     double width,
//     double height, {
//     double radius = defaultBorderRadius,
//   }) =>
//       Container(
//         height: height,
//         width: width,
//         decoration: BoxDecoration(
//           color: Colors.grey.shade100,
//           borderRadius: BorderRadius.circular(radius),
//         ),
//       );

//   Container _buildPlaceHolder(double width, double heigth) => Container(
//         width: width,
//         height: height,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(
//             radius,
//           ),
//           image: const DecorationImage(
//             image: AssetImage(
//               'assets/images/PlaceHolderRestaurant.jpg',
//             ),
//             fit: BoxFit.cover,
//           ),
//         ),
//       );

//   Widget _buildErrorPlaceHolder(double width, double height) =>
//       _buildPlaceHolder(width, height);

//   Widget _buildImage(
//     double width,
//     double height,
//     ImageProvider<Object> imageProvider, {
//     double radius = defaultBorderRadius,
//     BoxFit boxFit = BoxFit.cover,
//     bool inkEffectOn = true,
//     bool buildBigImage = false,
//     BorderRadius? borderRadius,
//   }) {
//     BoxDecoration imageBoxDecoration() => BoxDecoration(
//           borderRadius: borderRadius ?? BorderRadius.circular(radius),
//           image: DecorationImage(
//             image: imageProvider,
//             fit: boxFit,
//           ),
//         );

//     Positioned smoothImageFade() => Positioned.fill(
//           child: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.center,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   Colors.transparent,
//                   _getRandomColor(),
//                 ],
//                 stops: const [0.1, 1],
//               ),
//             ),
//           ),
//         );

//     Widget imageWithInk() => hasOnTapFunction
//         ? InkWell(
//             onTap: onTap,
//             borderRadius: BorderRadius.circular(onTapBorderRadius),
//             child: Ink(
//               height: height,
//               width: width,
//               decoration: imageBoxDecoration(),
//             ),
//           )
//         : Ink(
//             height: height,
//             width: width,
//             decoration: imageBoxDecoration(),
//           );

//     StatelessWidget imageWithoutInk() => hasOnTapFunction
//         ? GestureDetector(
//             onTap: onTap,
//             child: Container(
//               height: height,
//               width: width,
//               decoration: imageBoxDecoration(),
//             ),
//           )
//         : Container(
//             height: height,
//             width: width,
//             decoration: imageBoxDecoration(),
//           );

//     Stack bigImage() => Stack(
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image: imageProvider,
//                   fit: boxFit,
//                 ),
//               ),
//             ),
//             smoothImageFade(),
//             // statisticAndDetailsOfRest(),
//             // nameOfRest(),
//           ],
//         );

//     if (inkEffectOn) return imageWithInk();
//     if (buildBigImage) return bigImage();
//     return imageWithoutInk();
//   }

//   CachedNetworkImage _buildCachedNetworkImage(BuildContext context) {
//     CachedNetworkImage smallCachedImage() => CachedNetworkImage(
//           imageUrl: imageUrl,
//           cacheManager: _defaultCacheManager(_smallCacheKey),
//           imageBuilder: (context, imageProvider) => _buildImage(
//             width,
//             height,
//             imageProvider,
//             radius: radius,
//             inkEffectOn: hasInkEffect,
//             borderRadius: borderRadius,
//           ),
//           placeholder: (_, __) => ShimmerLoading(
//             radius: radius,
//             width: shimmerWidth ?? width,
//             height: shimmerHeight ?? height,
//           ),
//           errorWidget: (_, __, ___) =>
//               _buildErrorEmpty(width, height, radius: radius),
//         );

//     CachedNetworkImage smallWithoutShimmerCachedImage() => CachedNetworkImage(
//           imageUrl: imageUrl,
//           cacheManager: _defaultCacheManager(_smallCacheKeyWithoutShimmer),
//           imageBuilder: (_, imageProvider) => _buildImage(
//             width,
//             height,
//             imageProvider,
//             inkEffectOn: hasInkEffect,
//           ),
//           placeholder: (_, __) => _buildPlaceHolder(width, height),
//           errorWidget: (_, __, ___) => _buildErrorPlaceHolder(width, height),
//         );

//     CachedNetworkImage bigCachedImage() => CachedNetworkImage(
//           imageUrl: imageUrl,
//           cacheManager: _defaultCacheManager(_bigCacheKey),
//           imageBuilder: (_, imageProvider) => _buildImage(
//             width,
//             height,
//             imageProvider,
//             buildBigImage: true,
//             inkEffectOn: hasInkEffect,
//           ),
//           placeholder: (_, __) => const ShimmerLoading(),
//           placeholderFadeInDuration: const Duration(seconds: 2),
//           errorWidget: (_, __, ___) => _buildErrorPlaceHolder(width, height),
//         );

//     if (isSmallImage) return smallCachedImage();
//     if (isSmallImageWithNoShimmer) return smallWithoutShimmerCachedImage();
//     if (isBigImage) return bigCachedImage();
//     return smallCachedImage();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return _buildCachedNetworkImage(context);
//   }
// }

// abstract class _CachedImageBase extends StatelessWidget {
//   const _CachedImageBase({
//     required this.imageUrl,
//     required this.width,
//     required this.height,
//     required this.radius,
//     required this.hasInkEffect,
//     required this.borderRadius,
//     this.shimmerWidth,
//     this.shimmerHeight,
//   });

//   final String imageUrl;

//   final double width;

//   final double height;

//   final double radius;

//   final bool hasInkEffect;

//   final double borderRadius;

//   final double? shimmerWidth;

//   final double? shimmerHeight;

//   Widget builder(BuildContext context);

//   @override
//   Widget build(BuildContext context) => builder(context);
// }

// class _SmallCahedImage extends _CachedImageBase {
//   const _SmallCahedImage({
//     required super.imageUrl,
//     required super.width,
//     required super.height,
//     required super.radius,
//     required super.hasInkEffect,
//     required super.borderRadius,
//     super.shimmerWidth,
//     super.shimmerHeight,
//   });

//   @override
//   Widget builder(BuildContext context) {
//     return CachedNetworkImage(
//       imageUrl: imageUrl,
//       cacheManager: _defaultCacheManager(_smallCacheKey),
//       imageBuilder: (context, imageProvider) => _buildImage(
//         width,
//         height,
//         imageProvider,
//         radius: radius,
//         inkEffectOn: hasInkEffect,
//         borderRadius: borderRadius,
//       ),
//       placeholder: (_, __) => ShimmerLoading(
//         radius: radius,
//         width: shimmerWidth ?? width,
//         height: shimmerHeight ?? height,
//       ),
//       errorWidget: (_, __, ___) =>
//           _buildErrorEmpty(width, height, radius: radius),
//     );
//   }
// }

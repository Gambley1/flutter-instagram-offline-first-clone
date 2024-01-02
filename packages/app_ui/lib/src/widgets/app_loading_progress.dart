import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

// class GlobalLoadingProgress extends StatefulWidget {
//   const GlobalLoadingProgress({
//     super.key,
//   });

//   @override
//   State<GlobalLoadingProgress> createState() => GlobalLoadingProgressState();
// }

// class GlobalLoadingProgressState extends State<GlobalLoadingProgress> {
//   double progressPercentage = 0;
//   void setProgressPercentage(double percent) {
//     setState(() {
//       progressPercentage = percent;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Make the loading bar height slightly higher than the indeterminate progress
//     // to ensure it gets covered fully
//     const loadingBarHeight = 3.1;
//     return Align(
//       alignment: getIsFullScreen(context) == false
//           ? Alignment.bottomLeft
//           : Alignment.topCenter,
//       child: AnimatedOpacity(
//         opacity: progressPercentage <= 0 || progressPercentage >= 1 ? 0 : 1,
//         duration: const Duration(milliseconds: 300),
//         child: Stack(
//           children: [
//             Container(
//               color: getBottomNavbarBackgroundColor(
//                 brightness: Theme.of(context).brightness,
//                 colorScheme: Theme.of(context).colorScheme,
//                 lightDarkAccent: getColor(context, 'lightDarkAccent'),
//               ),
//               height: loadingBarHeight,
//             ),
//             AnimatedContainer(
//               duration: const Duration(milliseconds: 300),
//               curve: Curves.easeInOut,
//               height: loadingBarHeight,
//               width: MediaQuery.of(context).size.width * progressPercentage,
//               decoration: BoxDecoration(
//                 color: dynamicPastel(
//                   context,
//                   Theme.of(context).colorScheme.primary,
//                   amount: 0.5,
//                 ),
//                 borderRadius: const BorderRadius.only(
//                   bottomRight: Radius.circular(5),
//                   topRight: Radius.circular(5),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class ApplLoadingIndeterminate extends StatefulWidget {
  const ApplLoadingIndeterminate({
    super.key,
  });

  @override
  State<ApplLoadingIndeterminate> createState() =>
      AppLoadingIndeterminateState();
}

class AppLoadingIndeterminateState extends State<ApplLoadingIndeterminate> {
  bool visible = false;
  double opacity = 0;
  // Set the timeout for loading indicator
  final _debouncer = Debouncer(milliseconds: 5000);

  void setVisibility(bool visible, {double? opacity}) {
    setState(() {
      this.visible = visible;
      this.opacity = visible == false ? 1 : opacity ?? 1;
    });
    _debouncer.run(() {
      setState(() {
        this.visible = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: SizedBox(
        width: Helper.getIsFullScreen(context) == false
            ? null
            : Helper.getWidthNavigationSidebar(context),
        child: Align(
          // alignment: getIsFullScreen(context) == false
          //     ? Alignment.bottomLeft
          //     : Alignment.topCenter,
          alignment: Alignment.bottomLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: !visible ? 0 : 3,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(5),
                topRight: Radius.circular(5),
              ),
            ),
            child: const ClipRRect(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(5),
                topRight: Radius.circular(5),
              ),
              child: LinearProgressIndicator(
                color: Colors.red,
                backgroundColor: Colors.yellow,
                // backgroundColor: Helper.getBottomNavbarBackgroundColor(
                //   brightness: Theme.of(context).brightness,
                //   colorScheme: Theme.of(context).colorScheme,
                //   // lightDarkAccent: getColor(context, 'lightDarkAccent'),
                // ),
                minHeight: 3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// {@template helper}
/// Helper class to get the width of the navigation sidebar.
/// {@endtemplate}
class Helper {
  const Helper._();

  /// Returns 0 if no navigation sidebar should be shown.
  static double getWidthNavigationSidebar(BuildContext context) {
    const screenPercent = 0.3;
    const maxWidthNavigation = 270;
    const minScreenWidth = 700;

    if (context.screenWidth < minScreenWidth) return 0;
    return (context.screenWidth * screenPercent > maxWidthNavigation
            ? maxWidthNavigation
            : context.screenWidth * screenPercent) +
        MediaQuery.of(context).viewPadding.left;
  }

  /// Returns true if the navigation sidebar should be shown.
  static bool getIsFullScreen(BuildContext context) {
    return getWidthNavigationSidebar(context) > 0;
  }
}

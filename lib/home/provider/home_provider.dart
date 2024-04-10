import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class HomeProvider extends ChangeNotifier {
  factory HomeProvider() => _internal ?? HomeProvider._();

  HomeProvider._();

  static HomeProvider? _internal = HomeProvider._();

  late PageController pageController;

  void setPageController(PageController controller) {
    pageController = controller;
    notifyListeners();
  }

  void animateToPage(int page) => pageController.animateToPage(
        page,
        curve: Easing.legacy,
        duration: 150.ms,
      );

  bool enablePageView = true;

  void togglePageView({bool enable = true}) {
    enablePageView = enable;
    notifyListeners();
  }

  @override
  void dispose() {
    _internal = null;
    super.dispose();
  }
}

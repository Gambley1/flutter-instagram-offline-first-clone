import 'package:flutter/material.dart';

class FeedPageController extends ChangeNotifier {
  FeedPageController();

  static late ScrollController nestedScrollController;
  static late ScrollController feedScrollController;

  static void init({
    required ScrollController nestedController,
    required ScrollController feedController,
  }) {
    nestedScrollController = nestedController;
    feedScrollController = feedController;
  }

  final _animationPlayed = ValueNotifier(false);

  final _animationValue = ValueNotifier<double>(0);

  bool get hasPlayedAnimation => _animationPlayed.value;

  double get animationValue => _animationValue.value;

  void setPlayedAnimation(double value) {
    if (_animationPlayed.value == true) return;

    _animationPlayed.value = true;
    _animationValue.value = value;
    notifyListeners();
  }
}

// ignore_for_file: use_setters_to_change_properties

import 'package:flutter/foundation.dart';

class CarouselIndicatorController extends ValueNotifier<int> {
  CarouselIndicatorController() : super(0);

  void updateCurrentIndex(int index) => value = index;
}

import 'dart:developer' as dev;

import 'package:shared/shared.dart';

/// Iterable extensions
extension IterableExtension<T> on Iterable<T> {
  /// Insert any item<T> inBetween the list items
  List<T> insertBetween(T item) => expand((e) sync* {
        yield item;
        yield e;
      }).skip(1).toList(growable: false);

  /// Insert any item<T> inBetween the list items
  Iterable<T> separatedBy(T element) sync* {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      yield iterator.current;
      while (iterator.moveNext()) {
        yield element;
        yield iterator.current;
      }
    }
  }

  /// Applies to each element in the iterable [toElement] function. If
  /// try catch block caught an error, it will be logged and null will be
  /// returned.
  Iterable<E?> safeNullableMap<E>(
    E Function(T element) toElement, {
    bool logError = true,
  }) =>
      map((e) {
        try {
          return toElement(e);
        } catch (e) {
          if (logError) logE('Error in safeMap: $e');
          return null;
        }
      });

  /// Applies [toElement] function to each element in the iterable. If
  /// try catch block caught an error, it will be logged and null will be
  /// returned.
  ///
  /// Filters any nullable results and will return only non-nullable objects.
  Iterable<E> safeMap<E>(
    E Function(T element) toElement, {
    bool logError = true,
  }) sync* {
    for (final element in this) {
      try {
        yield toElement(element);
      } catch (error) {
        if (logError) dev.log('Error in safeMap: $error');
      }
    }
  }
}

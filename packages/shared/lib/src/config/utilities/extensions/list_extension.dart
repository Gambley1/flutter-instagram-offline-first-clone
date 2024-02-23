import 'dart:developer' as dev;

/// Iterable extensions
extension ListExtension<T> on List<T> {
  /// Updates the list by finding an element matching [findCallback], replacing
  /// it with [newItem] using [onUpdate] function, or inserting [newItem]
  /// if no match.
  ///
  /// If [isDelete] is true, the matching element will be removed instead of
  /// replaced.
  List<T> updateWith<E extends T>({
    required bool Function(T item, T newItem) findCallback,
    required T Function(E item, T newItem) onUpdate,
    required T? newItem,
    bool isDelete = false,
    bool insertIfNotFound = true,
  }) {
    if (newItem == null) {
      dev.log('No `newItem` was provided. '
          'Return the original list without any modifications');
      return this;
    }
    final index = indexWhere((item) => findCallback(item, newItem));

    if (index != -1) {
      if (isDelete) {
        removeAt(index);
      } else {
        this[index] = onUpdate(this[index] as E, newItem);
      }
    } else {
      if (!insertIfNotFound) {
        dev.log('No item found by provided `findCallback` in the list. '
            'No action applied to the list. Return the original list.');
        return this;
      }
      dev.log('No item found by provided `findCallback` in the list. '
          'Insert provided `newItem` into the list. Return the modified list.');
      insert(0, newItem);
    }
    return this;
  }
}

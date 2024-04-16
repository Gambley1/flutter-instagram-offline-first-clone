import 'dart:developer' as dev;

/// Represents a typedef called `FindItemCallback` that takes in two parameters:
/// - `item` of type `T`: The item to be compared.
/// - `newItem` of type `T`: The new item to be compared with.
///
/// This typedef is used to define a callback function that determines whether
/// an item matches the new item based on some condition.
typedef FindItemCallback<T> = bool Function(T item, T newItem);

/// Represents a typedef called `UpdateCallback` that defines a callback 
/// function used to update an item of type `T` with a new item of type `T`.
typedef UpdateCallback<T, E> = T Function(E item, T newItem);

/// Extension method on List that updates the list.
extension UpdateListExtension<T> on List<T> {
  /// Updates the list by finding an element matching [findItemCallback],
  /// replacing it with [newItem] using [onUpdate] function, or inserting
  /// [newItem] if no match.
  ///
  /// If [isDelete] is true, the matching element will be removed instead of
  /// replaced.
  List<T> updateWith<E extends T>({
    required T? newItem,
    required FindItemCallback<T> findItemCallback,
    required UpdateCallback<T, E> onUpdate,
    bool isDelete = false,
    bool insertIfNotFound = true,
  }) {
    if (newItem == null) {
      dev.log('No `newItem` was provided. '
          'Return the original list without any modifications');
      return this;
    }
    final index = indexWhere((item) => findItemCallback(item, newItem));

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

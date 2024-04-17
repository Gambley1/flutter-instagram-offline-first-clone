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

/// {@template update_list_exception}
/// Exceptions from the update list extension.
/// {@endtemplate}
abstract class UpdateListException implements Exception {
  /// {@macro update_list_exception}
  const UpdateListException(this.error);

  /// The error which was caught.
  final Object error;

  @override
  String toString() => 'Update list exception error: $error';
}

/// {@template delete_item_failure}
/// Thrown during the deletion of the item if a failure occurs.
/// {@endtemplate}
class DeleteItemFailure extends UpdateListException {
  /// {@macro delete_item_failure}
  const DeleteItemFailure(super.error);
}

/// {@template update_item_failure}
/// Thrown during the update of the item if a failure occurs.
/// {@endtemplate}
class UpdateItemFailure extends UpdateListException {
  /// {@macro update_item_failure}
  const UpdateItemFailure(super.error);
}

/// {@template insert_item_failure}
/// Thrown during the insert of the item if a failure occurs.
/// {@endtemplate}
class InsertItemFailure extends UpdateListException {
  /// {@macro insert_item_failure}
  const InsertItemFailure(super.error);
}

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
        try {
          removeAt(index);
          dev.log('Removed the item at index $index from the list.');
        } catch (error, stackTrace) {
          Error.throwWithStackTrace(DeleteItemFailure(error), stackTrace);
        }
      } else {
        try {
          this[index] = onUpdate(this[index] as E, newItem);
          dev.log('Updated the list at index $index with the new item.');
        } catch (error, stackTrace) {
          Error.throwWithStackTrace(UpdateItemFailure(error), stackTrace);
        }
      }
    } else {
      if (!insertIfNotFound) {
        dev.log(
          'No item found by provided `findCallback` in the list. '
          'Return the original list.',
        );
        return this;
      }
      dev.log(
        'Insert provided `newItem` into the list. Return the modified list.',
      );
      try {
        insert(0, newItem);
      } catch (error, stackTrace) {
        Error.throwWithStackTrace(InsertItemFailure(error), stackTrace);
      }
    }
    return this;
  }
}

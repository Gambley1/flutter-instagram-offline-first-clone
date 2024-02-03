/// List extension
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
}

/// The extension that splits the original string and inserts the `text` between
/// each word.
extension SplitTextBy on String {
  /// Splits the original string and inserts the [text] between
  /// each word.
  String insertBetween(String text, {String splitBy = ' '}) {
    final iterator = split(splitBy).iterator;
    final str = StringBuffer();
    if (iterator.moveNext()) {
      str.write(iterator.current);
      while (iterator.moveNext()) {
        str
          ..write(' $text ')
          ..write(iterator.current);
      }
    }
    return str.toString();
  }
}

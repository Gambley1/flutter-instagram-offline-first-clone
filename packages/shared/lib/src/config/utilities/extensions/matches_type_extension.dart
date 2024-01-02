extension MatchesTypeExtension<T> on T? {
  /// Returns true if the value is null or matches the given [value]
  /// otherwise returns false.
  bool isNullOrMatches(T value) => this == null || this == value;
}
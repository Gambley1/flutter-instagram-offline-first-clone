/// Extension on int that converts [int] to [bool].
extension IntToBool on int {
  /// Returns true if the value is 1 otherwise returns false.
  bool get isTrue => this == 1;
}

/// Extension on bool that converts [bool] to [int].
extension BoolToInt on bool {
  /// Returns 1 if the value is true otherwise returns 0.
  int get toInt => this == true ? 1 : 0;
}

extension IntToBool on int {
  bool get isTrue => this == 1;
}

extension BoolToInt on bool {
  int get toInt => this == true ? 1 : 0;
}

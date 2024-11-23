extension WordExt on String {
  bool isEqualTo(String other) => toLowerCase() == other.toLowerCase();
  bool doesContain(String other) => toLowerCase().contains(other.toLowerCase());
}

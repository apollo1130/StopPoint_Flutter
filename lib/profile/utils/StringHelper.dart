class StringHelper {
  static String puralize(String word, int count) {
    return count <= 1 ? word : word + 's';
  }
}

class CommonFunctions {
  String capitalizeFirstLetter(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1);
  }

  String calculatePercentageOfCartTotal(
      {required double cartTotalPrice, required double percentage}) {
    double value = cartTotalPrice * (percentage / 100);
    return value.toStringAsFixed(2);
  }
}

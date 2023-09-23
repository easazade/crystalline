/// ANSI escape code explanation
///
/// \x1B  [31m  Hello  \x1B  [0m
///
/// Meaning:
///
/// \x1B: ANSI escape sequence starting marker
/// [31m: Escape sequence for red
/// [0m: Escape sequence for reset (stop making the text red)
///
/// you can find code for all colors in below link
/// https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit
/// check the first table of colors, that shows different ANSI color code
/// appearance in different Operating Systems

String inRed(dynamic object) {
  return "\x1B[31m${object}\x1B[0m";
}

String inGreen(dynamic object) {
  return "\x1B[32m${object}\x1B[0m";
}

String inYellow(dynamic object) {
  return "\x1B[33m${object}\x1B[0m";
}

String inOrange(dynamic object) {
  return "\x1B[34m${object}\x1B[0m";
}

String inMagenta(dynamic object) {
  return "\x1B[35m${object}\x1B[0m";
}

String inCyan(dynamic object) {
  return "\x1B[36m${object}\x1B[0m";
}

String inWhite(dynamic object) {
  return "\x1B[37m${object}\x1B[0m";
}

String inReset(dynamic object) {
  return "\x1B[0m${object}\x1B[0m";
}

String inBlinking(dynamic object) {
  return "\x1B[5m${object}\x1B[0m";
}

String inBlinkingFast(dynamic object) {
  return "\x1B[6m${object}\x1B[0m";
}

/// prints all ANSI colors and effects that can be shown
/// this method is just for testing to see what colors/effects we can use
void printAllColorsAndEffects() {
  for (var i = 0; i < 110; i++) {
    print("$i -> \x1B[${i}m${'Hello'}\x1B[0m");
  }
}

String ellipsize(String text, {required int maxSize}) {
  if (text.length <= maxSize) {
    return text;
  } else {
    return '${text.substring(0, maxSize)}...';
  }
}

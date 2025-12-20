import 'package:flutter/material.dart';

class Console {
  static void red(String text) {
    debugPrint('\x1B[31m$text\x1B[0m');
  }

  static void green(String text) {
    debugPrint('\x1B[32m$text\x1B[0m');
  }

  static void yellow(String text) {
    debugPrint('\x1B[33m$text\x1B[0m');
  }

  static void blue(String text) {
    debugPrint('\x1B[34m$text\x1B[0m');
  }

  static void magenta(String text) {
    debugPrint('\x1B[35m$text\x1B[0m');
  }

  static void cyan(String text) {
    debugPrint('\x1B[36m$text\x1B[0m');
  }
}

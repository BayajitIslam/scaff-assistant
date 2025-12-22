import 'package:flutter/cupertino.dart';

class DynamicSize {
  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  // Predefined sizes for padding, margin, etc.
  static double small(BuildContext context) => screenHeight(context) * 0.01;
  static double medium(BuildContext context) => screenHeight(context) * 0.02;
  static double large(BuildContext context) => screenHeight(context) * 0.04;

  static double horizontalSmall(BuildContext context) =>
      screenWidth(context) * 0.01;
  static double horizontalMedium(BuildContext context) =>
      screenWidth(context) * 0.02;
  static double horizontalLarge(BuildContext context) =>
      screenWidth(context) * 0.04;
}

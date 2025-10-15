import 'dart:ui';

import 'package:flutter/src/painting/text_style.dart';
import 'package:google_fonts/google_fonts.dart';

import 'SColor.dart';

class STextTheme{

  static TextStyle headLine() {
    return TextStyle(
      fontFamily: 'LemonMilk',
      color: SColor.primary,
      fontSize: 16,
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle subHeadLine() {
    return GoogleFonts.roboto(
      color: SColor.textSecondary,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    );
  }

}
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/SColor.dart';
import '../../../core/theme/text_theme.dart';

class SFullBtn extends StatelessWidget {
  String text;
  VoidCallback onPressed;
  SFullBtn({
    required this.text,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: SColor.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          style: STextTheme.headLine(),
        ),
      ),
    );
  }
}
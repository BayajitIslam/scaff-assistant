import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/const/size_const/dynamic_size.dart';
import '../../../core/theme/text_theme.dart';

class SocialButton extends StatelessWidget {
  String text;
  String image;
  VoidCallback? onTap;
  SocialButton({
    required this.text,
    required this.image,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.all(DynamicSize.small(context)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(width: 20, image: AssetImage(image)),
            SizedBox(width: DynamicSize.horizontalMedium(context)),
            Text(text, style: STextTheme.subHeadLine()),
          ],
        ),
      ),
    );
  }
}

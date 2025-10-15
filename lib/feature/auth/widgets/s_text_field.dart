import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scaffassistant/core/theme/text_theme.dart';

import '../../../core/const/size_const/dynamic_size.dart';
import '../../../core/theme/SColor.dart';

class STextField extends StatefulWidget {
          String? hintText;
          String? labelText;
          TextEditingController? controller;
          bool? obscureText;
          TextInputType? keyboardType;
          Widget? prefixIcon;
          Widget? suffixIcon;
          Widget? changedSuffixIcon;
          STextField({
            super.key,
            this.hintText,
            this.labelText,
            this.controller,
            this.obscureText = false,
            this.keyboardType,
            this.prefixIcon,
            this.suffixIcon,
            this.changedSuffixIcon,
          });

          @override
          State<STextField> createState() => _STextFieldState();
        }

class _STextFieldState extends State<STextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText ?? false;
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: widget.hintText ?? '',
        label: Text(widget.labelText ?? ''),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon != null
            ? GestureDetector(
          onTap: _toggleObscureText,
          child: _obscureText
              ? widget.suffixIcon
              : widget.changedSuffixIcon ?? widget.suffixIcon,
        )
            : null,
        labelStyle: STextTheme.subHeadLine(),
        hintStyle: STextTheme.subHeadLine(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: SColor.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: SColor.borderColor),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: DynamicSize.horizontalMedium(context),
          vertical: DynamicSize.medium(context),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class InnerShadowContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final Color backgroundColor;
  final Color shadowColor;
  final EdgeInsetsGeometry? padding;
  final double shadowBlur;
  final double shadowSpread;

  const InnerShadowContainer({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.backgroundColor = Colors.white,
    this.shadowColor = Colors.black,
    this.padding,
    this.shadowBlur = 12,
    this.shadowSpread = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            // Content
            Padding(padding: padding ?? EdgeInsets.all(16), child: child),

            // Top shadow
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: shadowSpread,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      shadowColor.withOpacity(0.08),
                      shadowColor.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom shadow
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: shadowSpread,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      shadowColor.withOpacity(0.08),
                      shadowColor.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Left shadow
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              width: shadowSpread,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      shadowColor.withOpacity(0.08),
                      shadowColor.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Right shadow
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              width: shadowSpread,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      shadowColor.withOpacity(0.08),
                      shadowColor.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Corner shadows (top-left)
            Positioned(
              top: 0,
              left: 0,
              width: shadowSpread,
              height: shadowSpread,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.bottomRight,
                    radius: 1,
                    colors: [
                      shadowColor.withOpacity(0.0),
                      shadowColor.withOpacity(0.06),
                    ],
                  ),
                ),
              ),
            ),

            // Corner shadows (top-right)
            Positioned(
              top: 0,
              right: 0,
              width: shadowSpread,
              height: shadowSpread,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.bottomLeft,
                    radius: 1,
                    colors: [
                      shadowColor.withOpacity(0.0),
                      shadowColor.withOpacity(0.06),
                    ],
                  ),
                ),
              ),
            ),

            // Corner shadows (bottom-left)
            Positioned(
              bottom: 0,
              left: 0,
              width: shadowSpread,
              height: shadowSpread,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topRight,
                    radius: 1,
                    colors: [
                      shadowColor.withOpacity(0.0),
                      shadowColor.withOpacity(0.06),
                    ],
                  ),
                ),
              ),
            ),

            // Corner shadows (bottom-right)
            Positioned(
              bottom: 0,
              right: 0,
              width: shadowSpread,
              height: shadowSpread,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topLeft,
                    radius: 1,
                    colors: [
                      shadowColor.withOpacity(0.0),
                      shadowColor.withOpacity(0.06),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

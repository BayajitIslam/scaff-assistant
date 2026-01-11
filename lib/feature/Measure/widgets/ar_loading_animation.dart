import 'package:flutter/material.dart';
import 'dart:math' as math;

class ARLoadingAnimation extends StatefulWidget {
  final String message;

  const ARLoadingAnimation({super.key, this.message = 'Initializing AR...'});

  @override
  State<ARLoadingAnimation> createState() => _ARLoadingAnimationState();
}

class _ARLoadingAnimationState extends State<ARLoadingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Rotation animation
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // Scale/pulse animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 3D Animated Cube
            AnimatedBuilder(
              animation: Listenable.merge([
                _rotationController,
                _scaleController,
              ]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateX(_rotationController.value * 2 * math.pi * 0.5)
                      ..rotateY(_rotationController.value * 2 * math.pi),
                    child: _build3DCube(),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            // Loading text with dots animation
            _buildLoadingText(),
          ],
        ),
      ),
    );
  }

  Widget _build3DCube() {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        children: [
          // Front face
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          // Back face (offset)
          Positioned(
            left: 15,
            top: -15,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          // Connecting lines
          CustomPaint(size: const Size(100, 100), painter: _CubeLinesPainter()),
        ],
      ),
    );
  }

  Widget _buildLoadingText() {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: 3),
      duration: const Duration(milliseconds: 1500),
      builder: (context, value, child) {
        String dots = '.' * (value % 4);
        return Text(
          '${widget.message}$dots',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        );
      },
      onEnd: () {
        // Restart animation
        setState(() {});
      },
    );
  }
}

class _CubeLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Connect corners
    canvas.drawLine(const Offset(0, 0), const Offset(15, -15), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width + 15, -15), paint);
    canvas.drawLine(
      Offset(0, size.height),
      Offset(15, size.height - 15),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width + 15, size.height - 15),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

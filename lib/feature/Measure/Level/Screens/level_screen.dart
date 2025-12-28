import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class LevelView extends StatefulWidget {
  const LevelView({super.key});

  @override
  State<LevelView> createState() => _LevelViewState();
}

class _LevelViewState extends State<LevelView>
    with SingleTickerProviderStateMixin {
  // Constants
  static const _greenColor = Color(0xFF4CAF50);
  static const _redColor = Color(0xFFE53935);
  static const _bubbleSize = 150.0;
  static const _bubbleRadius = _bubbleSize / 2;
  static const _smoothingFactor = 0.12;

  // State
  double _x = 0, _y = 0, _z = 0;
  double _targetX = 0, _targetY = 0, _targetZ = 0;

  bool _isLoading = true;
  String? _error;

  StreamSubscription<AccelerometerEvent>? _sensorSubscription;
  Timer? _smoothingTimer;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Computed
  bool get _isFlat => _z.abs() > 7.0;

  double get _absoluteAngle {
    if (_isFlat) return sqrt(_x * _x + _y * _y);
    return (atan2(_x, _y.abs()) * (180 / pi)).abs();
  }

  double get _signedAngle {
    if (_isFlat) return _absoluteAngle;
    return atan2(_x, _y.abs()) * (180 / pi);
  }

  bool get _isPerfectLevel => _signedAngle.round() == 0;
  bool get _showBubbles => _absoluteAngle > 1;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _initSensor();
    _startSmoothingLoop();
  }

  @override
  void dispose() {
    _sensorSubscription?.cancel();
    _smoothingTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _setupAnimation() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initSensor() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      _sensorSubscription =
          accelerometerEventStream(
            samplingPeriod: const Duration(milliseconds: 20),
          ).listen(
            (event) {
              _targetX = event.x;
              _targetY = event.y;
              _targetZ = event.z;
              if (_isLoading && mounted) {
                setState(() => _isLoading = false);
              }
            },
            onError: (e) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _error = e.toString();
                });
              }
            },
          );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  void _startSmoothingLoop() {
    _smoothingTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (mounted) {
        setState(() {
          _x += (_targetX - _x) * _smoothingFactor;
          _y += (_targetY - _y) * _smoothingFactor;
          _z += (_targetZ - _z) * _smoothingFactor;
        });
      }
    });
  }

  void _retry() {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    _initSensor();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoading();
    if (_error != null) return _buildError();
    return _buildLevelView();
  }

  Widget _buildLoading() {
    return Container(
      color: _greenColor,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
            SizedBox(height: 20),
            Text(
              'Calibrating...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      color: _greenColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.sensors_off_rounded,
                size: 64,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              const Text(
                'Sensor Unavailable',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _retry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final center = Offset(
          constraints.maxWidth / 2,
          constraints.maxHeight / 2,
        );

        return Stack(
          children: [
            // Dynamic background
            _buildDynamicBackground(constraints),

            // Bubbles
            if (_showBubbles) _buildClippedBubbles(center, constraints),

            // Main circle with angle text inside
            _buildMainCircleWithAngle(center),
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DYNAMIC BACKGROUND
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildDynamicBackground(BoxConstraints constraints) {
    final absAngle = _absoluteAngle;

    // Full GREEN (0° - 5°)
    if (absAngle <= 5) {
      return Container(color: _greenColor);
    }

    // Full RED (15°+)
    if (absAngle >= 15) {
      return Container(color: _redColor);
    }

    // Dynamic split: 5° - 15° (white grows from 0% to 30%)
    final whiteRatio = ((absAngle - 5) / 10 * 0.3).clamp(0.0, 0.3);
    final greenRatio = 1.0 - whiteRatio;

    return Column(
      children: [
        Expanded(
          flex: (whiteRatio * 100).round().clamp(1, 99),
          child: Container(color: Colors.white),
        ),
        Expanded(
          flex: (greenRatio * 100).round().clamp(1, 99),
          child: Container(color: _greenColor),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MAIN CIRCLE WITH ANGLE TEXT CENTERED INSIDE
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildMainCircleWithAngle(Offset center) {
    final angle = _signedAngle.round();

    return Positioned(
      left: center.dx - _bubbleRadius,
      top: center.dy - _bubbleRadius,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          final scale = _isPerfectLevel ? _pulseAnimation.value : 1.0;
          return Transform.scale(
            scale: scale,
            child: Container(
              width: _bubbleSize,
              height: _bubbleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.9),
                  width: 3,
                ),
                boxShadow: _isPerfectLevel
                    ? [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ]
                    : null,
              ),
              // Angle text centered inside circle
              child: Center(
                child: Text(
                  '$angle°',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CLIPPED BUBBLES
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildClippedBubbles(Offset center, BoxConstraints constraints) {
    final angle = _signedAngle;
    final absAngle = _absoluteAngle;

    final t = absAngle / 25;
    final verticalOffset = t * constraints.maxHeight * 0.55;
    final horizontalOffset = (angle / 25) * constraints.maxWidth * 0.6;

    final topBubble = Offset(
      center.dx + horizontalOffset,
      center.dy - verticalOffset,
    );
    final bottomBubble = Offset(
      center.dx - horizontalOffset,
      center.dy + verticalOffset,
    );

    return ClipPath(
      clipper: _CircleClipOut(center: center, radius: _bubbleRadius),
      child: Stack(
        clipBehavior: Clip.none,
        children: [_buildBubbleAt(topBubble), _buildBubbleAt(bottomBubble)],
      ),
    );
  }

  Widget _buildBubbleAt(Offset position) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      left: position.dx - _bubbleRadius,
      top: position.dy - _bubbleRadius,
      child: Container(
        width: _bubbleSize,
        height: _bubbleSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CLIPPER
// ═══════════════════════════════════════════════════════════════════════════

class _CircleClipOut extends CustomClipper<Path> {
  final Offset center;
  final double radius;

  _CircleClipOut({required this.center, required this.radius});

  @override
  Path getClip(Size size) {
    return Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(_CircleClipOut old) =>
      center != old.center || radius != old.radius;
}

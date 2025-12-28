import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';
import 'package:scaffassistant/core/utils/console.dart';
import 'package:scaffassistant/feature/Measure/services/ar_measurement_service.dart';

class MeasureView extends StatefulWidget {
  const MeasureView({super.key});

  @override
  State<MeasureView> createState() => _MeasureViewState();
}

class _MeasureViewState extends State<MeasureView> {
  ArMeasurementService? _arService;

  bool _isReady = false;
  bool _planeDetected = false;
  bool _permissionDenied = false;
  String _statusMessage = 'Initializing AR...';
  int _pointCount = 0;
  double? _currentDistance;

  @override
  void initState() {
    super.initState();
    _initAR();
  }

  Future<void> _initAR() async {
    // ═══════════════════════════════════════════════════════════════
    // Step 1: Request Camera Permission
    // ═══════════════════════════════════════════════════════════════
    final cameraStatus = await Permission.camera.request();

    if (cameraStatus.isDenied) {
      if (mounted) {
        setState(() {
          _permissionDenied = true;
          _statusMessage = 'Camera permission required for AR';
        });
      }
      return;
    }

    if (cameraStatus.isPermanentlyDenied) {
      if (mounted) {
        setState(() {
          _permissionDenied = true;
          _statusMessage = 'Please enable camera in Settings';
        });
      }
      return;
    }

    // ═══════════════════════════════════════════════════════════════
    // Step 2: Initialize AR Service
    // ═══════════════════════════════════════════════════════════════
    _arService = ArMeasurementService();

    _arService!.onPlaneDetected = (detected) {
      if (mounted) {
        setState(() {
          _planeDetected = detected;
          if (detected && _pointCount == 0) {
            _statusMessage = 'Tap + to add first point';
          }
        });
      }
    };

    _arService!.onHitTestFailed = (message) {
      if (mounted) {
        setState(() {
          _statusMessage = message;
        });

        // Reset message after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && _planeDetected) {
            setState(() {
              _statusMessage = _pointCount == 0
                  ? 'Tap + to add first point'
                  : 'Tap + to continue measuring';
            });
          }
        });
      }
    };

    _arService!.onPointAdded = (position) {
      if (mounted) {
        setState(() {
          _pointCount++;
          _statusMessage = _pointCount == 1
              ? 'Move & tap + for second point'
              : 'Tap + to continue measuring';
        });
      }
    };

    _arService!.onDistanceCalculated = (distance) {
      if (mounted) {
        setState(() {
          _currentDistance = distance;
        });
      }
    };

    _arService!.onPointCount = (count) {
      if (mounted) {
        setState(() {
          _pointCount = count;
          if (count < 2) _currentDistance = null;
          if (count == 0) {
            _statusMessage = 'Tap + to add first point';
          }
        });
      }
    };

    _arService!.onError = (error) {
      if (mounted) {
        setState(() {
          _statusMessage = error;
        });
      }
    };

    // Small delay to let platform view initialize
    await Future.delayed(const Duration(milliseconds: 500));

    final success = await _arService!.initialize();
    if (mounted) {
      setState(() {
        _isReady = success;
        _statusMessage = success
            ? 'Move device to detect surface'
            : 'AR not available on this device';
      });
    }
  }

  Future<void> _openSettings() async {
    await openAppSettings();
  }

  @override
  void dispose() {
    _arService?.dispose();
    super.dispose();
  }

  void _addPoint() {
    if (!_planeDetected) return;
    HapticFeedback.mediumImpact();
    _arService?.addPoint();
  }

  void _undo() {
    if (_pointCount == 0) return;
    HapticFeedback.lightImpact();
    _arService?.undo();
  }

  void _clear() {
    if (_pointCount == 0) return;
    HapticFeedback.mediumImpact();
    _arService?.clear();
  }

  Future<void> _takeScreenshot() async {
    HapticFeedback.mediumImpact();
    final Uint8List? image = await _arService?.takeSnapshot();
    if (image != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Screenshot captured!')));
    }
  }

  String _formatDistanceMetric(double meters) {
    if (meters < 0.01) return '${(meters * 1000).toStringAsFixed(1)} mm';
    if (meters < 1) return '${(meters * 100).toStringAsFixed(1)} cm';
    return '${meters.toStringAsFixed(2)} m';
  }

  String _formatDistanceImperial(double meters) {
    final inches = meters / 0.0254;
    if (inches < 12) {
      final whole = inches.floor();
      final frac = inches - whole;
      if (frac >= 0.875) return '${whole + 1}"';
      if (frac >= 0.625) return '$whole¾"';
      if (frac >= 0.375) return '$whole½"';
      if (frac >= 0.125) return '$whole¼"';
      return '$whole"';
    }
    final feet = (inches / 12).floor();
    final rem = (inches % 12).round();
    return "$feet' $rem\"";
  }

  @override
  Widget build(BuildContext context) {
    // Show permission denied screen
    if (_permissionDenied) {
      return _buildPermissionDeniedScreen();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Native AR View
        _buildARView(),

        // Crosshair
        _buildCrosshair(),

        // Status message
        _buildStatusMessage(),

        // Distance display
        if (_currentDistance != null) _buildDistanceDisplay(),

        // Top controls
        _buildTopControls(),

        // Bottom controls
        _buildBottomControls(),
      ],
    );
  }

  Widget _buildPermissionDeniedScreen() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 80,
                color: Colors.white.withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              const Text(
                'Camera Permission Required',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'To use the AR measurement tool, please allow camera access.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _openSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Open Settings',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _permissionDenied = false;
                  });
                  _initAR();
                },
                child: Text(
                  'Try Again',
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildARView() {
    if (Platform.isAndroid) {
      return const AndroidView(
        viewType: 'ar_measurement_view_android',
        creationParamsCodec: StandardMessageCodec(),
      );
    } else if (Platform.isIOS) {
      return const UiKitView(
        viewType: 'ar_measurement_view_ios',
        creationParamsCodec: StandardMessageCodec(),
      );
    } else {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Text(
            'AR not supported on this platform',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  Widget _buildCrosshair() {
    return Center(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _isReady ? 1.0 : 0.5,
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(shape: BoxShape.circle),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _planeDetected
                      ? Colors.green
                      : AppColors.background.withOpacity(0.9),
                  boxShadow: _planeDetected
                      ? [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
              ),
              // Positioned(top: 20, child: _line(true)),
              // Positioned(bottom: 20, child: _line(true)),
              // Positioned(left: 20, child: _line(false)),
              // Positioned(right: 20, child: _line(false)),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _line(bool vertical) => Container(
  //   width: vertical ? 1.5 : 15,
  //   height: vertical ? 15 : 1.5,
  //   color: Colors.white.withOpacity(0.7),
  // );

  Widget _buildStatusMessage() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 80,
      left: 20,
      right: 20,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            _statusMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDistanceDisplay() {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.32,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.keyboard_arrow_up,
                    color: Colors.grey.shade500,
                    size: 16,
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey.shade500,
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Text(
                _formatDistanceImperial(_currentDistance!),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${_formatDistanceMetric(_currentDistance!)})',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopControls() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildControlButton(
            icon: Icons.undo_rounded,
            onTap: _undo,
            enabled: _pointCount > 0,
          ),
          _buildControlButton(
            weight: 80,
            height: 50,
            isText: true,
            icon: Icons.delete_outline_rounded,
            onTap: _clear,
            text: 'CLEAR',
            enabled: _pointCount > 0,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    bool enabled = true,
    bool isText = false,
    String text = '',
    double height = 50,
    double weight = 50,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1.0 : 0.4,
        child: Container(
          width: weight,
          height: height,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: isText
              ? Center(
                  child: Text(
                    text,
                    style: AppTextStyles.headLine().copyWith(
                      color: AppColors.textWhite,
                    ),
                  ),
                )
              : Icon(icon, color: AppColors.background, size: 24),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: () {
              Console.info(
                "Button tapped! planeDetected: $_planeDetected",
              ); // Debug
              if (_planeDetected) {
                _addPoint();
              }
            },
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _planeDetected ? 1.0 : 0.5,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.6),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 36),
              ),
            ),
          ),

          Positioned(
            right: 50,
            child: GestureDetector(
              onTap: _takeScreenshot,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.chatUserBubble,
                  border: Border.all(color: AppColors.background, width: 4),
                ),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black.withOpacity(0.1),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

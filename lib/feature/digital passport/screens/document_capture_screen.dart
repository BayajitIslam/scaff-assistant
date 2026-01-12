import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';

/// Document capture mode
enum CaptureMode { card, a4Document }

class DocumentCaptureScreen extends StatefulWidget {
  final String initialSide;
  final Function(File imageFile, String side, CaptureMode mode) onImageCaptured;
  final CaptureMode initialMode;

  const DocumentCaptureScreen({
    super.key,
    this.initialSide = 'front',
    required this.onImageCaptured,
    this.initialMode = CaptureMode.card,
  });

  @override
  State<DocumentCaptureScreen> createState() => _DocumentCaptureScreenState();
}

class _DocumentCaptureScreenState extends State<DocumentCaptureScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isCapturing = false;
  bool _isFlashOn = false;
  int _currentCameraIndex = 0;

  late String _currentSide;
  late CaptureMode _captureMode;

  @override
  void initState() {
    super.initState();
    _currentSide = widget.initialSide;
    _captureMode = widget.initialMode;
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        _showError('No camera available');
        return;
      }
      await _setupCamera(_cameras![_currentCameraIndex]);
    } catch (e) {
      _showError('Failed to initialize camera');
    }
  }

  Future<void> _setupCamera(CameraDescription camera) async {
    if (_cameraController != null) await _cameraController!.dispose();

    _cameraController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _cameraController!.initialize();
      if (mounted) setState(() => _isInitialized = true);
    } catch (e) {
      _showError('Failed to setup camera');
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null) return;
    try {
      await _cameraController!.setFlashMode(
        _isFlashOn ? FlashMode.off : FlashMode.torch,
      );
      setState(() => _isFlashOn = !_isFlashOn);
    } catch (e) {
      debugPrint('Flash error: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;
    setState(() {
      _isInitialized = false;
      _currentCameraIndex = (_currentCameraIndex + 1) % _cameras!.length;
    });
    await _setupCamera(_cameras![_currentCameraIndex]);
  }

  bool get _isA4 => _captureMode == CaptureMode.a4Document;

  _FrameDimensions _getFrameDimensions(Size screenSize) {
    final sw = screenSize.width;
    final sh = screenSize.height;

    if (_isA4) {
      // A4 Portrait ratio (1:1.414)
      final maxH = sh * 0.55;
      var h = maxH;
      var w = h / 1.414;
      if (w > sw - 40) {
        w = sw - 40;
        h = w * 1.414;
      }
      return _FrameDimensions(
        left: (sw - w) / 2,
        top: sh * 0.22,
        width: w,
        height: h,
      );
    } else {
      // Card ratio (wider)
      final w = sw - 48;
      final h = w * 0.63;
      return _FrameDimensions(left: 24, top: sh * 0.32, width: w, height: h);
    }
  }

  Future<File> _cropToFrame(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final original = img.decodeImage(bytes);
      if (original == null) return imageFile;

      final screen = MediaQuery.of(context).size;
      final frame = _getFrameDimensions(screen);

      final imgW = original.width;
      final imgH = original.height;

      final previewRatio = imgW / imgH;
      final screenRatio = screen.width / screen.height;

      double scale, offX = 0, offY = 0;
      if (previewRatio > screenRatio) {
        scale = imgH / screen.height;
        offX = (imgW - screen.width * scale) / 2;
      } else {
        scale = imgW / screen.width;
        offY = (imgH - screen.height * scale) / 2;
      }

      var cropX = (offX + frame.left * scale).round().clamp(0, imgW - 1);
      var cropY = (offY + frame.top * scale).round().clamp(0, imgH - 1);
      var cropW = (frame.width * scale).round().clamp(1, imgW - cropX);
      var cropH = (frame.height * scale).round().clamp(1, imgH - cropY);

      final cropped = img.copyCrop(
        original,
        x: cropX,
        y: cropY,
        width: cropW,
        height: cropH,
      );
      final croppedBytes = Uint8List.fromList(
        img.encodeJpg(cropped, quality: 95),
      );

      final dir = await getTemporaryDirectory();
      final prefix = _isA4 ? 'a4' : 'card';
      final file = File(
        '${dir.path}/doc_${prefix}_${_currentSide}_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await file.writeAsBytes(croppedBytes);

      try {
        await imageFile.delete();
      } catch (_) {}
      return file;
    } catch (e) {
      debugPrint('Crop error: $e');
      return imageFile;
    }
  }

  Future<void> _capture() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isCapturing)
      return;

    setState(() => _isCapturing = true);

    try {
      if (_isFlashOn) await _cameraController!.setFlashMode(FlashMode.off);

      final xFile = await _cameraController!.takePicture();
      var file = File(xFile.path);
      file = await _cropToFrame(file);

      widget.onImageCaptured(file, _currentSide, _captureMode);
      if (mounted) Get.back();
    } catch (e) {
      _showError('Capture failed');
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  void _showError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final frame = _getFrameDimensions(screen);
    final safeTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          if (_isInitialized && _cameraController != null)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: screen.width,
                  height: screen.width * _cameraController!.value.aspectRatio,
                  child: CameraPreview(_cameraController!),
                ),
              ),
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          // Dark Overlay with Frame Cutout
          Positioned.fill(
            child: CustomPaint(
              painter: _FramePainter(frame: frame, isA4: _isA4),
            ),
          ),

          // Corner Brackets
          ..._buildCorners(frame),

          // Top Bar: Close & Flash
          Positioned(
            top: safeTop + 12,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _IconBtn(icon: Icons.close, onTap: () => Get.back()),
                _IconBtn(
                  icon: _isFlashOn ? Icons.flash_on : Icons.flash_off,
                  onTap: _toggleFlash,
                  active: _isFlashOn,
                ),
              ],
            ),
          ),

          // Mode Toggle (Card / A4)
          Positioned(
            top: safeTop + 70,
            left: 0,
            right: 0,
            child: Center(child: _buildModeToggle()),
          ),

          // Side Toggle (Front/Back) - Card mode only
          if (!_isA4)
            Positioned(
              top: safeTop + 130,
              left: 0,
              right: 0,
              child: Center(child: _buildSideToggle()),
            ),

          // Bottom: Capture Button & Camera Switch
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 30,
            left: 0,
            right: 0,
            child: _buildBottomBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ModeBtn(
            label: 'Card',
            icon: Icons.credit_card,
            selected: !_isA4,
            color: AppColors.primary,
            onTap: () => setState(() {
              _captureMode = CaptureMode.card;
              _currentSide = 'front';
            }),
          ),
          _ModeBtn(
            label: 'A4',
            icon: Icons.description,
            selected: _isA4,
            color: Colors.blue,
            onTap: () => setState(() {
              _captureMode = CaptureMode.a4Document;
              _currentSide = 'front';
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSideToggle() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SideBtn(
            label: 'FRONT',
            selected: _currentSide == 'front',
            onTap: () => setState(() => _currentSide = 'front'),
          ),
          _SideBtn(
            label: 'BACK',
            selected: _currentSide == 'back',
            onTap: () => setState(() => _currentSide = 'back'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Camera Switch
        _IconBtn(icon: Icons.flip_camera_ios, onTap: _switchCamera, size: 50),

        // Capture Button
        GestureDetector(
          onTap: _isCapturing ? null : _capture,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
            ),
            padding: const EdgeInsets.all(4),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isCapturing
                    ? Colors.grey
                    : (_isA4 ? Colors.blue : AppColors.primary),
              ),
              child: _isCapturing
                  ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.camera_alt,
                      color: _isA4 ? Colors.white : Colors.black,
                      size: 28,
                    ),
            ),
          ),
        ),

        // Placeholder for symmetry
        const SizedBox(width: 50),
      ],
    );
  }

  List<Widget> _buildCorners(_FrameDimensions f) {
    final color = _isA4 ? Colors.blue : AppColors.primary;
    const size = 28.0;
    const stroke = 3.0;

    Widget corner(Alignment align) {
      return Positioned(
        left: align == Alignment.topLeft || align == Alignment.bottomLeft
            ? f.left - 2
            : null,
        right: align == Alignment.topRight || align == Alignment.bottomRight
            ? MediaQuery.of(context).size.width - f.left - f.width - 2
            : null,
        top: align == Alignment.topLeft || align == Alignment.topRight
            ? f.top - 2
            : null,
        bottom: align == Alignment.bottomLeft || align == Alignment.bottomRight
            ? MediaQuery.of(context).size.height - f.top - f.height - 2
            : null,
        child: CustomPaint(
          size: const Size(size, size),
          painter: _CornerPainter(align: align, color: color, stroke: stroke),
        ),
      );
    }

    return [
      corner(Alignment.topLeft),
      corner(Alignment.topRight),
      corner(Alignment.bottomLeft),
      corner(Alignment.bottomRight),
    ];
  }
}

// ════════════════════════════════════════════════════════════════════════════
// WIDGETS
// ════════════════════════════════════════════════════════════════════════════

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  final double size;

  const _IconBtn({
    required this.icon,
    required this.onTap,
    this.active = false,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.black38,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: active ? Colors.black : Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }
}

class _ModeBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _ModeBtn({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? Colors.white : Colors.white60,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white60,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SideBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SideBtn({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white60,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// PAINTERS
// ════════════════════════════════════════════════════════════════════════════

class _FrameDimensions {
  final double left, top, width, height;
  _FrameDimensions({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
}

class _FramePainter extends CustomPainter {
  final _FrameDimensions frame;
  final bool isA4;

  _FramePainter({required this.frame, required this.isA4});

  @override
  void paint(Canvas canvas, Size size) {
    // Dark overlay
    final overlay = Paint()..color = Colors.black.withOpacity(0.6);
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final frameRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(frame.left, frame.top, frame.width, frame.height),
      Radius.circular(isA4 ? 4 : 10),
    );

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(fullRect),
        Path()..addRRect(frameRect),
      ),
      overlay,
    );

    // Frame border
    final border = Paint()
      ..color = (isA4 ? Colors.blue : Colors.white).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(frameRect, border);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CornerPainter extends CustomPainter {
  final Alignment align;
  final Color color;
  final double stroke;

  _CornerPainter({
    required this.align,
    required this.color,
    required this.stroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    const r = 6.0;

    if (align == Alignment.topLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, r);
      path.quadraticBezierTo(0, 0, r, 0);
      path.lineTo(size.width, 0);
    } else if (align == Alignment.topRight) {
      path.moveTo(0, 0);
      path.lineTo(size.width - r, 0);
      path.quadraticBezierTo(size.width, 0, size.width, r);
      path.lineTo(size.width, size.height);
    } else if (align == Alignment.bottomLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height - r);
      path.quadraticBezierTo(0, size.height, r, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width - r, size.height);
      path.quadraticBezierTo(
        size.width,
        size.height,
        size.width,
        size.height - r,
      );
      path.lineTo(size.width, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

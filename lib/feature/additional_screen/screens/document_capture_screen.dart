import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
class DocumentCaptureScreen extends StatefulWidget {
  final String initialSide; // 'front' or 'back'
  final Function(File imageFile, String side) onImageCaptured;

  const DocumentCaptureScreen({
    super.key,
    this.initialSide = 'front',
    required this.onImageCaptured,
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

  // Current capture side
  late String _currentSide;

  // Frame key for getting exact position
  final GlobalKey _frameKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _currentSide = widget.initialSide;
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

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
      _showError('Failed to initialize camera: $e');
    }
  }

  Future<void> _setupCamera(CameraDescription camera) async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
    }

    _cameraController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      _showError('Failed to setup camera: $e');
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null) return;

    try {
      if (_isFlashOn) {
        await _cameraController!.setFlashMode(FlashMode.off);
      } else {
        await _cameraController!.setFlashMode(FlashMode.torch);
      }
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      debugPrint('Flash toggle error: $e');
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

  // Toggle between front and back capture
  void _toggleSide() {
    setState(() {
      _currentSide = _currentSide == 'front' ? 'back' : 'front';
    });
  }

  // Crop image to document frame area
  Future<File> _cropToDocumentFrame(File imageFile) async {
    try {
      // Read image bytes
      final Uint8List bytes = await imageFile.readAsBytes();
      img.Image? originalImage = img.decodeImage(bytes);

      if (originalImage == null) {
        debugPrint('Failed to decode image');
        return imageFile;
      }

      // Get screen dimensions
      final screenSize = MediaQuery.of(context).size;
      final screenWidth = screenSize.width;
      final screenHeight = screenSize.height;

      // Frame dimensions (same as in build method)
      final double frameWidth = screenWidth - 48;
      final double frameHeight = frameWidth * 0.63;
      final double frameLeft = 24;
      final double frameTop = screenHeight * 0.28;

      // Image dimensions
      final int imageWidth = originalImage.width;
      final int imageHeight = originalImage.height;

      // Camera preview fills the screen (cover mode)
      // Calculate how the image maps to screen
      double previewAspectRatio = imageWidth / imageHeight;
      double screenAspectRatio = screenWidth / screenHeight;

      double scaleX, scaleY;
      double offsetX = 0, offsetY = 0;

      if (previewAspectRatio > screenAspectRatio) {
        // Image is wider - height fits, width is cropped
        scaleY = imageHeight / screenHeight;
        scaleX = scaleY;
        offsetX = (imageWidth - (screenWidth * scaleX)) / 2;
      } else {
        // Image is taller - width fits, height is cropped
        scaleX = imageWidth / screenWidth;
        scaleY = scaleX;
        offsetY = (imageHeight - (screenHeight * scaleY)) / 2;
      }

      // Calculate crop coordinates in image space
      int cropX = (offsetX + (frameLeft * scaleX)).round();
      int cropY = (offsetY + (frameTop * scaleY)).round();
      int cropWidth = (frameWidth * scaleX).round();
      int cropHeight = (frameHeight * scaleY).round();

      // Clamp values to image bounds
      cropX = cropX.clamp(0, imageWidth - 1);
      cropY = cropY.clamp(0, imageHeight - 1);
      cropWidth = cropWidth.clamp(1, imageWidth - cropX);
      cropHeight = cropHeight.clamp(1, imageHeight - cropY);

      debugPrint('Image: ${imageWidth}x${imageHeight}');
      debugPrint('Screen: ${screenWidth}x${screenHeight}');
      debugPrint(
        'Frame: ${frameWidth}x${frameHeight} at ($frameLeft, $frameTop)',
      );
      debugPrint('Crop: ${cropWidth}x${cropHeight} at ($cropX, $cropY)');

      // Crop the image
      img.Image croppedImage = img.copyCrop(
        originalImage,
        x: cropX,
        y: cropY,
        width: cropWidth,
        height: cropHeight,
      );

      // Encode to JPEG
      final Uint8List croppedBytes = Uint8List.fromList(
        img.encodeJpg(croppedImage, quality: 90),
      );

      // Save to new file
      final directory = await getTemporaryDirectory();
      final String fileName =
          'doc_${_currentSide}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File croppedFile = File('${directory.path}/$fileName');
      await croppedFile.writeAsBytes(croppedBytes);

      // Delete original
      try {
        await imageFile.delete();
      } catch (e) {
        debugPrint('Could not delete original: $e');
      }

      return croppedFile;
    } catch (e) {
      debugPrint('Error cropping image: $e');
      return imageFile;
    }
  }

  Future<void> _captureImage() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      // Turn off flash for capture
      if (_isFlashOn) {
        await _cameraController!.setFlashMode(FlashMode.off);
      }

      final XFile image = await _cameraController!.takePicture();
      File imageFile = File(image.path);

      // Crop to document frame
      imageFile = await _cropToDocumentFrame(imageFile);

      // Call callback with cropped image and side
      widget.onImageCaptured(imageFile, _currentSide);

      // Go back
      if (mounted) {
        Get.back();
      }
    } catch (e) {
      _showError('Failed to capture image: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  String get _title =>
      _currentSide == 'front' ? 'Capture Front' : 'Capture Back';
  String get _subtitle => _currentSide == 'front'
      ? 'Position the FRONT of your document'
      : 'Position the BACK of your document';

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double frameWidth = screenSize.width - 48;
    final double frameHeight = frameWidth * 0.63;
    final double frameLeft = 24;
    final double frameTop = screenSize.height * 0.28;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          if (_isInitialized && _cameraController != null)
            Positioned.fill(
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: screenSize.width,
                      height:
                          screenSize.width *
                          _cameraController!.value.aspectRatio,
                      child: CameraPreview(_cameraController!),
                    ),
                  ),
                ),
              ),
            )
          else
            Center(child: CircularProgressIndicator(color: AppColors.primary)),

          // Document Frame Overlay
          Positioned.fill(
            child: CustomPaint(
              key: _frameKey,
              painter: DocumentFramePainter(
                frameLeft: frameLeft,
                frameTop: frameTop,
                frameWidth: frameWidth,
                frameHeight: frameHeight,
              ),
            ),
          ),

          // Top Bar
          _buildTopBar(),

          // Side Toggle & Instructions
          Positioned(
            top: MediaQuery.of(context).padding.top + 70,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // Side Toggle Buttons
                _buildSideToggle(),
                SizedBox(height: 12),
                // Instructions
                _buildInstructions(),
              ],
            ),
          ),

          // Corner Guides
          _buildCornerGuides(frameLeft, frameTop, frameWidth, frameHeight),

          // Bottom Controls
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16,
          right: 16,
          bottom: 10,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Close Button
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: Colors.white, size: 24),
              ),
            ),

            // Title
            Text(
              _title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            // Flash Toggle
            GestureDetector(
              onTap: _toggleFlash,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isFlashOn
                      ? AppColors.primary.withOpacity(0.8)
                      : Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isFlashOn ? Icons.flash_on : Icons.flash_off,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideToggle() {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Front Button
          GestureDetector(
            onTap: () {
              if (_currentSide != 'front') _toggleSide();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: _currentSide == 'front'
                    ? AppColors.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                'FRONT',
                style: TextStyle(
                  color: _currentSide == 'front' ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          // Back Button
          GestureDetector(
            onTap: () {
              if (_currentSide != 'back') _toggleSide();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: _currentSide == 'back'
                    ? AppColors.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                'BACK',
                style: TextStyle(
                  color: _currentSide == 'back' ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _subtitle,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildCornerGuides(
    double frameLeft,
    double frameTop,
    double frameWidth,
    double frameHeight,
  ) {
    return Stack(
      children: [
        // Top Left
        Positioned(
          left: frameLeft - 2,
          top: frameTop - 2,
          child: _buildCorner(isTop: true, isLeft: true),
        ),
        // Top Right
        Positioned(
          right: frameLeft - 2,
          top: frameTop - 2,
          child: _buildCorner(isTop: true, isLeft: false),
        ),
        // Bottom Left
        Positioned(
          left: frameLeft - 2,
          top: frameTop + frameHeight - 38,
          child: _buildCorner(isTop: false, isLeft: true),
        ),
        // Bottom Right
        Positioned(
          right: frameLeft - 2,
          top: frameTop + frameHeight - 38,
          child: _buildCorner(isTop: false, isLeft: false),
        ),
      ],
    );
  }

  Widget _buildCorner({required bool isTop, required bool isLeft}) {
    return SizedBox(
      width: 40,
      height: 40,
      child: CustomPaint(
        painter: CornerPainter(
          isTop: isTop,
          isLeft: isLeft,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          left: 30,
          right: 30,
          bottom: MediaQuery.of(context).padding.bottom + 30,
          top: 30,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.8), Colors.transparent],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Cancel/Back Button
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(Icons.arrow_back, color: Colors.white, size: 24),
              ),
            ),

            // Capture Button
            GestureDetector(
              onTap: _isCapturing ? null : _captureImage,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: Container(
                  margin: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isCapturing ? Colors.grey : AppColors.primary,
                  ),
                  child: _isCapturing
                      ? Center(
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.camera_alt,
                          color: AppColors.textBlackPrimary,
                          size: 32,
                        ),
                ),
              ),
            ),

            // Switch Camera Button
            GestureDetector(
              onTap: _switchCamera,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.flip_camera_ios_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Document Frame Overlay Painter
class DocumentFramePainter extends CustomPainter {
  final double frameLeft;
  final double frameTop;
  final double frameWidth;
  final double frameHeight;

  DocumentFramePainter({
    required this.frameLeft,
    required this.frameTop,
    required this.frameWidth,
    required this.frameHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    // Draw overlay with cutout
    final Path overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final RRect frameRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(frameLeft, frameTop, frameWidth, frameHeight),
      Radius.circular(12),
    );

    final Path framePath = Path()..addRRect(frameRect);

    final Path combinedPath = Path.combine(
      PathOperation.difference,
      overlayPath,
      framePath,
    );

    canvas.drawPath(combinedPath, overlayPaint);

    // Draw frame border
    final Paint borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(frameRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Corner Guide Painter
class CornerPainter extends CustomPainter {
  final bool isTop;
  final bool isLeft;
  final Color color;

  CornerPainter({
    required this.isTop,
    required this.isLeft,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final Path path = Path();

    if (isTop && isLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 8);
      path.quadraticBezierTo(0, 0, 8, 0);
      path.lineTo(size.width, 0);
    } else if (isTop && !isLeft) {
      path.moveTo(0, 0);
      path.lineTo(size.width - 8, 0);
      path.quadraticBezierTo(size.width, 0, size.width, 8);
      path.lineTo(size.width, size.height);
    } else if (!isTop && isLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height - 8);
      path.quadraticBezierTo(0, size.height, 8, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width - 8, size.height);
      path.quadraticBezierTo(
        size.width,
        size.height,
        size.width,
        size.height - 8,
      );
      path.lineTo(size.width, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

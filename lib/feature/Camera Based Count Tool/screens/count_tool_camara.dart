import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/instance_manager.dart';
import 'package:image/image.dart' as img;
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';
import 'package:scaffassistant/core/utils/console.dart';
import 'package:scaffassistant/feature/Camera%20Based%20Count%20Tool/widgets/crop_frame_overlay.dart';
import 'package:scaffassistant/routing/route_name.dart';

class CountToolCamara extends StatefulWidget {
  const CountToolCamara({super.key});

  @override
  State<CountToolCamara> createState() => _CountToolCamaraState();
}

class _CountToolCamaraState extends State<CountToolCamara> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isCapturing = false;

  //Crop Frame Size
  final double _frameWidth = 280;
  final double _frameHeight = 200;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  //initialize camera
  Future<void> _initCamera() async {
    try {
      //GET ALL AVAILABLE CAMERAS
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        Console.error("No camera found");
        return;
      }

      //initialize camera controller
      _controller = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      Console.error("Error initializing camera: $e");
    }
  }

  // Crop image to frame area
  Future<String?> _cropImage(String imagePath) async {
    try {
      // Read image file
      final File imageFile = File(imagePath);
      final Uint8List imageBytes = await imageFile.readAsBytes();

      // Decode image
      final img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) return null;

      // Get screen size
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight =
          MediaQuery.of(context).size.height -
          AppBar().preferredSize.height -
          MediaQuery.of(context).padding.top;

      // Calculate scale between image and screen
      final double scaleX = originalImage.width / screenWidth;
      final double scaleY = originalImage.height / screenHeight;

      // Calculate crop area in image coordinates
      final double frameLeft = (screenWidth - _frameWidth) / 2;
      final double frameTop = (screenHeight - _frameHeight) / 2;

      final int cropX = (frameLeft * scaleX).toInt();
      final int cropY = (frameTop * scaleY).toInt();
      final int cropWidth = (_frameWidth * scaleX).toInt();
      final int cropHeight = (_frameHeight * scaleY).toInt();

      // Ensure crop area is within bounds
      final int safeX = cropX.clamp(0, originalImage.width - 1);
      final int safeY = cropY.clamp(0, originalImage.height - 1);
      final int safeWidth = cropWidth.clamp(1, originalImage.width - safeX);
      final int safeHeight = cropHeight.clamp(1, originalImage.height - safeY);

      // Crop image
      final img.Image croppedImage = img.copyCrop(
        originalImage,
        x: safeX,
        y: safeY,
        width: safeWidth,
        height: safeHeight,
      );

      // Save cropped image
      final Directory tempDir = Directory.systemTemp;
      final String croppedPath =
          '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File croppedFile = File(croppedPath);
      await croppedFile.writeAsBytes(img.encodeJpg(croppedImage, quality: 90));

      return croppedPath;
    } catch (e) {
      Console.error("Error cropping image: $e");
      return null;
    }
  }

  //Capeture Image
  Future<void> _captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
    });
    Console.info("Capturing image...");

    try {
      //Take Picture
      final XFile image = await _controller!.takePicture();

      // Crop the image
      final String? croppedPath = await _cropImage(image.path);

      if (croppedPath == null) {
        Console.error("Failed to crop image");
        return;
      }

      //Navigate to preview screen with image path
      Get.toNamed(
        RouteNames.countToolImagePreview,
        arguments: {'imagePath': croppedPath},
      );
    } catch (e) {
      Console.error("Error capturing image: $e");
    } finally {
      setState(() {
        _isCapturing = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Get.toNamed(RouteNames.countToolScreen),
        ),
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            'Count Tool',
            style: AppTextStyles.headLine().copyWith(
              color: AppColors.textBlack,
              fontWeight: FontWeight.w400,
              fontSize: 18,
              letterSpacing: 1.2,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview
          _buildCameraPreview(),

          // Crop Frame Overlay
          CropFrameOverlay(frameWidth: _frameWidth, frameHeight: _frameHeight),

          // Capture Button
          _buildCaptureButton(),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_isInitialized || _controller != null) {
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _controller!.value.previewSize?.height ?? 0,
          height: _controller!.value.previewSize?.width ?? 0,
          child: CameraPreview(_controller!),
        ),
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  Widget _buildCaptureButton() {
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: _isCapturing ? null : _captureImage,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.6),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 3,
              ),
            ),
            child: _isCapturing
                ? const CircularProgressIndicator(color: Colors.white)
                : Icon(Icons.camera_alt, color: AppColors.primary, size: 32),
          ),
        ),
      ),
    );
  }
}

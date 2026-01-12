import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:scaffassistant/core/constants/api_endpoints.dart';
import 'package:scaffassistant/core/services/local_storage/user_info.dart';
import 'package:scaffassistant/core/utils/console.dart';
import 'package:scaffassistant/feature/digital%20passport/screens/document_capture_screen.dart';

class DocumentModel {
  final String id;
  final String name;
  final String cardType;
  final String? documentSize; // 'card' or 'a4'
  final String? usernameOnCard;
  final String? frontImageUrl;
  final String? backImageUrl;
  final String? captureMethod;
  final String? createdAt;

  DocumentModel({
    required this.id,
    required this.name,
    required this.cardType,
    this.documentSize,
    this.usernameOnCard,
    this.frontImageUrl,
    this.backImageUrl,
    this.captureMethod,
    this.createdAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      cardType: json['card_type'] ?? '',
      documentSize: json['document_size'],
      usernameOnCard: json['username_on_card'],
      frontImageUrl: json['front_image_url'],
      backImageUrl: json['back_image_url'],
      captureMethod: json['capture_method'],
      createdAt: json['created_at'],
    );
  }

  // Check if this is an A4 document
  bool get isA4Document {
    if (documentSize == 'a4') return true;
    if (captureMethod == 'a4_capture') return true;
    return false;
  }

  // Helper to get formatted subtitle
  String get subtitle {
    String sizeLabel = isA4Document ? 'A4' : 'Card';
    String status = '';
    if (frontImageUrl != null && backImageUrl != null) {
      status = 'Front & Back';
    } else if (frontImageUrl != null) {
      status = 'Front only';
    } else if (backImageUrl != null) {
      status = 'Back only';
    }
    return '$sizeLabel • $status';
  }

  // Helper to get display type
  String get displayType {
    switch (cardType) {
      case 'cisrs':
        return 'CISRS Card';
      case 'training':
        return 'Training Card';
      case 'certificate':
        return 'A4 Certificate';
      case 'business':
        return 'Business Document';
      default:
        return 'Other';
    }
  }
}

class DigitalPassportController extends GetxController {
  var documents = <DocumentModel>[].obs;
  var isLoading = false.obs;
  var isUploading = false.obs;

  final ImagePicker _picker = ImagePicker();

  var frontImagePath = Rxn<String>();
  var frontImageFile = Rxn<File>();
  var backImagePath = Rxn<String>();
  var backImageFile = Rxn<File>();

  final nameController = TextEditingController();

  // ═══════════════════════════════════════════════════════════════════════
  // DOCUMENT SIZE (Card or A4) - User selects manually
  // ═══════════════════════════════════════════════════════════════════════
  var selectedDocumentSize = Rxn<String>();

  final List<String> documentSizeOptions = [
    'Card (Front & Back)',
    'A4 Document (Single Page)',
  ];

  bool get isA4Mode =>
      selectedDocumentSize.value == 'A4 Document (Single Page)';

  // ═══════════════════════════════════════════════════════════════════════
  // DOCUMENT TYPE - Separate selection
  // ═══════════════════════════════════════════════════════════════════════
  var selectedDocumentType = Rxn<String>();

  final List<String> documentTypeOptions = [
    'CISRS Card',
    'Training Card',
    'A4 Certificate',
    'Business Document',
    'Other',
  ];

  var selectedDocument = Rxn<DocumentModel>();
  var showUploadDialog = false.obs;

  @override
  void onInit() {
    super.onInit();
    Console.cyan('DigitalPassportController initialized');
    fetchDocuments();
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> fetchDocuments() async {
    try {
      isLoading(true);
      Console.blue('Fetching documents...');

      final response = await http.get(
        Uri.parse(APIEndPoint.digitalPassportFetchAll),
        headers: {'Authorization': 'Bearer ${UserInfo.getAccessToken()}'},
      );

      Console.magenta('StatusCode: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['data'] != null) {
          final List data = responseData['data'];
          documents.value = data.map((e) => DocumentModel.fromJson(e)).toList();
          Console.green('Documents loaded: ${documents.length}');
        }
      } else {
        Console.red('Failed to fetch documents: ${response.statusCode}');
      }
    } catch (e) {
      Console.red('Error fetching documents: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> onCaptureFront(BuildContext context) async {
    Console.blue('Opening camera...');
    Get.to(
      () => DocumentCaptureScreen(
        initialSide: 'front',
        initialMode: CaptureMode.card,
        onImageCaptured: (File imageFile, String side, CaptureMode mode) {
          if (mode == CaptureMode.a4Document) {
            selectedDocumentSize.value = 'A4 Document (Single Page)';
          } else {
            selectedDocumentSize.value = 'Card (Front & Back)';
          }

          if (side == 'front') {
            frontImagePath.value = imageFile.path;
            frontImageFile.value = imageFile;
            Console.green(
              'Front image captured (${mode.name}): ${imageFile.path}',
            );
          } else {
            backImagePath.value = imageFile.path;
            backImageFile.value = imageFile;
            Console.green('Back image captured: ${imageFile.path}');
          }
          showUploadDialog.value = true;
        },
      ),
    );
  }

  Future<void> onUploadFront(BuildContext context) async {
    try {
      Console.blue('Opening gallery for front image...');
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (image != null) {
        frontImagePath.value = image.path;
        frontImageFile.value = File(image.path);
        selectedDocumentSize.value = null;
        showUploadDialog.value = true;
        Console.green('Front image selected: ${image.path}');
      }
    } catch (e) {
      Console.red('Error picking front image: $e');
      _showSnackBar(context, 'Failed to pick image', isError: true);
    }
  }

  Future<void> captureBackImage(BuildContext context) async {
    Console.blue('Opening camera for back image...');
    Get.to(
      () => DocumentCaptureScreen(
        initialSide: 'back',
        initialMode: CaptureMode.card,
        onImageCaptured: (File imageFile, String side, CaptureMode mode) {
          backImagePath.value = imageFile.path;
          backImageFile.value = imageFile;
          Console.green('Back image captured: ${imageFile.path}');
        },
      ),
    );
  }

  Future<void> pickBackImage(BuildContext context) async {
    try {
      Console.blue('Opening gallery for back image...');
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (image != null) {
        backImagePath.value = image.path;
        backImageFile.value = File(image.path);
        Console.green('Back image selected: ${image.path}');
      }
    } catch (e) {
      Console.red('Error picking back image: $e');
      _showSnackBar(context, 'Failed to pick image', isError: true);
    }
  }

  void showBackImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add Back Image',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    captureBackImage(context);
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 32,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Camera'),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    pickBackImage(context);
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.photo_library,
                          size: 32,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Gallery'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  bool validateUpload(BuildContext context) {
    if (frontImageFile.value == null) {
      _showSnackBar(context, 'Please add front image', isError: true);
      return false;
    }
    if (selectedDocumentSize.value == null) {
      _showSnackBar(context, 'Please select document size', isError: true);
      return false;
    }
    if (!isA4Mode && backImageFile.value == null) {
      _showSnackBar(
        context,
        'Please add back image for card documents',
        isError: true,
      );
      return false;
    }
    if (nameController.text.trim().isEmpty) {
      _showSnackBar(context, 'Please enter document name', isError: true);
      return false;
    }
    if (selectedDocumentType.value == null) {
      _showSnackBar(context, 'Please select document type', isError: true);
      return false;
    }
    Console.green('Validation passed');
    return true;
  }

  Future<bool> uploadDocument(BuildContext context) async {
    if (!validateUpload(context)) return false;

    try {
      isUploading(true);
      Console.blue('Uploading document...');
      Console.cyan('Name: ${nameController.text}');
      Console.cyan('Size: ${selectedDocumentSize.value}');
      Console.cyan('Type: ${selectedDocumentType.value}');

      String cardType = 'other';
      switch (selectedDocumentType.value) {
        case 'CISRS Card':
          cardType = 'cisrs';
          break;
        case 'Training Card':
          cardType = 'training';
          break;
        case 'A4 Certificate':
          cardType = 'certificate';
          break;
        case 'Business Document':
          cardType = 'business';
          break;
        default:
          cardType = 'other';
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(APIEndPoint.digitalPassportUpload),
      );
      request.headers.addAll({
        'Authorization': 'Bearer ${UserInfo.getAccessToken()}',
      });

      request.fields['name'] = nameController.text.trim();
      request.fields['card_type'] = cardType;
      request.fields['document_size'] = isA4Mode ? 'a4' : 'card';
      request.fields['capture_method'] = isA4Mode
          ? 'a4_capture'
          : 'card_capture';

      request.files.add(
        await http.MultipartFile.fromPath(
          'front_image',
          frontImageFile.value!.path,
        ),
      );

      if (!isA4Mode && backImageFile.value != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'back_image',
            backImageFile.value!.path,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      Console.magenta('StatusCode: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Console.green('Document uploaded successfully!');
        _showSnackBar(context, 'Document uploaded successfully');
        clearSelection();
        fetchDocuments();
        return true;
      } else {
        Console.red('Upload failed: ${response.body}');
        _showSnackBar(context, 'Failed to upload document', isError: true);
        return false;
      }
    } catch (e) {
      Console.red('Error uploading document: $e');
      _showSnackBar(context, 'Failed to upload document', isError: true);
      return false;
    } finally {
      isUploading(false);
    }
  }

  void clearSelection() {
    frontImagePath.value = null;
    frontImageFile.value = null;
    backImagePath.value = null;
    backImageFile.value = null;
    nameController.clear();
    selectedDocumentSize.value = null;
    selectedDocumentType.value = null;
    showUploadDialog.value = false;
    Console.cyan('Selection cleared');
  }

  // ==================== EDIT ====================
  var editFrontImageFile = Rxn<File>();
  var editBackImageFile = Rxn<File>();

  void onEditDocument(DocumentModel document) {
    selectedDocument.value = document;
    nameController.text = document.name;
    selectedDocumentType.value = document.displayType;
    selectedDocumentSize.value = document.isA4Document
        ? 'A4 Document (Single Page)'
        : 'Card (Front & Back)';
    editFrontImageFile.value = null;
    editBackImageFile.value = null;
    Console.blue('Editing document: ${document.id}');
  }

  Future<void> captureEditFrontImage(BuildContext context) async {
    Get.to(
      () => DocumentCaptureScreen(
        initialSide: 'front',
        initialMode: isA4Mode ? CaptureMode.a4Document : CaptureMode.card,
        onImageCaptured: (File imageFile, String side, CaptureMode mode) {
          editFrontImageFile.value = imageFile;
          Console.green('Edit front image captured: ${imageFile.path}');
        },
      ),
    );
  }

  Future<void> pickEditFrontImage(BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 80,
      );
      if (image != null) {
        editFrontImageFile.value = File(image.path);
        Console.green('Edit front image selected: ${image.path}');
      }
    } catch (e) {
      Console.red('Error picking edit front image: $e');
    }
  }

  Future<void> captureEditBackImage(BuildContext context) async {
    Get.to(
      () => DocumentCaptureScreen(
        initialSide: 'back',
        initialMode: CaptureMode.card,
        onImageCaptured: (File imageFile, String side, CaptureMode mode) {
          editBackImageFile.value = imageFile;
          Console.green('Edit back image captured: ${imageFile.path}');
        },
      ),
    );
  }

  Future<void> pickEditBackImage(BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 80,
      );
      if (image != null) {
        editBackImageFile.value = File(image.path);
        Console.green('Edit back image selected: ${image.path}');
      }
    } catch (e) {
      Console.red('Error picking edit back image: $e');
    }
  }

  void showEditImageSourceDialog(
    BuildContext context, {
    required bool isFront,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isFront ? 'Change Front Image' : 'Change Back Image',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    isFront
                        ? captureEditFrontImage(context)
                        : captureEditBackImage(context);
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 32,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Camera'),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    isFront
                        ? pickEditFrontImage(context)
                        : pickEditBackImage(context);
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.photo_library,
                          size: 32,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Gallery'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> onSaveEdit(BuildContext context) async {
    if (selectedDocument.value == null) return;

    if (nameController.text.trim().isEmpty) {
      _showSnackBar(context, 'Please enter document name', isError: true);
      return;
    }
    if (selectedDocumentType.value == null) {
      _showSnackBar(context, 'Please select document type', isError: true);
      return;
    }

    try {
      isUploading(true);
      Console.blue('Saving edit for: ${selectedDocument.value!.id}');

      String cardType = 'other';
      switch (selectedDocumentType.value) {
        case 'CISRS Card':
          cardType = 'cisrs';
          break;
        case 'Training Card':
          cardType = 'training';
          break;
        case 'A4 Certificate':
          cardType = 'certificate';
          break;
        case 'Business Document':
          cardType = 'business';
          break;
        default:
          cardType = 'other';
      }

      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse(
          '${APIEndPoint.digitalPassportFetchAll}${selectedDocument.value!.id}/',
        ),
      );
      request.headers.addAll({
        'Authorization': 'Bearer ${UserInfo.getAccessToken()}',
      });

      request.fields['name'] = nameController.text.trim();
      request.fields['card_type'] = cardType;
      request.fields['document_size'] = isA4Mode ? 'a4' : 'card';

      if (editFrontImageFile.value != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'front_image',
            editFrontImageFile.value!.path,
          ),
        );
      }
      if (editBackImageFile.value != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'back_image',
            editBackImageFile.value!.path,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 204) {
        Console.green('Document updated');
        _showSnackBar(context, 'Document updated');
        fetchDocuments();
        closeEditDialog();
      } else {
        Console.red('Update failed: ${response.body}');
        _showSnackBar(context, 'Failed to update document', isError: true);
      }
    } catch (e) {
      Console.red('Error saving edit: $e');
      _showSnackBar(context, 'Failed to update document', isError: true);
    } finally {
      isUploading(false);
    }
  }

  Future<void> onDeleteDocument(
    BuildContext context,
    DocumentModel document,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Are you sure you want to delete "${document.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      Console.yellow('Deleting document: ${document.id}');
      final response = await http.delete(
        Uri.parse('${APIEndPoint.digitalPassportFetchAll}${document.id}/'),
        headers: {'Authorization': 'Bearer ${UserInfo.getAccessToken()}'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        documents.removeWhere((d) => d.id == document.id);
        Console.green('Document deleted');
        _showSnackBar(context, 'Document deleted');
      } else {
        Console.red('Delete failed: ${response.body}');
        _showSnackBar(context, 'Failed to delete document', isError: true);
      }
    } catch (e) {
      Console.red('Error deleting document: $e');
      _showSnackBar(context, 'Failed to delete document', isError: true);
    }
  }

  void closeEditDialog() {
    selectedDocument.value = null;
    nameController.clear();
    selectedDocumentSize.value = null;
    selectedDocumentType.value = null;
    editFrontImageFile.value = null;
    editBackImageFile.value = null;
    Console.cyan('Edit dialog closed');
  }

  @override
  void onClose() {
    nameController.dispose();
    Console.cyan('DigitalPassportController disposed');
    super.onClose();
  }
}

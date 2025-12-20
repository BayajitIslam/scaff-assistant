import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:scaffassistant/core/const/string_const/api_endpoint.dart';
import 'package:scaffassistant/core/local_storage/user_info.dart';
import 'package:scaffassistant/core/utils/log.dart';
import 'package:scaffassistant/feature/additional_screen/screens/document_capture_screen.dart';

class DocumentModel {
  final String id;
  final String name;
  final String cardType;
  final String? usernameOnCard;
  final String? frontImageUrl;
  final String? backImageUrl;
  final String? captureMethod;
  final String? createdAt;

  DocumentModel({
    required this.id,
    required this.name,
    required this.cardType,
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
      usernameOnCard: json['username_on_card'],
      frontImageUrl: json['front_image_url'],
      backImageUrl: json['back_image_url'],
      captureMethod: json['capture_method'],
      createdAt: json['created_at'],
    );
  }

  // Helper to get formatted subtitle
  String get subtitle {
    String status = '';
    if (frontImageUrl != null && backImageUrl != null) {
      status = 'Front and back';
    } else if (frontImageUrl != null) {
      status = 'Front only';
    } else if (backImageUrl != null) {
      status = 'Back only';
    }
    return '$status . Added';
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
  // Documents list
  var documents = <DocumentModel>[].obs;

  // Loading state
  var isLoading = false.obs;
  var isUploading = false.obs;

  // Image picker
  final ImagePicker _picker = ImagePicker();

  // Front image
  var frontImagePath = Rxn<String>();
  var frontImageFile = Rxn<File>();

  // Back image
  var backImagePath = Rxn<String>();
  var backImageFile = Rxn<File>();

  // Document name
  final nameController = TextEditingController();

  // Document type dropdown
  var selectedDocumentType = Rxn<String>();

  // Document type options (4 types + Other = 5)
  final List<String> documentTypeOptions = [
    'CISRS Card',
    'Training Card',
    'A4 Certificate',
    'Business Document',
    'Other',
  ];

  // Edit dialog state
  var selectedDocument = Rxn<DocumentModel>();

  // Flag to show dialog
  var showUploadDialog = false.obs;

  @override
  void onInit() {
    super.onInit();
    Console.cyan('DigitalPassportController initialized');
    fetchDocuments();
  }

  // Show snackbar helper
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
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Fetch documents from API
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

        // Data is inside 'data' key
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

  // ==================== FRONT IMAGE (Direct - No Dialog) ====================

  // Capture front image using custom camera screen
  Future<void> onCaptureFront(BuildContext context) async {
    Console.blue('Opening camera for front image...');

    Get.to(
      () => DocumentCaptureScreen(
        initialSide: 'front',
        onImageCaptured: (File imageFile, String side) {
          if (side == 'front') {
            frontImagePath.value = imageFile.path;
            frontImageFile.value = imageFile;
            Console.green('Front image captured: ${imageFile.path}');
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

  // Pick front image directly from gallery (Upload button)
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
        showUploadDialog.value = true;
        Console.green('Front image selected: ${image.path}');
      }
    } catch (e) {
      Console.red('Error picking front image: $e');
      _showSnackBar(context, 'Failed to pick image', isError: true);
    }
  }

  // ==================== BACK IMAGE (With Dialog Choice) ====================

  // Capture back image using custom camera screen
  Future<void> captureBackImage(BuildContext context) async {
    Console.blue('Opening camera for back image...');

    Get.to(
      () => DocumentCaptureScreen(
        initialSide: 'back',
        onImageCaptured: (File imageFile, String side) {
          if (side == 'front') {
            frontImagePath.value = imageFile.path;
            frontImageFile.value = imageFile;
            Console.green('Front image captured: ${imageFile.path}');
          } else {
            backImagePath.value = imageFile.path;
            backImageFile.value = imageFile;
            Console.green('Back image captured: ${imageFile.path}');
          }
        },
      ),
    );
  }

  // Pick back image from gallery
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

  // Show image source selection for BACK image only (Camera or Gallery)
  void showBackImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add Back Image',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Camera option
                GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    captureBackImage(context);
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 32,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Camera'),
                    ],
                  ),
                ),
                // Gallery option
                GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    pickBackImage(context);
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.photo_library,
                          size: 32,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Gallery'),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Validate before upload
  bool validateUpload(BuildContext context) {
    if (frontImageFile.value == null) {
      Console.yellow('Validation failed: No front image');
      _showSnackBar(context, 'Please add front image', isError: true);
      return false;
    }

    if (backImageFile.value == null) {
      Console.yellow('Validation failed: No back image');
      _showSnackBar(context, 'Please add back image', isError: true);
      return false;
    }

    if (nameController.text.trim().isEmpty) {
      Console.yellow('Validation failed: No document name');
      _showSnackBar(context, 'Please enter document name', isError: true);
      return false;
    }

    if (selectedDocumentType.value == null) {
      Console.yellow('Validation failed: No document type');
      _showSnackBar(context, 'Please select document type', isError: true);
      return false;
    }

    Console.green('Validation passed');
    return true;
  }

  // Upload document to API
  Future<bool> uploadDocument(BuildContext context) async {
    if (!validateUpload(context)) return false;

    try {
      isUploading(true);
      Console.blue('Uploading document...');
      Console.cyan('Name: ${nameController.text}');
      Console.cyan('Type: ${selectedDocumentType.value}');

      // Map dropdown to API card_type
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

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(APIEndPoint.digitalPassportUpload),
      );

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer ${UserInfo.getAccessToken()}',
      });

      // Add fields
      request.fields['name'] = nameController.text.trim();
      request.fields['card_type'] = cardType;
      request.fields['capture_method'] = 'upload';

      // Add front image
      request.files.add(
        await http.MultipartFile.fromPath(
          'front_image',
          frontImageFile.value!.path,
        ),
      );

      // Add back image
      request.files.add(
        await http.MultipartFile.fromPath(
          'back_image',
          backImageFile.value!.path,
        ),
      );

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      Console.magenta('StatusCode: ${response.statusCode}');
      Console.magenta('Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Console.green('Document uploaded successfully!');
        _showSnackBar(context, 'Document uploaded successfully');

        // Clear selection
        clearSelection();

        // Refresh documents list
        fetchDocuments();
        return true; // Success
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

  // Clear all selections
  void clearSelection() {
    frontImagePath.value = null;
    frontImageFile.value = null;
    backImagePath.value = null;
    backImageFile.value = null;
    nameController.clear();
    selectedDocumentType.value = null;
    showUploadDialog.value = false;
    Console.cyan('Selection cleared');
  }

  // New images for edit
  var editFrontImageFile = Rxn<File>();
  var editBackImageFile = Rxn<File>();

  // Edit existing document
  void onEditDocument(DocumentModel document) {
    selectedDocument.value = document;
    nameController.text = document.name;
    selectedDocumentType.value = document.displayType;
    // Clear any previous edit images
    editFrontImageFile.value = null;
    editBackImageFile.value = null;
    Console.blue('Editing document: ${document.id}');
  }

  // Capture new front image for edit
  Future<void> captureEditFrontImage(BuildContext context) async {
    Console.blue('Opening camera for edit front image...');

    Get.to(
      () => DocumentCaptureScreen(
        initialSide: 'front',
        onImageCaptured: (File imageFile, String side) {
          editFrontImageFile.value = imageFile;
          Console.green('Edit front image captured: ${imageFile.path}');
        },
      ),
    );
  }

  // Pick new front image for edit from gallery
  Future<void> pickEditFrontImage(BuildContext context) async {
    try {
      Console.blue('Opening gallery for edit front image...');
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

  // Capture new back image for edit
  Future<void> captureEditBackImage(BuildContext context) async {
    Console.blue('Opening camera for edit back image...');

    Get.to(
      () => DocumentCaptureScreen(
        initialSide: 'back',
        onImageCaptured: (File imageFile, String side) {
          editBackImageFile.value = imageFile;
          Console.green('Edit back image captured: ${imageFile.path}');
        },
      ),
    );
  }

  // Pick new back image for edit from gallery
  Future<void> pickEditBackImage(BuildContext context) async {
    try {
      Console.blue('Opening gallery for edit back image...');
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

  // Show image source dialog for edit
  void showEditImageSourceDialog(
    BuildContext context, {
    required bool isFront,
  }) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isFront ? 'Change Front Image' : 'Change Back Image',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Camera option
                GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    if (isFront) {
                      captureEditFrontImage(context);
                    } else {
                      captureEditBackImage(context);
                    }
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 32,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Camera'),
                    ],
                  ),
                ),
                // Gallery option
                GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    if (isFront) {
                      pickEditFrontImage(context);
                    } else {
                      pickEditBackImage(context);
                    }
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.photo_library,
                          size: 32,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Gallery'),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Save edited document - Using multipart/form-data
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

      // Map dropdown to API card_type
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

      // Create multipart request for PATCH
      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse(
          '${APIEndPoint.digitalPassportFetchAll}${selectedDocument.value!.id}/',
        ),
      );

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer ${UserInfo.getAccessToken()}',
      });

      // Add fields
      request.fields['name'] = nameController.text.trim();
      request.fields['card_type'] = cardType;

      // Add new front image if selected
      if (editFrontImageFile.value != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'front_image',
            editFrontImageFile.value!.path,
          ),
        );
        Console.cyan('Adding new front image');
      }

      // Add new back image if selected
      if (editBackImageFile.value != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'back_image',
            editBackImageFile.value!.path,
          ),
        );
        Console.cyan('Adding new back image');
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      Console.magenta('Update StatusCode: ${response.statusCode}');
      Console.magenta('Update Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        Console.green('Document updated');
        _showSnackBar(context, 'Document updated');

        // Refresh documents list
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
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Document'),
        content: Text('Are you sure you want to delete "${document.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
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

      Console.magenta('Delete StatusCode: ${response.statusCode}');

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

  // Save edited document
  void closeEditDialog() {
    selectedDocument.value = null;
    nameController.clear();
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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';
import 'package:scaffassistant/core/utils/dynamic_size.dart';
import 'package:scaffassistant/feature/additional_screen/widgets/custom_appbar.dart';
import 'package:scaffassistant/feature/additional_screen/widgets/digital_passport_widget/document_card.dart';
import 'package:scaffassistant/feature/additional_screen/widgets/digital_passport_widget/document_item.dart';
import 'package:scaffassistant/feature/additional_screen/widgets/digital_passport_widget/quick_add_card.dart';
import 'package:scaffassistant/feature/additional_screen/widgets/weight_calculator_widget/description_card.dart';
import '../controllers/digital_passport_controller.dart';

class DigitalPassportScreen extends StatelessWidget {
  DigitalPassportScreen({super.key});

  final controller = Get.put(DigitalPassportController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // App Bar
          CustomAppBar(
            title: 'DIGITAL PASSPORT',
            onBackPressed: () => Get.back(),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(DynamicSize.medium(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description Card
                  DescriptionCard(
                    text:
                        'Store CISRS, training cards , A4 certificates, and business docs securely under your account',
                  ),

                  SizedBox(height: DynamicSize.medium(context)),

                  // Quick Add Card
                  QuickAddCard(
                    // Capture → Direct camera for FRONT image
                    onCapture: () => controller.onCaptureFront(context),
                    // Upload → Direct gallery for FRONT image
                    onUpload: () => controller.onUploadFront(context),
                  ),

                  SizedBox(height: DynamicSize.medium(context)),

                  // Listen for dialog trigger
                  Obx(() {
                    if (controller.showUploadDialog.value) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _showUploadDialog(context);
                      });
                    }
                    return SizedBox.shrink();
                  }),

                  // Documents List
                  Obx(() {
                    if (controller.isLoading.value) {
                      return Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      );
                    }

                    if (controller.documents.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'No documents yet.\nCapture or upload to add.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: controller.documents.map((document) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: DynamicSize.medium(context),
                          ),
                          child: DocumentCard(
                            title: 'YOUR DOCUMENT',
                            onEdit: () => _showEditDialog(context, document),
                            onDelete: () =>
                                controller.onDeleteDocument(context, document),
                            child: DocumentItem(
                              imagePath: document.frontImageUrl,
                              title:
                                  "${document.displayType} - ${document.name}",
                              subtitle: document.subtitle,
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Show upload dialog with front/back images, name, and type
  void _showUploadDialog(BuildContext context) {
    controller.showUploadDialog.value = false; // Reset flag

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) =>
          _UploadDocumentDialog(controller: controller, parentContext: context),
    );
  }

  // Show edit dialog for existing document
  void _showEditDialog(BuildContext context, DocumentModel document) {
    controller.onEditDocument(document);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _EditDocumentDialog(
        controller: controller,
        document: document,
        parentContext: context,
      ),
    );
  }
}

// Upload Document Dialog
class _UploadDocumentDialog extends StatelessWidget {
  final DigitalPassportController controller;
  final BuildContext parentContext;

  const _UploadDocumentDialog({
    required this.controller,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Document',
                    style: AppTextStyles.headLine().copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textBlackPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      controller.clearSelection();
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Front & Back Images Row
              Row(
                children: [
                  // Front Image (already selected, can tap to change)
                  Expanded(
                    child: _ImageBox(
                      label: 'Front',
                      imagePath: controller.frontImagePath,
                      onTap: () {
                        // Show choice for changing front image
                        _showFrontImageChangeDialog(context);
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  // Back Image (tap to choose camera/gallery)
                  Expanded(
                    child: _ImageBox(
                      label: 'Back',
                      imagePath: controller.backImagePath,
                      onTap: () {
                        // Show bottom sheet for back image
                        controller.showBackImageSourceDialog(parentContext);
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Document Name Input
              Text(
                'Document Name',
                style: AppTextStyles.subHeadLine().copyWith(
                  color: AppColors.textBlackPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: controller.nameController,
                decoration: InputDecoration(
                  hintText: 'Enter document name',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Document Type Dropdown
              Text(
                'Document Type',
                style: AppTextStyles.subHeadLine().copyWith(
                  color: AppColors.textBlackPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Obx(
                () => Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedDocumentType.value,
                      hint: Text(
                        'Select document type',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      isExpanded: true,
                      icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                      items: controller.documentTypeOptions.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        controller.selectedDocumentType.value = value;
                      },
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.clearSelection();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 12),

                  // Upload Button
                  Expanded(
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: controller.isUploading.value
                            ? null
                            : () async {
                                final success = await controller.uploadDocument(
                                  parentContext,
                                );
                                if (success) {
                                  Navigator.pop(context);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: controller.isUploading.value
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Upload',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show choice dialog to change front image
  void _showFrontImageChangeDialog(BuildContext context) {
    showModalBottomSheet(
      context: parentContext,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Change Front Image',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Camera option
                GestureDetector(
                  onTap: () async {
                    Navigator.pop(ctx);
                    await controller.onCaptureFront(parentContext);
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
                  onTap: () async {
                    Navigator.pop(ctx);
                    await controller.onUploadFront(parentContext);
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
}

// Image Box Widget
class _ImageBox extends StatelessWidget {
  final String label;
  final Rxn<String> imagePath;
  final VoidCallback onTap;

  const _ImageBox({
    required this.label,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Obx(
            () => Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
                color: Colors.grey.withOpacity(0.05),
              ),
              child: imagePath.value != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(File(imagePath.value!), fit: BoxFit.cover),
                          // Edit overlay
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.edit,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_outlined,
                          size: 32,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add $label',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

// Edit Document Dialog
class _EditDocumentDialog extends StatelessWidget {
  final DigitalPassportController controller;
  final DocumentModel document;
  final BuildContext parentContext;

  const _EditDocumentDialog({
    required this.controller,
    required this.document,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Document',
                    style: AppTextStyles.headLine().copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textBlackPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      controller.closeEditDialog();
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Front & Back Images Row
              Row(
                children: [
                  // Front Image
                  Expanded(
                    child: _EditImageBox(
                      label: 'Front',
                      networkImageUrl: document.frontImageUrl,
                      newImageFile: controller.editFrontImageFile,
                      onTap: () {
                        controller.showEditImageSourceDialog(
                          parentContext,
                          isFront: true,
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  // Back Image
                  Expanded(
                    child: _EditImageBox(
                      label: 'Back',
                      networkImageUrl: document.backImageUrl,
                      newImageFile: controller.editBackImageFile,
                      onTap: () {
                        controller.showEditImageSourceDialog(
                          parentContext,
                          isFront: false,
                        );
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Document Name Input
              Text(
                'Document Name',
                style: AppTextStyles.subHeadLine().copyWith(
                  color: AppColors.textBlackPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: controller.nameController,
                decoration: InputDecoration(
                  hintText: 'Enter document name',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Document Type Dropdown
              Text(
                'Document Type',
                style: AppTextStyles.subHeadLine().copyWith(
                  color: AppColors.textBlackPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Obx(
                () => Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedDocumentType.value,
                      hint: Text('Select document type'),
                      isExpanded: true,
                      items: controller.documentTypeOptions.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        controller.selectedDocumentType.value = value;
                      },
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.closeEditDialog();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: controller.isUploading.value
                            ? null
                            : () async {
                                await controller.onSaveEdit(parentContext);
                                Navigator.pop(context);
                              },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: controller.isUploading.value
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Save',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Edit Image Box Widget - Shows existing or new image with edit option
class _EditImageBox extends StatelessWidget {
  final String label;
  final String? networkImageUrl;
  final Rxn<File> newImageFile;
  final VoidCallback onTap;

  const _EditImageBox({
    required this.label,
    this.networkImageUrl,
    required this.newImageFile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Obx(
            () => Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                  width: 1.5,
                ),
                color: Colors.grey.withOpacity(0.05),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Show new image if selected, otherwise show existing
                    if (newImageFile.value != null)
                      Image.file(newImageFile.value!, fit: BoxFit.cover)
                    else if (networkImageUrl != null)
                      Image.network(
                        networkImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholder();
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                      )
                    else
                      _buildPlaceholder(),

                    // Edit overlay
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.edit, size: 14, color: Colors.white),
                      ),
                    ),

                    // "New" badge if new image selected
                    if (newImageFile.value != null)
                      Positioned(
                        left: 8,
                        top: 8,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'NEW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo_outlined, size: 24, color: Colors.grey),
          SizedBox(height: 4),
          Text(
            'Add $label',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

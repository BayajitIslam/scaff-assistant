import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';
import 'package:scaffassistant/core/utils/dynamic_size.dart';
import 'package:scaffassistant/feature/Calculator/widgets/weight_calculator_widget/description_card.dart';
import 'package:scaffassistant/feature/digital%20passport/widgets/custom_appbar.dart';
import 'package:scaffassistant/feature/digital%20passport/widgets/digital_passport_widget/document_card.dart';
import 'package:scaffassistant/feature/digital%20passport/widgets/digital_passport_widget/document_item.dart';
import 'package:scaffassistant/feature/digital%20passport/widgets/digital_passport_widget/quick_add_card.dart';
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
          CustomAppBar(
            title: 'DIGITAL PASSPORT',
            onBackPressed: () => Get.back(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(DynamicSize.medium(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DescriptionCard(
                    text:
                        'Store CISRS, training cards, A4 certificates, and business docs securely under your account',
                  ),
                  SizedBox(height: DynamicSize.medium(context)),
                  QuickAddCard(
                    onCapture: () => controller.onCaptureFront(context),
                    onUpload: () => controller.onUploadFront(context),
                  ),
                  SizedBox(height: DynamicSize.medium(context)),
                  Obx(() {
                    if (controller.showUploadDialog.value) {
                      WidgetsBinding.instance.addPostFrameCallback(
                        (_) => _showUploadDialog(context),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  Obx(() {
                    if (controller.isLoading.value) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }
                    if (controller.documents.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
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
                            title: document.isA4Document
                                ? 'A4 DOCUMENT'
                                : 'CARD DOCUMENT',
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

  void _showUploadDialog(BuildContext context) {
    controller.showUploadDialog.value = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) =>
          UploadDocumentDialog(controller: controller, parentContext: context),
    );
  }

  void _showEditDialog(BuildContext context, DocumentModel document) {
    controller.onEditDocument(document);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => EditDocumentDialog(
        controller: controller,
        document: document,
        parentContext: context,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// UPLOAD DOCUMENT DIALOG
// ═══════════════════════════════════════════════════════════════════════════
class UploadDocumentDialog extends StatelessWidget {
  final DigitalPassportController controller;
  final BuildContext parentContext;

  const UploadDocumentDialog({
    super.key,
    required this.controller,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
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
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ═══════════════════════════════════════════════════════════
              // STEP 1: Document Size Selection
              // ═══════════════════════════════════════════════════════════
              Text(
                'Document Size *',
                style: AppTextStyles.subHeadLine().copyWith(
                  color: AppColors.textBlackPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Row(
                  children: [
                    // Card Option
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.selectedDocumentSize.value =
                            'Card (Front & Back)',
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color:
                                controller.selectedDocumentSize.value ==
                                    'Card (Front & Back)'
                                ? AppColors.primary.withOpacity(0.15)
                                : Colors.grey.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color:
                                  controller.selectedDocumentSize.value ==
                                      'Card (Front & Back)'
                                  ? AppColors.primary
                                  : Colors.grey.withOpacity(0.3),
                              width:
                                  controller.selectedDocumentSize.value ==
                                      'Card (Front & Back)'
                                  ? 2
                                  : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.credit_card,
                                size: 28,
                                color:
                                    controller.selectedDocumentSize.value ==
                                        'Card (Front & Back)'
                                    ? AppColors.primary
                                    : Colors.grey,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Card',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color:
                                      controller.selectedDocumentSize.value ==
                                          'Card (Front & Back)'
                                      ? AppColors.primary
                                      : Colors.grey[700],
                                ),
                              ),
                              Text(
                                'Front & Back',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // A4 Option
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          controller.selectedDocumentSize.value =
                              'A4 Document (Single Page)';
                          // Clear back image when switching to A4
                          controller.backImagePath.value = null;
                          controller.backImageFile.value = null;
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color:
                                controller.selectedDocumentSize.value ==
                                    'A4 Document (Single Page)'
                                ? Colors.blue.withOpacity(0.15)
                                : Colors.grey.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color:
                                  controller.selectedDocumentSize.value ==
                                      'A4 Document (Single Page)'
                                  ? Colors.blue
                                  : Colors.grey.withOpacity(0.3),
                              width:
                                  controller.selectedDocumentSize.value ==
                                      'A4 Document (Single Page)'
                                  ? 2
                                  : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.description,
                                size: 28,
                                color:
                                    controller.selectedDocumentSize.value ==
                                        'A4 Document (Single Page)'
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'A4 Doc',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color:
                                      controller.selectedDocumentSize.value ==
                                          'A4 Document (Single Page)'
                                      ? Colors.blue
                                      : Colors.grey[700],
                                ),
                              ),
                              Text(
                                'Single Page',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ═══════════════════════════════════════════════════════════
              // STEP 2: Images Section (changes based on size)
              // ═══════════════════════════════════════════════════════════
              Obx(() {
                if (controller.isA4Mode) {
                  // A4: Only Front Image (Full Width)
                  return A4ImageBox(
                    imagePath: controller.frontImagePath,
                    onTap: () => _showFrontImageChangeDialog(context),
                  );
                } else {
                  // Card: Front & Back Images
                  return Row(
                    children: [
                      Expanded(
                        child: ImageBox(
                          label: 'Front *',
                          imagePath: controller.frontImagePath,
                          onTap: () => _showFrontImageChangeDialog(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ImageBox(
                          label: 'Back *',
                          imagePath: controller.backImagePath,
                          onTap: () => controller.showBackImageSourceDialog(
                            parentContext,
                          ),
                        ),
                      ),
                    ],
                  );
                }
              }),
              const SizedBox(height: 16),

              // ═══════════════════════════════════════════════════════════
              // STEP 3: Document Name
              // ═══════════════════════════════════════════════════════════
              Text(
                'Document Name *',
                style: AppTextStyles.subHeadLine().copyWith(
                  color: AppColors.textBlackPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller.nameController,
                decoration: InputDecoration(
                  hintText: 'e.g., My CISRS Card, Safety Certificate',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(
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
              const SizedBox(height: 16),

              // ═══════════════════════════════════════════════════════════
              // STEP 4: Document Type
              // ═══════════════════════════════════════════════════════════
              Text(
                'Document Type *',
                style: AppTextStyles.subHeadLine().copyWith(
                  color: AppColors.textBlackPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        IconData icon = Icons.description;
                        if (type.contains('CISRS'))
                          icon = Icons.badge;
                        else if (type.contains('Training'))
                          icon = Icons.school;
                        else if (type.contains('Certificate'))
                          icon = Icons.workspace_premium;
                        else if (type.contains('Business'))
                          icon = Icons.business;
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Row(
                            children: [
                              Icon(icon, size: 18, color: Colors.grey[600]),
                              const SizedBox(width: 10),
                              Text(type),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          controller.selectedDocumentType.value = value,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.clearSelection();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: controller.isUploading.value
                            ? null
                            : () async {
                                final success = await controller.uploadDocument(
                                  parentContext,
                                );
                                if (success) Navigator.pop(context);
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: controller.isA4Mode
                              ? Colors.blue
                              : AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: controller.isUploading.value
                            ? const SizedBox(
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
                                  color: controller.isA4Mode
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.w600,
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

  void _showFrontImageChangeDialog(BuildContext context) {
    showModalBottomSheet(
      context: parentContext,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Change Front Image',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () async {
                    Navigator.pop(ctx);
                    await controller.onCaptureFront(parentContext);
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
                  onTap: () async {
                    Navigator.pop(ctx);
                    await controller.onUploadFront(parentContext);
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
}

// ═══════════════════════════════════════════════════════════════════════════
// EDIT DOCUMENT DIALOG
// ═══════════════════════════════════════════════════════════════════════════
class EditDocumentDialog extends StatelessWidget {
  final DigitalPassportController controller;
  final DocumentModel document;
  final BuildContext parentContext;

  const EditDocumentDialog({
    super.key,
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
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Document Size Selection
              Text(
                'Document Size',
                style: AppTextStyles.subHeadLine().copyWith(
                  color: AppColors.textBlackPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.selectedDocumentSize.value =
                            'Card (Front & Back)',
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !controller.isA4Mode
                                ? AppColors.primary.withOpacity(0.15)
                                : Colors.grey.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: !controller.isA4Mode
                                  ? AppColors.primary
                                  : Colors.grey.withOpacity(0.3),
                              width: !controller.isA4Mode ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.credit_card,
                                size: 24,
                                color: !controller.isA4Mode
                                    ? AppColors.primary
                                    : Colors.grey,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Card',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: !controller.isA4Mode
                                      ? AppColors.primary
                                      : Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.selectedDocumentSize.value =
                            'A4 Document (Single Page)',
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: controller.isA4Mode
                                ? Colors.blue.withOpacity(0.15)
                                : Colors.grey.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: controller.isA4Mode
                                  ? Colors.blue
                                  : Colors.grey.withOpacity(0.3),
                              width: controller.isA4Mode ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.description,
                                size: 24,
                                color: controller.isA4Mode
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'A4 Doc',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: controller.isA4Mode
                                      ? Colors.blue
                                      : Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Images
              Obx(() {
                if (controller.isA4Mode) {
                  return EditA4ImageBox(
                    networkImageUrl: document.frontImageUrl,
                    newImageFile: controller.editFrontImageFile,
                    onTap: () => controller.showEditImageSourceDialog(
                      parentContext,
                      isFront: true,
                    ),
                  );
                } else {
                  return Row(
                    children: [
                      Expanded(
                        child: EditImageBox(
                          label: 'Front',
                          networkImageUrl: document.frontImageUrl,
                          newImageFile: controller.editFrontImageFile,
                          onTap: () => controller.showEditImageSourceDialog(
                            parentContext,
                            isFront: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: EditImageBox(
                          label: 'Back',
                          networkImageUrl: document.backImageUrl,
                          newImageFile: controller.editBackImageFile,
                          onTap: () => controller.showEditImageSourceDialog(
                            parentContext,
                            isFront: false,
                          ),
                        ),
                      ),
                    ],
                  );
                }
              }),
              const SizedBox(height: 16),

              // Name
              Text(
                'Document Name',
                style: AppTextStyles.subHeadLine().copyWith(
                  color: AppColors.textBlackPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller.nameController,
                decoration: InputDecoration(
                  hintText: 'Enter document name',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Type
              Text(
                'Document Type',
                style: AppTextStyles.subHeadLine().copyWith(
                  color: AppColors.textBlackPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedDocumentType.value,
                      hint: const Text('Select document type'),
                      isExpanded: true,
                      items: controller.documentTypeOptions
                          .map(
                            (type) => DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          controller.selectedDocumentType.value = value,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
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
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: controller.isA4Mode
                              ? Colors.blue
                              : AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: controller.isUploading.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Save',
                                style: TextStyle(
                                  color: controller.isA4Mode
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.w600,
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
}

// ═══════════════════════════════════════════════════════════════════════════
// IMAGE WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

class A4ImageBox extends StatelessWidget {
  final Rxn<String> imagePath;
  final VoidCallback onTap;
  const A4ImageBox({super.key, required this.imagePath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.description, size: 16, color: Colors.blue),
            const SizedBox(width: 6),
            Text(
              'A4 Document Image *',
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Obx(
            () => Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.4),
                  width: 2,
                ),
                color: Colors.blue.withOpacity(0.05),
              ),
              child: imagePath.value != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(
                            File(imagePath.value!),
                            fit: BoxFit.contain,
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'A4',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
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
                          Icons.document_scanner,
                          size: 48,
                          color: Colors.blue.withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tap to add image',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.withOpacity(0.7),
                          ),
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

class ImageBox extends StatelessWidget {
  final String label;
  final Rxn<String> imagePath;
  final VoidCallback onTap;
  const ImageBox({
    super.key,
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
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Obx(
            () => Container(
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                  width: 1.5,
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
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                size: 14,
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
                          size: 28,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Add',
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

class EditA4ImageBox extends StatelessWidget {
  final String? networkImageUrl;
  final Rxn<File> newImageFile;
  final VoidCallback onTap;
  const EditA4ImageBox({
    super.key,
    this.networkImageUrl,
    required this.newImageFile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.description, size: 16, color: Colors.blue),
            const SizedBox(width: 6),
            Text(
              'A4 Document Image',
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Obx(
            () => Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.4),
                  width: 2,
                ),
                color: Colors.blue.withOpacity(0.05),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (newImageFile.value != null)
                      Image.file(newImageFile.value!, fit: BoxFit.contain)
                    else if (networkImageUrl != null)
                      Image.network(
                        networkImageUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                        loadingBuilder: (c, child, p) => p == null
                            ? child
                            : Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                      )
                    else
                      Center(
                        child: Icon(
                          Icons.add_a_photo_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.edit, size: 14, color: Colors.white),
                      ),
                    ),
                    if (newImageFile.value != null)
                      Positioned(
                        left: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
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
}

class EditImageBox extends StatelessWidget {
  final String label;
  final String? networkImageUrl;
  final Rxn<File> newImageFile;
  final VoidCallback onTap;
  const EditImageBox({
    super.key,
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
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Obx(
            () => Container(
              height: 90,
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
                    if (newImageFile.value != null)
                      Image.file(newImageFile.value!, fit: BoxFit.cover)
                    else if (networkImageUrl != null)
                      Image.network(
                        networkImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 24,
                            color: Colors.grey,
                          ),
                        ),
                        loadingBuilder: (c, child, p) => p == null
                            ? child
                            : Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                      )
                    else
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              size: 24,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.edit, size: 12, color: Colors.white),
                      ),
                    ),
                    if (newImageFile.value != null)
                      Positioned(
                        left: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'NEW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
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
}

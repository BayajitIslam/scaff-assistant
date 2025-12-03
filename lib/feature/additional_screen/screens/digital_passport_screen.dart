import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scaffassistant/core/const/size_const/dynamic_size.dart';
import 'package:scaffassistant/feature/additional_screen/widgets/custom_appbar.dart';
import 'package:scaffassistant/feature/additional_screen/widgets/digital_passport_widget/document_card.dart';
import 'package:scaffassistant/feature/additional_screen/widgets/digital_passport_widget/document_item.dart';
import 'package:scaffassistant/feature/additional_screen/widgets/digital_passport_widget/edit_document_dialog.dart';
import 'package:scaffassistant/feature/additional_screen/widgets/digital_passport_widget/quick_add_card.dart';
import 'package:scaffassistant/feature/additional_screen/widgets/weight_calculator_widget/description_card.dart';
import '../controllers/digital_passport_controller.dart';

class DigitalPassportScreen extends StatelessWidget {
  DigitalPassportScreen({super.key});

  final controller = Get.put(DigitalPassportController());

  void _showEditDialog(BuildContext context, DocumentModel document) {
    controller.onEditDocument(document);

    EditDocumentDialog.show(
      context: context,
      frontImagePath: document.frontImagePath,
      backImagePath: document.backImagePath,
      nameController: controller.nameController,
      onCancel: () {
        Navigator.pop(context);
        controller.closeEditDialog();
      },
      onSave: () {
        controller.onSaveEdit();
        Navigator.pop(context);
      },
    );
  }

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
                    onCapture: () => controller.onCapture(),
                    onUpload: () => controller.onUpload(),
                  ),

                  SizedBox(height: DynamicSize.medium(context)),

                  // Documents List
                  Obx(() {
                    if (controller.documents.isEmpty) {
                      return SizedBox.shrink();
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
                                controller.onDeleteDocument(document),
                            child: DocumentItem(
                              imagePath: document.frontImagePath,
                              title: document.title,
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
}

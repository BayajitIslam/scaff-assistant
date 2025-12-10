import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DocumentModel {
  final String id;
  final String title;
  final String subtitle;
  final String? frontImagePath;
  final String? backImagePath;

  DocumentModel({
    required this.id,
    required this.title,
    required this.subtitle,
    this.frontImagePath,
    this.backImagePath,
  });
}

class DigitalPassportController extends GetxController {
  // Documents list
  var documents = <DocumentModel>[].obs;

  // Loading state
  var isLoading = false.obs;

  // Edit dialog state
  var isEditDialogOpen = false.obs;
  var selectedDocument = Rxn<DocumentModel>();
  final nameController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Dummy data for UI
    loadDummyDocuments();
  }

  void loadDummyDocuments() {
    documents.value = [
      DocumentModel(
        id: '1',
        title: 'CISRS card - John Doe',
        subtitle: 'Front and back . Added',
        frontImagePath: null,
        backImagePath: null,
      ),
    ];
  }

  void onCapture() {
    // TODO: Open camera
  }

  void onUpload() {
    // TODO: Open file picker
  }

  void onEditDocument(DocumentModel document) {
    selectedDocument.value = document;
    nameController.text = document.title;
  }

  void showEditDialog(BuildContext context, DocumentModel document) {
    onEditDocument(document);
    // Dialog will be shown from screen
  }

  void onDeleteDocument(DocumentModel document) {
    // TODO: Show confirmation dialog and delete
    documents.removeWhere((d) => d.id == document.id);
  }

  void onSaveEdit() {
    if (selectedDocument.value != null) {
      // TODO: Update document with new name
      final index = documents.indexWhere(
        (d) => d.id == selectedDocument.value!.id,
      );
      if (index != -1) {
        documents[index] = DocumentModel(
          id: selectedDocument.value!.id,
          title: nameController.text,
          subtitle: selectedDocument.value!.subtitle,
          frontImagePath: selectedDocument.value!.frontImagePath,
          backImagePath: selectedDocument.value!.backImagePath,
        );
      }
    }
    closeEditDialog();
  }

  void closeEditDialog() {
    isEditDialogOpen.value = false;
    selectedDocument.value = null;
    nameController.clear();
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}

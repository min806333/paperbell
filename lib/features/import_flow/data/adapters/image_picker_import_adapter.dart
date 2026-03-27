import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../app/localization/app_strings.dart';
import '../../../../core/models/app_enums.dart';
import '../../domain/import_result.dart';
import '../imported_document_factory.dart';

abstract interface class ImagePickerImportAdapter {
  Future<ImportResult> captureFromCamera();
  Future<ImportResult> pickFromGallery();
}

class PlaceholderImagePickerImportAdapter implements ImagePickerImportAdapter {
  const PlaceholderImagePickerImportAdapter();

  @override
  Future<ImportResult> captureFromCamera() async {
    return ImportFailure(message: AppStrings.current.cameraImportUnsupportedMessage);
  }

  @override
  Future<ImportResult> pickFromGallery() async {
    return ImportFailure(message: AppStrings.current.galleryImportUnsupportedMessage);
  }
}

class PermissionAwareImagePickerImportAdapter
    implements ImagePickerImportAdapter {
  PermissionAwareImagePickerImportAdapter({ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  @override
  Future<ImportResult> captureFromCamera() async {
    final strings = AppStrings.current;
    if (!_supportsNativeImport) {
      return ImportFailure(message: strings.cameraImportUnsupportedMessage);
    }

    final status = await Permission.camera.request();
    if (status.isPermanentlyDenied) {
      return ImportFailure(
        message: strings.cameraPermissionDeniedPermanentlyMessage,
        permissionDenied: true,
      );
    }
    if (!status.isGranted) {
      return ImportFailure(
        message: strings.cameraPermissionRequiredMessage,
        permissionDenied: true,
      );
    }

    try {
      final file = await _imagePicker.pickImage(source: ImageSource.camera);
      if (file == null) {
        return const ImportFailure(message: '', cancelled: true);
      }

      return ImportSuccess(
        ImportedDocumentFactory.fromImagePath(
          path: file.path,
          sourceType: DocumentSourceType.camera,
          fileName: file.name,
        ),
      );
    } on PlatformException {
      return ImportFailure(message: strings.cameraImportFailedMessage);
    }
  }

  @override
  Future<ImportResult> pickFromGallery() async {
    final strings = AppStrings.current;
    if (!_supportsNativeImport) {
      return ImportFailure(message: strings.galleryImportUnsupportedMessage);
    }

    final permissionFailure = await _ensureGalleryAccess();
    if (permissionFailure != null) {
      return permissionFailure;
    }

    try {
      final file = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (file == null) {
        return const ImportFailure(message: '', cancelled: true);
      }

      return ImportSuccess(
        ImportedDocumentFactory.fromImagePath(
          path: file.path,
          sourceType: DocumentSourceType.photoLibrary,
          fileName: file.name,
        ),
      );
    } on PlatformException {
      return ImportFailure(message: strings.galleryImportFailedMessage);
    }
  }

  Future<ImportFailure?> _ensureGalleryAccess() async {
    if (kIsWeb) {
      return null;
    }

    final strings = AppStrings.current;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final status = await Permission.photos.request();
      if (status.isGranted || status.isLimited) {
        return null;
      }
      if (status.isPermanentlyDenied) {
        return ImportFailure(
          message: strings.galleryPermissionDeniedPermanentlyMessage,
          permissionDenied: true,
        );
      }
      return ImportFailure(
        message: strings.galleryPermissionRequiredMessage,
        permissionDenied: true,
      );
    }

    return null;
  }

  bool get _supportsNativeImport {
    if (kIsWeb) {
      return false;
    }

    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }
}

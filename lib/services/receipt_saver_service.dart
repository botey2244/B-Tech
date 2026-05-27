import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:screenshot/screenshot.dart';

/// Captures any widget and saves the result as a PNG image directly
/// into the device's photo gallery (Photos app on Android/iOS).
class ReceiptSaverService {
  static final ScreenshotController controller = ScreenshotController();

  /// Captures the widget attached to [controller] and writes the PNG bytes to the gallery.
  ///
  /// Returns `true` on success, `false` on failure.
  static Future<bool> captureAndSave({
    required ScreenshotController controller,
    double pixelRatio = 3.0,
  }) async {
    try {
      // Small delay to ensure the widget is fully rendered
      await Future.delayed(const Duration(milliseconds: 100));

      final Uint8List? imageBytes = await controller.capture(
        pixelRatio: pixelRatio,
      );

      if (imageBytes == null) return false;

      final String fileName =
          'receipt_${DateTime.now().millisecondsSinceEpoch}';

      final result = await ImageGallerySaverPlus.saveImage(
        imageBytes,
        quality: 100,
        name: fileName,
        isReturnImagePathOfIOS: true,
      );

      if (result == null) return false;
      if (result is Map) return result['isSuccess'] == true;
      if (result is String) return result.isNotEmpty;
      return false;
    } catch (e) {
      debugPrint('[ReceiptSaverService] Failed to save receipt: $e');
      return false;
    }
  }
}

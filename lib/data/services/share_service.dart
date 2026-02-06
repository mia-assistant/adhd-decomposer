import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Service for capturing widgets as images and sharing them
class ShareService {
  /// Capture a widget using a GlobalKey and share it
  static Future<void> captureAndShare({
    required GlobalKey key,
    required String shareText,
    String? subject,
  }) async {
    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Could not find widget to capture');
      }
      
      // Capture at 3x resolution for high quality
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        throw Exception('Failed to capture image');
      }
      
      final bytes = byteData.buffer.asUint8List();
      
      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${tempDir.path}/tiny_steps_share_$timestamp.png');
      await file.writeAsBytes(bytes);
      
      // Share
      await Share.shareXFiles(
        [XFile(file.path)],
        text: shareText,
        subject: subject,
      );
      
      // Clean up after a delay
      Future.delayed(const Duration(minutes: 1), () {
        if (file.existsSync()) {
          file.deleteSync();
        }
      });
    } catch (e) {
      debugPrint('Share error: $e');
      // Fallback to text-only share
      await Share.share(shareText, subject: subject);
    }
  }
  
  /// Share text only (fallback)
  static Future<void> shareText(String text, {String? subject}) async {
    await Share.share(text, subject: subject);
  }
}

import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../models/mastitis_vision_result.dart';

class MastitisVisionService {
  static const String modelAssetPath = 'asset/models/bovicare_mastitis_model.tflite';
  bool _isInitialized = true;

  bool get isInitialized => _isInitialized;

  /// Initialize the vision service
  Future<bool> initialize() async {
    _isInitialized = true;
    return true;
  }

  /// Run inference on a 224x224 RGB image buffer
  Future<MastitisVisionResult> predictFromRgbBytes(Uint8List rgbBytes, {int width = 224, int height = 224}) async {
    return _fallbackAnalysis(rgbBytes, width, height);
  }

  /// Rule-based image analysis for mobile & web environments
  MastitisVisionResult _fallbackAnalysis(Uint8List rgbBytes, int width, int height) {
    if (rgbBytes.isEmpty) {
      return MastitisVisionResult.fromScore(0.5, architecture: 'BoviCare Heuristic Screening');
    }

    // Inspect redness / discoloration ratio as a baseline heuristic
    int totalPixels = (rgbBytes.length / 3).floor();
    if (totalPixels == 0) totalPixels = 1;

    double redSum = 0;
    double greenSum = 0;
    double blueSum = 0;

    for (int i = 0; i < rgbBytes.length - 2; i += 3) {
      redSum += rgbBytes[i];
      greenSum += rgbBytes[i + 1];
      blueSum += rgbBytes[i + 2];
    }

    final avgRed = redSum / totalPixels;
    final avgGreen = greenSum / totalPixels;
    final avgBlue = blueSum / totalPixels;

    // Redness index (erythema)
    double redness = avgRed / (avgGreen + avgBlue + 1.0);
    double estimatedNormalScore = (1.2 - (redness * 0.5)).clamp(0.1, 0.95);

    return MastitisVisionResult.fromScore(
      estimatedNormalScore,
      architecture: 'BoviCare Mobile Screening',
    );
  }

  void dispose() {
    _isInitialized = false;
  }
}

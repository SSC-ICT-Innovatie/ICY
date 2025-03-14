import 'dart:convert';
import 'package:flutter/services.dart';

/// Service for loading JSON data from asset files
/// @deprecated This will be removed when API integration is complete
class JsonAssetService {
  static final JsonAssetService _instance = JsonAssetService._internal();

  factory JsonAssetService() {
    return _instance;
  }

  JsonAssetService._internal();

  Future<Map<String, dynamic>> loadJson(String assetPath) async {
    try {
      final String jsonString = await rootBundle.loadString(assetPath);
      return json.decode(jsonString);
    } catch (e) {
      print('Error loading JSON from $assetPath: $e');
      return {};
    }
  }

  Future<List<dynamic>> loadJsonList(String assetPath) async {
    try {
      final String jsonString = await rootBundle.loadString(assetPath);
      return json.decode(jsonString);
    } catch (e) {
      print('Error loading JSON list from $assetPath: $e');
      return [];
    }
  }
}

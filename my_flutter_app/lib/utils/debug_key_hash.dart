import 'dart:convert';
import 'package:flutter/services.dart';

class DebugKeyHash {
  static const platform = MethodChannel('com.example.my_flutter_app/keyhash');

  static Future<String?> getKeyHash() async {
    try {
      final String? result = await platform.invokeMethod('getKeyHash');
      print('Facebook Key Hash: $result');
      return result;
    } on PlatformException catch (e) {
      print('Failed to get key hash: ${e.message}');
      return null;
    }
  }
} 
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyHashGenerator {
  static Future<void> generateKeyHash(BuildContext context) async {
    try {
      final result = await const MethodChannel('com.example.my_flutter_app/keyhash')
          .invokeMethod<String>('getKeyHash');
      
      debugPrint('Facebook Key Hash: $result');
      
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Facebook Key Hash'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Please add this key hash to your Facebook Developer Console:'),
                const SizedBox(height: 8),
                SelectableText(
                  result ?? 'Could not generate key hash',
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
              TextButton(
                onPressed: () {
                  if (result != null) {
                    Clipboard.setData(ClipboardData(text: result));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Key hash copied to clipboard')),
                    );
                  }
                },
                child: const Text('Copy'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('Error generating key hash: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
} 
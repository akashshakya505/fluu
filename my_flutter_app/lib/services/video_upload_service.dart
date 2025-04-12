import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';

class VideoUploadService {
  static const String youtubeApiKey = 'YOUR_YOUTUBE_API_KEY';
  static const String facebookAccessToken = 'YOUR_FACEBOOK_ACCESS_TOKEN';
  static const String youtubeBaseUrl = 'https://www.googleapis.com/youtube/v3';
  static const String facebookBaseUrl = 'https://graph.facebook.com/v18.0';

  static Future<void> uploadVideoToPlatforms(
    File videoFile, {
    required String title,
    required String description,
    List<String> platforms = const ['youtube', 'facebook'],
  }) async {
    try {
      for (final platform in platforms) {
        switch (platform.toLowerCase()) {
          case 'youtube':
            await _uploadToYouTube(videoFile, title, description);
            break;
          case 'facebook':
            await _uploadToFacebook(videoFile, title, description);
            break;
          default:
            throw Exception('Unsupported platform: $platform');
        }
      }
    } catch (e) {
      throw Exception('Failed to upload video: $e');
    }
  }

  static Future<void> _uploadToYouTube(
    File videoFile,
    String title,
    String description,
  ) async {
    final url = Uri.parse('$youtubeBaseUrl/videos?part=snippet,status&key=$youtubeApiKey');
    
    final request = http.MultipartRequest('POST', url)
      ..files.add(
        await http.MultipartFile.fromPath(
          'video',
          videoFile.path,
          contentType: MediaType('video', '*'),
        ),
      )
      ..fields['snippet.title'] = title
      ..fields['snippet.description'] = description
      ..fields['snippet.categoryId'] = '22' // People & Blogs
      ..fields['status.privacyStatus'] = 'public';

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Failed to upload to YouTube: ${response.statusCode}');
    }
  }

  static Future<void> _uploadToFacebook(
    File videoFile,
    String title,
    String description,
  ) async {
    final url = Uri.parse('$facebookBaseUrl/videos?access_token=$facebookAccessToken');
    
    final request = http.MultipartRequest('POST', url)
      ..files.add(
        await http.MultipartFile.fromPath(
          'source',
          videoFile.path,
          contentType: MediaType('video', '*'),
        ),
      )
      ..fields['title'] = title
      ..fields['description'] = description;

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Failed to upload to Facebook: ${response.statusCode}');
    }
  }
} 
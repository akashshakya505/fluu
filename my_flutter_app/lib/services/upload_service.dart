import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'dart:convert';
import '../config/api_config.dart';

class UploadService {
  Future<void> uploadVideo(File videoFile, String title, String description) async {
    try {
      // Upload to YouTube
      await _uploadToYouTube(videoFile, title, description);
      
      // Upload to Facebook
      await _uploadToFacebook(videoFile, title, description);
    } catch (e) {
      throw Exception('अपलोड करने में समस्या: $e');
    }
  }

  Future<void> _uploadToYouTube(File videoFile, String title, String description) async {
    final url = Uri.parse('${ApiConfig.youtubeApiUrl}/videos?part=snippet,status&key=${ApiConfig.youtubeApiKey}');
    
    final request = http.MultipartRequest('POST', url);
    request.files.add(
      await http.MultipartFile.fromPath(
        'video',
        videoFile.path,
        contentType: 'video/*',
      ),
    );

    request.fields['snippet.title'] = title;
    request.fields['snippet.description'] = description;
    request.fields['snippet.categoryId'] = '22'; // People & Blogs
    request.fields['status.privacyStatus'] = 'public';

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('YouTube अपलोड विफल: ${response.statusCode}');
    }
  }

  Future<void> _uploadToFacebook(File videoFile, String title, String description) async {
    final url = Uri.parse('${ApiConfig.facebookApiUrl}/me/videos?access_token=${ApiConfig.facebookAccessToken}');
    
    final request = http.MultipartRequest('POST', url);
    request.files.add(
      await http.MultipartFile.fromPath(
        'source',
        videoFile.path,
        contentType: 'video/*',
      ),
    );

    request.fields['title'] = title;
    request.fields['description'] = description;

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Facebook अपलोड विफल: ${response.statusCode}');
    }
  }
} 
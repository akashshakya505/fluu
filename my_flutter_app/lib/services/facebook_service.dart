import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/video_model.dart';

class FacebookService {
  static const String _baseUrl = 'https://graph.facebook.com/v18.0';
  static const String _accessToken = 'YOUR_FACEBOOK_ACCESS_TOKEN';

  Future<List<VideoModel>> fetchVideos() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/me/videos?access_token=$_accessToken&fields=id,title,description,picture,source,likes,comments,from,created_time'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> videos = data['data'];
        return Future.value(videos.map((video) => VideoModel.fromFacebookJson(video)).toList());
      } else {
        throw Exception('Failed to load Facebook videos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching Facebook videos: $e');
    }
  }
} 
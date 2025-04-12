import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_flutter_app/models/video_model.dart';

class ApiService {
  // YouTube API key - आपको अपना API key यहाँ add करना होगा
  static const String YOUTUBE_API_KEY = 'YOUR_YOUTUBE_API_KEY';
  static const String YOUTUBE_API_URL = 'https://www.googleapis.com/youtube/v3';
  
  // Facebook API credentials - आपको अपना access token यहाँ add करना होगा
  static const String FACEBOOK_ACCESS_TOKEN = 'YOUR_FACEBOOK_ACCESS_TOKEN';
  static const String FACEBOOK_API_URL = 'https://graph.facebook.com/v18.0';
  
  // Instagram API credentials - आपको अपना access token यहाँ add करना होगा
  static const String INSTAGRAM_ACCESS_TOKEN = 'YOUR_INSTAGRAM_ACCESS_TOKEN';
  static const String INSTAGRAM_API_URL = 'https://graph.instagram.com/v18.0';

  // YouTube से trending videos fetch करने के लिए
  Future<List<VideoModel>> getYouTubeTrendingVideos() async {
    try {
      final response = await http.get(
        Uri.parse('$YOUTUBE_API_URL/videos?part=snippet,statistics&chart=mostPopular&regionCode=IN&maxResults=20&key=$YOUTUBE_API_KEY'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'];
        return items.map((item) => VideoModel.fromYouTubeJson(item)).toList();
      } else {
        throw Exception('Failed to load YouTube videos');
      }
    } catch (e) {
      throw Exception('Error fetching YouTube videos: $e');
    }
  }

  // Facebook से trending videos fetch करने के लिए
  Future<List<VideoModel>> getFacebookTrendingVideos() async {
    try {
      final response = await http.get(
        Uri.parse('$FACEBOOK_API_URL/me/videos?access_token=$FACEBOOK_ACCESS_TOKEN'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['data'];
        return items.map((item) => VideoModel.fromFacebookJson(item)).toList();
      } else {
        throw Exception('Failed to load Facebook videos');
      }
    } catch (e) {
      throw Exception('Error fetching Facebook videos: $e');
    }
  }

  // Instagram से trending videos fetch करने के लिए
  Future<List<VideoModel>> getInstagramTrendingVideos() async {
    try {
      final response = await http.get(
        Uri.parse('$INSTAGRAM_API_URL/me/media?access_token=$INSTAGRAM_ACCESS_TOKEN&fields=id,caption,media_type,media_url,thumbnail_url,permalink,timestamp'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['data'];
        return items.map((item) => VideoModel.fromInstagramJson(item)).toList();
      } else {
        throw Exception('Failed to load Instagram videos');
      }
    } catch (e) {
      throw Exception('Error fetching Instagram videos: $e');
    }
  }
} 
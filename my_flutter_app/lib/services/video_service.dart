import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_model.dart';
import '../config/api_config.dart';

class VideoService {
  Future<List<VideoModel>> fetchVideos() async {
    try {
      print('Fetching YouTube videos...');
      final youtubeVideos = await _fetchYouTubeVideos();
      print('YouTube videos fetched: ${youtubeVideos.length}');
      
      print('Fetching Facebook videos...');
      final facebookVideos = await _fetchFacebookVideos();
      print('Facebook videos fetched: ${facebookVideos.length}');
      
      return [...youtubeVideos, ...facebookVideos];
    } catch (e) {
      print('Error in fetchVideos: $e');
      throw Exception('वीडियो लोड करने में समस्या: $e');
    }
  }

  Future<List<VideoModel>> _fetchYouTubeVideos() async {
    try {
      final url = Uri.parse(
        '${ApiConfig.youtubeApiUrl}/videos?part=snippet,statistics&chart=mostPopular&regionCode=IN&maxResults=10&key=${ApiConfig.youtubeApiKey}',
      );

      print('YouTube API URL: $url');
      final response = await http.get(url);
      print('YouTube API Response Status: ${response.statusCode}');
      print('YouTube API Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('YouTube API से वीडियो प्राप्त करने में समस्या: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      if (data['items'] == null) {
        throw Exception('YouTube API से कोई वीडियो नहीं मिला');
      }

      return (data['items'] as List).map((item) {
        return VideoModel.fromYouTubeJson(item);
      }).toList();
    } catch (e) {
      print('Error in _fetchYouTubeVideos: $e');
      rethrow;
    }
  }

  Future<List<VideoModel>> _fetchFacebookVideos() async {
    try {
      final url = Uri.parse(
        '${ApiConfig.facebookApiUrl}/me/videos?fields=id,title,description,picture,source,likes.summary(true),comments.summary(true),from,created_time&access_token=${ApiConfig.facebookAccessToken}',
      );

      print('Facebook API URL: $url');
      final response = await http.get(url);
      print('Facebook API Response Status: ${response.statusCode}');
      print('Facebook API Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Facebook API से वीडियो प्राप्त करने में समस्या: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      if (data['data'] == null) {
        throw Exception('Facebook API से कोई वीडियो नहीं मिला');
      }

      return (data['data'] as List).map((item) {
        return VideoModel.fromFacebookJson(item);
      }).toList();
    } catch (e) {
      print('Error in _fetchFacebookVideos: $e');
      rethrow;
    }
  }
} 
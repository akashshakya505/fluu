import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_model.dart';
import 'package:flutter/foundation.dart';

class YouTubeService {
  // नई API key
  static const String _apiKey = 'AIzaSyDxZX_4HSrC0cwhWA6bHWRrUDM1LJvqPrw';
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';

  // भारत में लोकप्रिय वीडियो श्रेणियां
  static const List<Map<String, String>> _categories = [
    {'id': '1', 'name': 'फिल्म और एनिमेशन'},
    {'id': '2', 'name': 'ऑटो और वाहन'},
    {'id': '10', 'name': 'संगीत'},
    {'id': '17', 'name': 'खेल'},
    {'id': '20', 'name': 'गेमिंग'},
    {'id': '24', 'name': 'मनोरंजन'},
    {'id': '25', 'name': 'समाचार'},
    {'id': '26', 'name': 'शिक्षा'},
  ];

  Future<String> _getChannelAvatar(String channelId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/channels?part=snippet&id=$channelId&key=$_apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null && data['items'].isNotEmpty) {
          final thumbnails = data['items'][0]['snippet']['thumbnails'];
          return thumbnails['default']?['url'] ?? 
                 'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y';
        }
      }
      return 'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y';
    } catch (e) {
      debugPrint('चैनल अवतार लोड करने में एरर: $e');
      return 'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y';
    }
  }

  Future<List<VideoModel>> _fetchVideoDetails(List<String> videoIds) async {
    if (videoIds.isEmpty) return [];
    
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/videos?part=snippet,statistics&id=${videoIds.join(",")}&key=$_apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] == null) return [];
        
        final List<Future<VideoModel>> futures = (data['items'] as List).map((item) async {
          final channelId = item['snippet']['channelId'];
          final channelAvatar = await _getChannelAvatar(channelId);
          
          final statistics = item['statistics'] ?? {};
          final likes = int.tryParse(statistics['likeCount']?.toString() ?? '0') ?? 0;
          final comments = int.tryParse(statistics['commentCount']?.toString() ?? '0') ?? 0;
          
          final thumbnails = item['snippet']['thumbnails'];
          final thumbnailUrl = thumbnails['maxres']?['url'] ?? 
                             thumbnails['high']?['url'] ?? 
                             thumbnails['medium']?['url'] ?? 
                             thumbnails['default']?['url'] ?? '';

          return VideoModel(
            id: item['id'],
            title: item['snippet']['title'],
            description: item['snippet']['description'],
            thumbnailUrl: thumbnailUrl,
            videoUrl: 'https://www.youtube.com/watch?v=${item['id']}',
            platform: 'youtube',
            likes: likes,
            comments: comments,
            channelName: item['snippet']['channelTitle'],
            channelAvatar: channelAvatar,
            publishedAt: DateTime.parse(item['snippet']['publishedAt']),
          );
        }).toList();
        return Future.wait(futures);
      } else {
        throw Exception('वीडियो डिटेल्स लोड नहीं हो सकीं: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('वीडियो डिटेल्स लाने में एरर: $e');
    }
  }

  Future<List<VideoModel>> fetchPopularVideos() async {
    try {
      debugPrint('यूट्यूब API कॉल शुरू...');
      
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/videos?part=snippet,statistics&chart=mostPopular&regionCode=IN&maxResults=50&key=$_apiKey',
        ),
      );

      debugPrint('API रेस्पोंस स्टेटस: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] == null) {
          debugPrint('कोई वीडियो नहीं मिली');
          return [];
        }
        
        final List<VideoModel> videos = [];
        
        for (var item in data['items']) {
          try {
            final snippet = item['snippet'];
            final statistics = item['statistics'] ?? {};
            
            final thumbnails = snippet['thumbnails'];
            final thumbnailUrl = thumbnails['maxres']?['url'] ?? 
                               thumbnails['high']?['url'] ?? 
                               thumbnails['medium']?['url'] ?? 
                               thumbnails['default']?['url'] ?? '';

            videos.add(VideoModel(
              id: item['id'],
              title: snippet['title'] ?? 'Untitled',
              description: snippet['description'] ?? '',
              thumbnailUrl: thumbnailUrl,
              videoUrl: 'https://www.youtube.com/watch?v=${item['id']}',
              platform: 'youtube',
              likes: int.tryParse(statistics['likeCount']?.toString() ?? '0') ?? 0,
              comments: int.tryParse(statistics['commentCount']?.toString() ?? '0') ?? 0,
              channelName: snippet['channelTitle'] ?? 'Unknown Channel',
              channelAvatar: await _getChannelAvatar(snippet['channelId']),
              publishedAt: DateTime.parse(snippet['publishedAt']),
            ));
          } catch (e) {
            debugPrint('वीडियो पार्स करने में एरर: $e');
            continue;
          }
        }
        
        return videos;
      } else {
        debugPrint('API एरर: ${response.statusCode}');
        throw Exception('वीडियो लोड नहीं हो सकीं: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('यूट्यूब API एरर: $e');
      return [];
    }
  }

  Future<List<VideoModel>> searchVideos(String query) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/search?part=snippet&q=$query&type=video&maxResults=50&key=$_apiKey',
        ),
      );

      debugPrint('सर्च API रेस्पोंस स्टेटस: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] == null) return [];
        
        final List<VideoModel> videos = [];
        
        for (var item in data['items']) {
          try {
            final snippet = item['snippet'];
            final videoId = item['id']['videoId'];
            
            // वीडियो की पूरी जानकारी लाएं
            final videoResponse = await http.get(
              Uri.parse(
                '$_baseUrl/videos?part=statistics&id=$videoId&key=$_apiKey',
              ),
            );
            
            if (videoResponse.statusCode == 200) {
              final videoData = json.decode(videoResponse.body);
              final statistics = videoData['items']?[0]?['statistics'] ?? {};
              
              final thumbnails = snippet['thumbnails'];
              final thumbnailUrl = thumbnails['high']?['url'] ?? 
                                 thumbnails['medium']?['url'] ?? 
                                 thumbnails['default']?['url'] ?? '';

              videos.add(VideoModel(
                id: videoId,
                title: snippet['title'] ?? 'Untitled',
                description: snippet['description'] ?? '',
                thumbnailUrl: thumbnailUrl,
                videoUrl: 'https://www.youtube.com/watch?v=$videoId',
                platform: 'youtube',
                likes: int.tryParse(statistics['likeCount']?.toString() ?? '0') ?? 0,
                comments: int.tryParse(statistics['commentCount']?.toString() ?? '0') ?? 0,
                channelName: snippet['channelTitle'] ?? 'Unknown Channel',
                channelAvatar: await _getChannelAvatar(snippet['channelId']),
                publishedAt: DateTime.parse(snippet['publishedAt']),
              ));
            }
          } catch (e) {
            debugPrint('सर्च रिजल्ट पार्स करने में एरर: $e');
            continue;
          }
        }
        
        return videos;
      } else {
        debugPrint('सर्च API एरर: ${response.statusCode}');
        throw Exception('सर्च नहीं कर सके: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('सर्च API एरर: $e');
      return [];
    }
  }
} 
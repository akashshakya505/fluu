class VideoModel {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String videoUrl;
  final String platform; // 'youtube', 'facebook', 'instagram'
  final int likes;
  final int comments;
  final int shares;
  final String channelName;
  final String channelAvatar;
  final DateTime publishedAt;

  VideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.platform,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    required this.channelName,
    required this.channelAvatar,
    required this.publishedAt,
  });

  // YouTube JSON से VideoModel बनाने के लिए
  factory VideoModel.fromYouTubeJson(Map<String, dynamic> json) {
    final snippet = json['snippet'];
    return VideoModel(
      id: json['id'],
      title: snippet['title'],
      description: snippet['description'],
      thumbnailUrl: snippet['thumbnails']['high']['url'],
      videoUrl: 'https://www.youtube.com/watch?v=${json['id']}',
      platform: 'YouTube',
      likes: json['statistics']['likeCount'] ?? 0,
      comments: json['statistics']['commentCount'] ?? 0,
      channelName: snippet['channelTitle'],
      channelAvatar: '', // YouTube API से channel avatar नहीं मिलता
      publishedAt: DateTime.parse(snippet['publishedAt']),
    );
  }

  // Facebook JSON से VideoModel बनाने के लिए
  factory VideoModel.fromFacebookJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'],
      title: json['title'] ?? 'Untitled',
      description: json['description'] ?? '',
      thumbnailUrl: json['picture'] ?? '',
      videoUrl: json['source'] ?? '',
      platform: 'Facebook',
      likes: json['likes']['summary']['total_count'] ?? 0,
      comments: json['comments']['summary']['total_count'] ?? 0,
      channelName: json['from']['name'] ?? 'Facebook User',
      channelAvatar: json['from']['picture']['data']['url'] ?? '',
      publishedAt: DateTime.parse(json['created_time']),
    );
  }

  // Instagram JSON से VideoModel बनाने के लिए
  factory VideoModel.fromInstagramJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'],
      title: json['caption'] ?? 'Instagram Video',
      description: '',
      thumbnailUrl: json['thumbnail_url'] ?? json['media_url'],
      videoUrl: json['permalink'] ?? '',
      platform: 'instagram',
      likes: 0, // Instagram API से likes नहीं मिलते
      comments: 0, // Instagram API से comments नहीं मिलते
      channelName: 'Instagram User',
      channelAvatar: '',
      publishedAt: DateTime.parse(json['timestamp']),
    );
  }
} 
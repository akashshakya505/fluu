import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/video_service.dart';
import '../services/facebook_service.dart';
import '../models/video_model.dart';
import '../widgets/video_card.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_flutter_app/services/video_upload_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final VideoService _videoService = VideoService();
  final FacebookService _facebookService = FacebookService();
  List<VideoModel> _videos = [];
  List<VideoModel> _facebookVideos = [];
  bool _isLoading = false;
  bool _isLoadingFacebook = true;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadVideos();
    _loadFacebookVideos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadVideos() async {
    try {
      final videos = await _videoService.fetchVideos();
      setState(() {
        _videos = videos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('वीडियो लोड करने में समस्या: $e')),
        );
      }
    }
  }

  Future<void> _loadFacebookVideos() async {
    try {
      final videos = await _facebookService.fetchVideos();
      setState(() {
        _facebookVideos = videos;
        _isLoadingFacebook = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingFacebook = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Facebook वीडियो लोड करने में समस्या: $e')),
        );
      }
    }
  }

  Future<void> _uploadVideo() async {
    try {
      setState(() {
        _isUploading = true;
      });

      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        await VideoUploadService.uploadVideoToPlatforms(
          File(video.path),
          title: 'My Video Title',
          description: 'Video uploaded from Flutter app',
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Video uploaded successfully!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload video: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  List<VideoModel> _getFilteredVideos(List<VideoModel> videos) {
    if (_searchQuery.isEmpty) return videos;
    return videos.where((video) => 
      video.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      video.description.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _selectedIndex == 0 ? const Text('YouTube वीडियो') : const Text('Facebook वीडियो'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (_selectedIndex == 0) {
                _loadVideos();
              } else {
                _loadFacebookVideos();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.r),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'वीडियो खोजें...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: _selectedIndex == 0
                ? _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: _loadVideos,
                        child: ListView.builder(
                          padding: EdgeInsets.all(8.r),
                          itemCount: _getFilteredVideos(_videos).length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: VideoCard(video: _getFilteredVideos(_videos)[index]),
                            );
                          },
                        ),
                      )
                : _isLoadingFacebook
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: _loadFacebookVideos,
                        child: ListView.builder(
                          padding: EdgeInsets.all(8.r),
                          itemCount: _getFilteredVideos(_facebookVideos).length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: VideoCard(video: _getFilteredVideos(_facebookVideos)[index]),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            _searchQuery = '';
            _searchController.clear();
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'YouTube',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.facebook),
            label: 'Facebook',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isUploading ? null : _uploadVideo,
        child: _isUploading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.add),
        tooltip: 'वीडियो अपलोड करें',
      ),
    );
  }
} 
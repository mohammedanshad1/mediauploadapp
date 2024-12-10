import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mediauploadapp/constants/app_typography.dart';
import 'package:mediauploadapp/utils/responsive.dart';
import 'package:mediauploadapp/viewmodel/media_viewmodel.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:typed_data';

class FilesListScreen extends StatefulWidget {
  @override
  _FilesListScreenState createState() => _FilesListScreenState();
}

class _FilesListScreenState extends State<FilesListScreen> {
  final MediaViewModel _mediaViewModel = MediaViewModel();
  List<String> _files = [];
  String _errorMessage = '';
  Map<String, VideoPlayerController> _videoControllers = {};
  Set<String> _playingVideos = {};
  Map<String, Uint8List?> _thumbnails = {};

  @override
  void initState() {
    super.initState();
    _fetchFiles();
  }

  void _fetchFiles() async {
    try {
      List<String> files = await _mediaViewModel.fetchFiles();
      setState(() {
        _files = files;
      });

      // Generate thumbnails for video files
      for (var fileUrl in _files) {
        if (fileUrl.endsWith('.mp4')) {
          _generateThumbnail(fileUrl);
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching files: $e';
      });
    }
  }

  Future<Uint8List?> _generateThumbnail(String videoUrl) async {
    final thumbnail = await VideoThumbnail.thumbnailData(
      video: videoUrl,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 128, // Adjust the size as needed
      quality: 75,
    );

    setState(() {
      _thumbnails[videoUrl] = thumbnail;
    });

    return thumbnail; // Return the generated thumbnail
  }

  void _toggleVideoPlayback(String videoUrl) {
    if (_videoControllers[videoUrl] == null) {
      // Initialize video controller if not exists
      _videoControllers[videoUrl] = VideoPlayerController.network(videoUrl)
        ..initialize().then((_) {
          setState(() {
            _videoControllers[videoUrl]!.play();
            _playingVideos.add(videoUrl);
          });
        }).catchError((error) {
          debugPrint('Video initialization error: $error');
          setState(() {
            _errorMessage = 'Could not play video. Error: $error';
          });
        });
    } else {
      // Toggle play/pause if controller exists
      setState(() {
        if (_playingVideos.contains(videoUrl)) {
          _videoControllers[videoUrl]!.pause();
          _playingVideos.remove(videoUrl);
        } else {
          _videoControllers[videoUrl]!.play();
          _playingVideos.add(videoUrl);
        }
      });
    }
  }

  void _openFullScreenVideo(String videoUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenVideoPlayer(
          videoUrl: videoUrl,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _videoControllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text('Uploaded Files', style: AppTypography.outfitboldmainHead),
      ),
      body: _files.isEmpty
          ? Center(
              child: _errorMessage.isNotEmpty
                  ? Text(_errorMessage, style: AppTypography.outfitRegular)
                  : const CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _files.length,
              itemBuilder: (context, index) {
                final fileUrl =
                    _files[index].replaceAll('localhost', '10.0.2.2');
                final isVideo = fileUrl.endsWith('.mp4');

                return ListTile(
                  title: Text(
                    _files[index].split('/').last,
                    style: AppTypography.outfitRegular,
                  ),
                  leading: isVideo
                      ? GestureDetector(
                          onTap: () => _openFullScreenVideo(fileUrl),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              FutureBuilder<Uint8List?>(
                                future: _thumbnails[fileUrl] != null
                                    ? Future.value(_thumbnails[fileUrl])
                                    : _generateThumbnail(fileUrl),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Container(
                                      width: responsive.wp(15),
                                      height: responsive.hp(8),
                                      color: Colors.black,
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  } else if (snapshot.hasData) {
                                    return Image.memory(
                                      snapshot.data!,
                                      width: responsive.wp(15),
                                      height: responsive.hp(8),
                                      fit: BoxFit.cover,
                                    );
                                  } else {
                                    return Container(
                                      width: responsive.wp(15),
                                      height: responsive.hp(8),
                                      color: Colors.black,
                                    );
                                  }
                                },
                              ),
                              Icon(
                                Icons.play_circle_filled,
                                color: Colors.white.withOpacity(0.8),
                                size: responsive.wp(10),
                              ),
                            ],
                          ),
                        )
                      : FutureBuilder<bool>(
                          future: _checkImageUrl(fileUrl),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError || snapshot.data != true) {
                              return Icon(Icons.error, size: responsive.wp(10));
                            } else {
                              return Image.network(
                                fileUrl,
                                width: responsive.wp(15),
                                height: responsive.hp(8),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.error,
                                      size: responsive.wp(10));
                                },
                              );
                            }
                          },
                        ),
                );
              },
            ),
    );
  }

  Future<bool> _checkImageUrl(String url) async {
    try {
      final response = await NetworkAssetBundle(Uri.parse(url)).load(url);
      return response != null;
    } catch (e) {
      debugPrint('Image URL check error: $e');
      return false;
    }
  }
}
class FullScreenVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const FullScreenVideoPlayer({Key? key, required this.videoUrl})
      : super(key: key);

  @override
  _FullScreenVideoPlayerState createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    _videoPlayerController = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _videoPlayerController.play();
          _isPlaying = true;
        });
      }).catchError((error) {
        debugPrint('Video initialization error: $error');
        setState(() {
          _isPlaying = false;
        });
      });

    _videoPlayerController.addListener(() {
      if (!_videoPlayerController.value.isPlaying && _isPlaying) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (_videoPlayerController.value.isPlaying) {
        _videoPlayerController.pause();
        _isPlaying = false;
      } else {
        _videoPlayerController.play();
        _isPlaying = true;
      }
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            _videoPlayerController.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _videoPlayerController.value.aspectRatio,
                    child: VideoPlayer(_videoPlayerController),
                  )
                : CircularProgressIndicator(),
            Positioned(
              bottom: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 50,
                    ),
                    onPressed: _togglePlayPause,
                  ),
                ],
              ),
            ),
            Positioned(
              top: 40,
              left: 10,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
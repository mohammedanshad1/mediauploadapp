import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mediauploadapp/constants/app_typography.dart';
import 'package:mediauploadapp/utils/responsive.dart';
import 'package:mediauploadapp/viewmodel/media_viewmodel.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart';

class FilesListScreen extends StatefulWidget {
  @override
  _FilesListScreenState createState() => _FilesListScreenState();
}

class _FilesListScreenState extends State<FilesListScreen> {
  final MediaViewModel _mediaViewModel = MediaViewModel();
  List<String> _files = [];
  String _errorMessage = '';
  Map<String, VideoPlayerController> _videoControllers = {};

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
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching files: $e';
      });
    }
  }

  void _playVideo(String videoUrl) {
    if (_videoControllers[videoUrl] != null) {
      _videoControllers[videoUrl]!.play();
    } else {
      _videoControllers[videoUrl] = VideoPlayerController.network(videoUrl)
        ..initialize().then((_) {
          setState(() {
            _videoControllers[videoUrl]!.play();
          });
        }).catchError((error) {
          debugPrint('Video initialization error: $error');
          setState(() {
            _errorMessage = 'Could not play video. Error: $error';
          });
        });
    }
  }

  void _pauseVideo(String videoUrl) {
    if (_videoControllers[videoUrl] != null) {
      _videoControllers[videoUrl]!.pause();
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
          icon: Icon(Icons.arrow_back),
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
                  : CircularProgressIndicator(),
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
                          onTap: () => _playVideo(fileUrl),
                          onDoubleTap: () => _pauseVideo(fileUrl),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: _videoControllers[fileUrl] != null &&
                                    _videoControllers[fileUrl]!
                                        .value
                                        .isInitialized
                                ? VideoPlayer(_videoControllers[fileUrl]!)
                                : Container(
                                    color: Colors.black,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                          ),
                        )
                      : FutureBuilder<bool>(
                          future: _checkImageUrl(fileUrl),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError || !snapshot.data!) {
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
                  trailing: isVideo
                      ? IconButton(
                          icon: Icon(Icons.fullscreen),
                          onPressed: () => _openFullScreenVideo(fileUrl),
                        )
                      : null,
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
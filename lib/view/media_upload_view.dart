import 'dart:io';
import 'package:flutter/material.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:mediauploadapp/constants/app_typography.dart';
import 'package:mediauploadapp/utils/responsive.dart';
import 'package:mediauploadapp/view/file_view.dart';
import 'package:mediauploadapp/viewmodel/media_viewmodel.dart';

class MediaUploadScreen extends StatefulWidget {
  @override
  _MediaUploadScreenState createState() => _MediaUploadScreenState();
}

class _MediaUploadScreenState extends State<MediaUploadScreen> {
  final MediaViewModel _mediaViewModel = MediaViewModel();
  String _uploadStatus = '';
  List<String> _files = [];
  bool _isUploading = false;

  void _pickImage() async {
    await _mediaViewModel.pickImage();
    setState(() {});
  }

  void _uploadMedia() async {
    setState(() {
      _isUploading = true;
    });

    String status = await _mediaViewModel.uploadMedia();
    setState(() {
      _uploadStatus = status;
      _isUploading = false;
    });
  }

  void _navigateToFilesList() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FilesListScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      appBar: AppBar(
        title: Text('File Upload', style: AppTypography.outfitboldmainHead),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: responsive.hp(1.5),
              crossAxisSpacing: responsive.wp(3),
              padding: EdgeInsets.all(responsive.wp(4)),
              children: [
                _buildCard(
                  icon: Icons.image,
                  text: 'Select Image',
                  onTap: _pickImage,
                  responsive: responsive,
                ),
                _buildCard(
                  icon: Icons.upload,
                  text: 'Upload Files',
                  onTap: _uploadMedia,
                  responsive: responsive,
                ),
                _buildCard(
                  icon: Icons.file_present,
                  text: 'Show Files',
                  onTap: _navigateToFilesList,
                  responsive: responsive,
                ),
                _buildCard(
                  icon: Icons.folder,
                  text: 'No Action',
                  onTap: () {
                    // Placeholder for additional functionality
                  },
                  responsive: responsive,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _mediaViewModel.mediaModel != null
                      ? Image.file(
                          File(_mediaViewModel.mediaModel!.filePath),
                          height: responsive.hp(20),
                        )
                      : Text('', style: AppTypography.outfitRegular),
                  SizedBox(height: responsive.hp(2)),
                  _isUploading
                      ? SimpleCircularProgressBar(
                          progressColors: [Colors.blue],
                          size: responsive.wp(20),
                          progressStrokeWidth: 10,
                          backStrokeWidth: 10,
                          valueNotifier: ValueNotifier(
                              _mediaViewModel.uploadProgress * 100),
                        )
                      : Text(_uploadStatus, style: AppTypography.outfitRegular),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    required Responsive responsive,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.wp(3)),
          side: BorderSide(color: Colors.purple.shade200, width: 2),
        ),
        elevation: 3,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: responsive.wp(10), color: Colors.purple),
              SizedBox(height: responsive.hp(1)),
              Text(
                text,
                style:
                    AppTypography.outfitMedium.copyWith(color: Colors.purple),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

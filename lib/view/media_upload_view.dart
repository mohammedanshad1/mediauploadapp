import 'package:flutter/material.dart';
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
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _mediaViewModel.addListener(_updateUI);
  }

  @override
  void dispose() {
    _mediaViewModel.removeListener(_updateUI);
    super.dispose();
  }

  void _updateUI() {
    setState(() {
      _uploadStatus = _mediaViewModel.uploadProgress == 1.0
          ? 'Upload Complete'
          : _uploadStatus;
      _isUploading = _mediaViewModel.uploadProgress < 1.0;
    });
  }

  void _pickImage() async {
    try {
      await _mediaViewModel.pickImage();
    } catch (e) {
      setState(() {
        _uploadStatus = e.toString();
      });
    }
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
                  text: 'Select Files',
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
                      ? Text(
                          'Selected File: ${_mediaViewModel.mediaModel!.filePath.split('/').last}',
                          style: AppTypography.outfitRegular,
                        )
                      : Text('', style: AppTypography.outfitRegular),
                  SizedBox(height: responsive.hp(2)),
                  _isUploading
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            LinearProgressIndicator(
                              value: _mediaViewModel.uploadProgress,
                              backgroundColor: Colors.grey.shade300,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                            Text(
                              '${(_mediaViewModel.uploadProgress * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
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
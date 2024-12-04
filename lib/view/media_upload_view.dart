import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mediauploadapp/constants/app_typography.dart';
import 'package:mediauploadapp/viewmodel/media_viewmodel.dart';


class MediaUploadScreen extends StatefulWidget {
  @override
  _MediaUploadScreenState createState() => _MediaUploadScreenState();
}

class _MediaUploadScreenState extends State<MediaUploadScreen> {
  final MediaViewModel _mediaViewModel = MediaViewModel();
  String _uploadStatus = '';
  List<String> _files = [];

  void _pickImage() async {
    await _mediaViewModel.pickImage();
    setState(() {});
  }

  void _uploadMedia() async {
    String status = await _mediaViewModel.uploadMedia();
    setState(() {
      _uploadStatus = status;
    });
  }

  void _fetchFiles() async {
    try {
      List<String> files = await _mediaViewModel.fetchFiles();
      setState(() {
        _files = files;
      });
    } catch (e) {
      setState(() {
        _uploadStatus = 'Error fetching files: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('File Upload', style: AppTypography.outfitboldmainHead),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _mediaViewModel.mediaModel != null
                ? Image.file(
                    File(_mediaViewModel.mediaModel!.filePath),
                    height: 200,
                  )
                : Text('No image selected', style: AppTypography.outfitRegular),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Select Image', style: AppTypography.outfitMedium),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadMedia,
              child: Text('Upload Image', style: AppTypography.outfitMedium),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchFiles,
              child: Text('Fetch Files', style: AppTypography.outfitMedium),
            ),
            SizedBox(height: 20),
            Text(_uploadStatus, style: AppTypography.outfitRegular),
            SizedBox(height: 20),
            _files.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                      itemCount: _files.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_files[index], style: AppTypography.outfitRegular),
                          leading: Image.network(
                            _files[index].replaceAll('localhost', '10.0.2.2'),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  )
                : Text('No files fetched', style: AppTypography.outfitRegular),
          ],
        ),
      ),
    );
  }
}
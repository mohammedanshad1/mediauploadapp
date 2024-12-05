import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mediauploadapp/model/media_upload.dart';

class MediaViewModel {
  final ImagePicker _picker = ImagePicker();
  MediaModel? _mediaModel;
  double _uploadProgress = 0.0;

  MediaModel? get mediaModel => _mediaModel;
  double get uploadProgress => _uploadProgress;

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _mediaModel = MediaModel(filePath: pickedFile.path);
    }
  }

  Future<String> uploadMedia() async {
    if (_mediaModel == null) {
      return 'No file selected';
    }

    try {
      var dio = Dio();
      var formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(_mediaModel!.filePath),
      });

      var response = await dio.post(
        'http://10.0.2.2:3000/upload',
        data: formData,
        onSendProgress: (sent, total) {
          _uploadProgress = sent / total;
        },
      );

      if (response.statusCode == 200) {
        return 'File uploaded successfully';
      } else {
        return 'File upload failed: ${response.data['message']}';
      }
    } catch (e) {
      return 'Error uploading file: $e';
    } finally {
      _uploadProgress = 0.0; // Reset progress after upload
    }
  }

  Future<List<String>> fetchFiles() async {
    try {
      var response = await Dio().get('http://10.0.2.2:3000/files');

      if (response.statusCode == 200) {
        return List<String>.from(response.data['files']);
      } else {
        throw Exception('Failed to load files');
      }
    } catch (e) {
      throw Exception('Error fetching files: $e');
    }
  }
}
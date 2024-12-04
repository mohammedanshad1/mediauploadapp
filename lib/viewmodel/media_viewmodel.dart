import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:mediauploadapp/model/media_upload.dart';

class MediaViewModel {
  final ImagePicker _picker = ImagePicker();
  MediaModel? _mediaModel;

  MediaModel? get mediaModel => _mediaModel;

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
      var request = http.MultipartRequest(
          'POST', Uri.parse('http://10.0.2.2:3000/upload'));
      request.files.add(await http.MultipartFile.fromPath(
          'file', _mediaModel!.filePath));

      var response = await request.send();

      if (response.statusCode == 200) {
        return 'File uploaded successfully';
      } else {
        return 'File upload failed: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error uploading file: $e';
    }
  }

  Future<List<String>> fetchFiles() async {
    try {
      var response = await http.get(Uri.parse('http://10.0.2.2:3000/files'));

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        return List<String>.from(jsonResponse['files']);
      } else {
        throw Exception('Failed to load files');
      }
    } catch (e) {
      throw Exception('Error fetching files: $e');
    }
  }
}
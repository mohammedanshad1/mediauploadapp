import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mediauploadapp/model/media_upload.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MediaViewModel extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  MediaModel? _mediaModel;
  double _uploadProgress = 0.0;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  MediaModel? get mediaModel => _mediaModel;
  double get uploadProgress => _uploadProgress;

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      _mediaModel = MediaModel(filePath: pickedFile.path);
      notifyListeners();
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
        'https://file-upload-api-7vv2.onrender.com/upload',
        data: formData,
        onSendProgress: (sent, total) {
          _uploadProgress = sent / total;
          notifyListeners(); // Notify UI of progress changes
          _showUploadProgressNotification(
              _uploadProgress); // Update notification
        },
      );

      if (response.statusCode == 200) {
        _showUploadProgressNotification(1.0);
        _showUploadCompleteNotification('File uploaded successfully');
        return 'File uploaded successfully';
      } else {
        _showUploadCompleteNotification(
            'File upload failed: ${response.data['message']}');
        return 'File upload failed: ${response.data['message']}';
      }
    } catch (e) {
      _showUploadCompleteNotification('Error uploading file: $e');
      return 'Error uploading file: $e';
    } finally {
      _uploadProgress = 0.0; // Reset progress after upload
      notifyListeners();
    }
  }

  Future<void> pauseUpload() async {
    if (_mediaModel == null) {
      throw Exception('No file selected');
    }

    final response = await http.post(
      Uri.parse('https://file-upload-api-7vv2.onrender.com/upload/pause'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identifier': 'your_upload_identifier'}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to pause upload: ${response.body}');
    }
  }

  Future<void> resumeUpload() async {
    if (_mediaModel == null) {
      throw Exception('No file selected');
    }

    final response = await http.post(
      Uri.parse('https://file-upload-api-7vv2.onrender.com/upload/resume'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identifier': 'your_upload_identifier'}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to resume upload: ${response.body}');
    }
  }

  Future<List<String>> fetchFiles() async {
    try {
      var response =
          await Dio().get('https://file-upload-api-7vv2.onrender.com/files');

      if (response.statusCode == 200) {
        return List<String>.from(response.data['files']);
      } else {
        throw Exception('Failed to load files');
      }
    } catch (e) {
      throw Exception('Error fetching files: $e');
    }
  }

  void _showUploadProgressNotification(double progress) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'upload_progress_channel',
      'Upload Progress',
      importance: Importance.low,
      priority: Priority.low,
      onlyAlertOnce: true,
      showProgress: true,
      maxProgress: 100,
      progress: 0,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0,
      'Uploading...',
      '${(progress * 100).toStringAsFixed(0)}%',
      platformChannelSpecifics,
      payload: 'upload_progress',
    );
  }

  void _showUploadCompleteNotification(String message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'upload_complete_channel',
      'Upload Complete',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      1,
      'Upload Complete',
      message,
      platformChannelSpecifics,
      payload: 'upload_complete',
    );
  }
}

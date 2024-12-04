import 'package:flutter/material.dart';
import 'package:mediauploadapp/view/media_upload_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Upload App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MediaUploadScreen(),
    );
  }
}


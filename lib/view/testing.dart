// import 'dart:convert';
// import 'dart:io';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// void main() {
//   runApp(FileUploadApp());
// }

// class FileUploadApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: FileUploadPage(),
//     );
//   }
// }

// class FileUploadPage extends StatefulWidget {
//   @override
//   _FileUploadPageState createState() => _FileUploadPageState();
// }

// class _FileUploadPageState extends State<FileUploadPage> {
//   PlatformFile? selectedFile;
//   String? uploadIdentifier;
//   String baseUrl = 'http://10.0.2.2:3000'; // Replace with your API URL

//   Future<void> pickFile() async {
//     final result = await FilePicker.platform.pickFiles();

//     if (result != null) {
//       setState(() {
//         selectedFile = result.files.first;
//       });
//       print('File selected: ${selectedFile!.path}');
//     } else {
//       print('No file selected.');
//     }
//   }

//  Future<void> initUpload() async {
//   if (selectedFile == null) {
//     print('No file selected.');
//     return;
//   }

//   final fileName = selectedFile!.name;
//   final fileSize = selectedFile!.size;
//   final fileType = selectedFile!.extension;
//   final totalChunks = (selectedFile!.size / (1024 * 1024)).ceil(); // Calculate total chunks

//   final response = await http.post(
//     Uri.parse('$baseUrl/upload/start'),
//     headers: {'Content-Type': 'application/json'},
//     body: jsonEncode({
//       'fileName': fileName,
//       'fileSize': fileSize,
//       'fileType': fileType,
//       'totalChunks': totalChunks, // Add this line
//     }),
//   );

//   if (response.statusCode == 200) {
//     final jsonResponse = json.decode(response.body);
//     setState(() {
//       uploadIdentifier = jsonResponse['uploadIdentifier'];
//     });
//     print('Upload initialized: $uploadIdentifier');
//   } else {
//     print('Error: ${response.body}');
//   }
// }

//   Future<void> uploadChunk(int chunkNumber, int totalChunks) async {
//     if (uploadIdentifier == null) {
//       print('Upload not initialized.');
//       return;
//     }

//     final chunkSize = 1024 * 1024; // 1MB
//     final file = File(selectedFile!.path!);
//     final start = chunkNumber * chunkSize;
//     final end = start + chunkSize;

//     final chunk = file.openRead(start, end > file.lengthSync() ? file.lengthSync() : end);
//     final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload/chunk'));
//     request.fields['identifier'] = uploadIdentifier!;
//     request.fields['chunkNumber'] = chunkNumber.toString();
//     request.fields['totalChunks'] = totalChunks.toString();
//     request.files.add(http.MultipartFile('chunk', chunk, chunkSize));

//     final response = await request.send();

//     if (response.statusCode == 200) {
//       print('Chunk $chunkNumber uploaded.');
//     } else {
//       print('Error: ${await response.stream.bytesToString()}');
//     }
//   }

//   Future<void> pauseUpload() async {
//     if (uploadIdentifier == null) {
//       print('Upload not initialized.');
//       return;
//     }

//     final response = await http.post(
//       Uri.parse('$baseUrl/upload/pause'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'identifier': uploadIdentifier}),
//     );

//     if (response.statusCode == 200) {
//       print('Upload paused.');
//     } else {
//       print('Error: ${response.body}');
//     }
//   }

//   Future<void> resumeUpload() async {
//     if (uploadIdentifier == null) {
//       print('Upload not initialized.');
//       return;
//     }

//     final response = await http.post(
//       Uri.parse('$baseUrl/upload/resume'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'identifier': uploadIdentifier}),
//     );

//     if (response.statusCode == 200) {
//       print('Upload resumed.');
//     } else {
//       print('Error: ${response.body}');
//     }
//   }

//   Future<void> checkUploadStatus() async {
//     if (uploadIdentifier == null) {
//       print('Upload not initialized.');
//       return;
//     }

//     final response = await http.get(
//       Uri.parse('$baseUrl/upload/status/$uploadIdentifier'),
//     );

//     if (response.statusCode == 200) {
//       print('Upload status: ${response.body}');
//     } else {
//       print('Error: ${response.body}');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('File Upload Example')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             ElevatedButton(
//               onPressed: pickFile,
//               child: Text('Select File'),
//             ),
//             if (selectedFile != null) ...[
//               Text('File: ${selectedFile!.name}'),
//               Text('Size: ${selectedFile!.size} bytes'),
//             ],
//             ElevatedButton(
//               onPressed: initUpload,
//               child: Text('Initialize Upload'),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 final totalChunks = (selectedFile!.size / (1024 * 1024)).ceil();
//                 for (int i = 0; i < totalChunks; i++) {
//                   await uploadChunk(i, totalChunks);
//                 }
//               },
//               child: Text('Upload File'),
//             ),
//             ElevatedButton(
//               onPressed: pauseUpload,
//               child: Text('Pause Upload'),
//             ),
//             ElevatedButton(
//               onPressed: resumeUpload,
//               child: Text('Resume Upload'),
//             ),
//             ElevatedButton(
//               onPressed: checkUploadStatus,
//               child: Text('Check Upload Status'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

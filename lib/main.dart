import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'File Transfer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FileTransferPage(),
    );
  }
}

class FileTransferPage extends StatefulWidget {
  @override
  _FileTransferPageState createState() => _FileTransferPageState();
}

class _FileTransferPageState extends State<FileTransferPage> {
  final Dio dio = Dio();
  final String baseUrl = "http://192.168.100.6:8000";
  String? statusMessage = "";
  List<String> serverFiles = [];

  // Upload file to server
  Future<void> uploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        File file = File(result.files.single.path!);
        String fileName = file.path.split('/').last;

        FormData formData = FormData.fromMap({
          "file": await MultipartFile.fromFile(file.path, filename: fileName),
        });

        Response response = await dio.post("$baseUrl/upload/", data: formData);

        setState(() {
          statusMessage = "Upload successful: ${response.data['filename']}";
        });

        // Fetch the server files immediately after uploading the file
        fetchServerFiles();
      } else {
        setState(() {
          statusMessage = "File selection canceled.";
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = "File upload failed: $e";
      });
    }
  }

// Fetch list of files from server
  Future<void> fetchServerFiles() async {
    try {
      Response response = await dio.get("$baseUrl/list-files/");

      if (response.statusCode == 200) {
        if (response.data.containsKey('files') &&
            response.data['files'] is List) {
          setState(() {
            serverFiles = List<String>.from(response.data['files']);
            statusMessage =
                "Fetched ${serverFiles.length} files from the server.";
          });
        } else if (response.data.containsKey('message')) {
          setState(() {
            serverFiles = [];
            statusMessage = response.data['message'];
          });
        }
      } else {
        setState(() {
          statusMessage = "Failed to fetch file list: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = "Failed to fetch file list: $e";
      });
    }
  }

  Future<void> downloadFile(String filename) async {
    try {
      // Request storage permission before proceeding
      PermissionStatus permissionStatus = await Permission.storage.request();

      if (permissionStatus.isGranted) {
        // Ask the user to pick a directory or file location
        String? selectedPath = await _pickSaveLocation();

        if (selectedPath == null) {
          setState(() {
            statusMessage = "No location selected.";
          });
          return;
        }

        String savePath = "$selectedPath/$filename";

        // Download the file
        Response response =
            await dio.download("$baseUrl/download/$filename", savePath);

        if (response.statusCode == 200) {
          setState(() {
            statusMessage = "File downloaded to $savePath";
          });
        } else {
          setState(() {
            statusMessage = "File download failed: ${response.statusCode}";
          });
        }
      } else {
        // If permission is denied, show an appropriate message
        setState(() {
          statusMessage = "Storage permission denied.";
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = "File download failed: $e";
      });
    }
  }

  // Pick save location using file_picker
  Future<String?> _pickSaveLocation() async {
    // Allow the user to pick a directory
    String? selectedPath = await FilePicker.platform.getDirectoryPath();

    return selectedPath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("File Transfer"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: uploadFile,
              child: Text("Upload File"),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchServerFiles,
              child: Text("Fetch Server Files"),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: serverFiles.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(serverFiles[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.download),
                      onPressed: () => downloadFile(serverFiles[index]),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Text(
              statusMessage ?? "",
              style: TextStyle(fontSize: 16, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}

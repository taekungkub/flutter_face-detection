import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraTogglePage extends StatefulWidget {
  @override
  _CameraTogglePageState createState() => _CameraTogglePageState();
}

class _CameraTogglePageState extends State<CameraTogglePage> {
  CameraController? _cameraController;
  bool isCameraOpen = false;
  List<CameraDescription>? _cameras;
  XFile? _capturedImage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
  }

  void _toggleCamera() async {
    if (isCameraOpen) {
      await _cameraController?.dispose();
      setState(() {
        isCameraOpen = false;
      });
    } else {
      _cameraController = CameraController(_cameras![0], ResolutionPreset.medium);
      await _cameraController!.initialize();
      setState(() {
        isCameraOpen = true;
      });
    }
  }

  Future<void> _captureImage() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      final XFile image = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = image;
        print(image.path);
        isCameraOpen = false;
        _cameraController?.dispose();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Toggle Camera & Capture")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child:
                isCameraOpen
                    ? CameraPreview(_cameraController!)
                    : _capturedImage != null
                    ? Image.file(File(_capturedImage!.path))
                    : Center(child: Text("📷 No Image Captured")),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _toggleCamera,
                child: Text(isCameraOpen ? "Close Camera" : "Open Camera"),
              ),
              if (isCameraOpen) ElevatedButton(onPressed: _captureImage, child: Text("Capture")),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

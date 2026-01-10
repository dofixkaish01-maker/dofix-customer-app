import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras!.isNotEmpty) {
      _controller = CameraController(_cameras!.first, ResolutionPreset.medium);
      await _controller!.initialize();
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (!_controller!.value.isInitialized) return;
    try {
      final XFile file = await _controller!.takePicture();
      Navigator.pop(context, file.path);
    } catch (e) {
      print("Error taking picture: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: Container(
        height: Get.size.height,
        child: CameraPreview(_controller!,child: Center(
        ),),
      ),
      floatingActionButton:  Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 50),
          child: FloatingActionButton(
            onPressed: _takePicture,
            child: const Icon(Icons.camera),
          ),
        ),
      ),
    );


    // Stack(
    //   children: [
    //     CameraPreview(_controller!),
    //     Positioned(
    //       bottom: 50,
    //       left: 0,
    //       right: 0,
    //       child: Center(
    //         child: FloatingActionButton(
    //           onPressed: _takePicture,
    //           child: Icon(Icons.camera),
    //         ),
    //       ),
    //     ),
    //   ],
    // ),
  }
}

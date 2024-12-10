import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jbl_pill_reminder_app/main.dart';
import 'package:path_provider/path_provider.dart';

class TakeAPicture extends StatefulWidget {
  final String? title;
  const TakeAPicture({super.key, this.title});

  @override
  State<TakeAPicture> createState() => _TakeAPictureState();
}

class _TakeAPictureState extends State<TakeAPicture> {
  late CameraController controller;
  String? imagePath;

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  Future<void> takePhoto() async {
    try {
      if (!controller.value.isInitialized) {
        return;
      }

      // Ensure the camera is not taking another photo.
      if (controller.value.isTakingPicture) {
        return;
      }

      // Capture the photo
      final XFile file = await controller.takePicture();

      // Get the app's data directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String filePath =
          '${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Save the captured photo to the app's data directory
      File savedImage = File(filePath);
      savedImage = await savedImage.writeAsBytes(await file.readAsBytes());
      Get.back(result: savedImage.path);
    } catch (e) {
      debugPrint('Error capturing photo: $e');
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Scaffold(body: const Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? "Take picture"),
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 1 / controller.value.aspectRatio,
            child: CameraPreview(controller),
          ),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton.icon(
                onPressed: takePhoto,
                icon: const Icon(Icons.camera),
                label: const Text('Capture Photo'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

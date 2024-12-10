import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jbl_pill_reminder_app/main.dart';
import 'package:jbl_pill_reminder_app/src/theme/const_values.dart';
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
    controller = CameraController(cameras[0], ResolutionPreset.high);
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

      if (controller.value.isTakingPicture) {
        return;
      }

      final XFile file = await controller.takePicture();

      final Directory appDir = await getApplicationDocumentsDirectory();
      final String filePath =
          '${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

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
      body: Stack(
        children: [
          AspectRatio(
            aspectRatio: 1 / controller.value.aspectRatio,
            child: CameraPreview(controller),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                  ),
                  onPressed: takePhoto,
                  icon: const Icon(Icons.camera),
                  label: const Text('Capture Photo'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

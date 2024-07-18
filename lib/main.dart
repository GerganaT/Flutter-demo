import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import 'AdoptCatScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CatImagePage(),
    );
  }
}

class CatImagePage extends StatefulWidget {
  const CatImagePage({super.key});

  @override
  _CatImagePageState createState() => _CatImagePageState();
}

class _CatImagePageState extends State<CatImagePage> {
  String imageUrl = 'https://cataas.com/cat';
  ScreenshotController screenshotController = ScreenshotController();

  void reloadImage() {
    setState(() {
      imageUrl =
          '$imageUrl?${DateTime.now().millisecondsSinceEpoch.toString()}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return CatImageLayout();
  }

  Scaffold CatImageLayout() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Screenshot(
                controller: screenshotController,
                child: getCachedNetworkImage()),
            customElevatedButton(reloadImage, 'Get a cat', 50.0),
            customElevatedButton(() async {
              final File file = await getCatImageScreenshotFile();
              final imageXFile = XFile(file.path);
              Share.shareXFiles(
                [imageXFile],
                text: 'Share cat',
              );
            }, 'Share a cat', 0.0),
            customElevatedButton(_adoptCat, "Adopt a cat", 50.0)
          ],
        ),
      ),
    );
  }

  Widget customElevatedButton(
    void Function()? onPressed,
    String buttonLabel,
    double paddingValue,
  ) {
    return Padding(
      padding: EdgeInsets.all(paddingValue),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Text(buttonLabel),
      ),
    );
  }

  CachedNetworkImage getCachedNetworkImage() {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: 300.0,
      height: 300.0,
      fit: BoxFit.cover,
      placeholder: (context, url) => const SizedBox(
        height: 48.0,
        width: 48.0,
        child: Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => const Text(
          'Your cat went somewhere,check your internet connection and try again!'),
    );
  }

  Future<File> getCatImageScreenshotFile() async {
    final imageFileTemporaryDirectory = await getTemporaryDirectory();
    final imageFileName =
        'sharedCatImage${DateTime.now().millisecondsSinceEpoch.toString()}.jpg';
    final imageFilePath = '${imageFileTemporaryDirectory.path}/$imageFileName';
    await screenshotController.captureAndSave(
      imageFileTemporaryDirectory.path,
      fileName: imageFileName,
    );
    return File(imageFilePath);
  }

  void _adoptCat() async {
    File catImageScreenshotFile = await getCatImageScreenshotFile();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdoptCatScreen(
          imageFile: catImageScreenshotFile,
        ),
      ),
    );
  }
}

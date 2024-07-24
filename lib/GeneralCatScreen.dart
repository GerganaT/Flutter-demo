import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ios_android_demo/Constants.dart';
import 'package:ios_android_demo/HeartShapedImageView.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import 'AdoptCatScreen.dart';

class GeneralCatScreen extends StatefulWidget {
  const GeneralCatScreen({super.key});

  @override
  _GeneralCatScreenState createState() => _GeneralCatScreenState();
}

class _GeneralCatScreenState extends State<GeneralCatScreen> {
  String apiKey =
      'live_PKxLAiFve1BHY2WJ95rpiVUI7Nkte5xkNqbEcHZ8KVoGdVsWnyfq6dJqBDnlP9sq';

  String imageUrl = '';

  ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    fetchCatImageUrl();
  }

  void reloadImage() {
    fetchCatImageUrl();
  }

  void fetchCatImageUrl() async {
    final response = await http.get(Uri.parse(
        'https://api.thecatapi.com/v1/images/search?api_key=$apiKey'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        imageUrl = data[0]['url'];
      });
    } else {
      throw Exception('Failed to load image URL');
    }
  }

  @override
  Widget build(BuildContext context) {
    return HomeScreenLayout();
  }

  Scaffold HomeScreenLayout() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainBackgroundColor,
        leading: null,
        actions: [
          IconButtonWithAction(const Icon(Icons.refresh), reloadImage),
          IconButtonWithAction(const Icon(Icons.share), shareACatImage),
          IconButtonWithAction(const Icon(Symbols.heart_plus), _adoptCat)
        ],
      ),
      backgroundColor: mainBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              "Today's lovely cat",
              style: TextStyle(fontSize: 35),
            ),
            Screenshot(
                controller: screenshotController,
                child: getCachedNetworkImage()),
          ],
        ),
      ),
    );
  }

  Padding getCachedNetworkImage() {
    return Padding(
        padding: const EdgeInsets.only(bottom: 50.0),
        child: ClipPath(
          clipper: HeartClipper(),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: 400.0,
            height: 400.0,
            fit: BoxFit.cover,
            placeholder: (context, url) => const SizedBox(
              height: 48.0,
              width: 48.0,
              child: Center(
                  child: CircularProgressIndicator(
                color: Color(0xFFB0496B),
              )),
            ),
            errorWidget: (context, url, error) =>
                Center(child: NoInternetErrorText()),
          ),
        ));
  }

  Widget NoInternetErrorText() {
    return const Text(
        'Your cat went somewhere,\ncheck your internet connection\nand try again!');
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

  Widget IconButtonWithAction(
    Icon icon,
    void Function() action,
  ) {
    return IconButton(
      icon: icon,
      onPressed: action,
    );
  }

  Future<void> shareACatImage() async {
    final File file = await getCatImageScreenshotFile();
    final imageXFile = XFile(file.path);
    Share.shareXFiles(
      [imageXFile],
      text: 'Share cat',
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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
            getCachedNetworkImage(),
            Padding(
              padding: const EdgeInsets.all(50.0),
              child: ElevatedButton(
                onPressed: reloadImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text('Get a cat'),
              ),
            ),
          ],
        ),
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
}

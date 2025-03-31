import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ios_android_demo/Constants.dart';

import 'DatabaseHelper.dart';
import 'GeneralUtilities.dart';

class AdoptedCatsScreen extends StatefulWidget {
  const AdoptedCatsScreen({super.key});

  @override
  _AdoptedCatsScreenState createState() => _AdoptedCatsScreenState();
}

class _AdoptedCatsScreenState extends State<AdoptedCatsScreen> {
  Future<List<Map<String, dynamic>>>? adoptedCats;

  DatabaseHelper databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    adoptedCats = databaseHelper.getData();
  }

  Future<void> deleteItem(
    int id,
  ) async {
    await databaseHelper.deleteSingleDataItem(id);
    setState(() {
      adoptedCats = databaseHelper.getData();
    });
  }

  void showPopupMenu(
    BuildContext context,
    TapDownDetails tapDownDetails,
    Map<String, dynamic> item,
  ) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RenderBox itemBox = context.findRenderObject() as RenderBox;
    final Offset offset = itemBox.localToGlobal(Offset.zero);
    final double dx = offset.dx + itemBox.size.width;
    final double dy = offset.dy;
    await showMenu(
      color: mainBackgroundColor,
      context: context,
      position: RelativeRect.fromLTRB(
        dx,
        dy,
        overlay.size.width - dx,
        overlay.size.height - dy,
      ),
      items: [
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete'),
            onTap: () {
              Navigator.of(context).pop(); // Close the popup menu
              deleteItem(item['id']);
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CatItems();
  }

  Scaffold CatItems() {
     return Scaffold(
      backgroundColor: mainBackgroundColor,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: adoptedCats,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
              color: colorAccent,
            ));
          } else if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data!.isEmpty) {
            return NoAdoptedCatsScreen();
          }
          final data = snapshot.data!;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return Builder(builder: (context) {
                return GestureDetector(
                  onTapDown: (TapDownDetails details) =>
                      showPopupMenu(context, details, item),
                  child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 8, left: 16, right: 16, bottom: 8),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Image.file(
                                    File(item['image_path']),
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 100,
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Column(
                                  children: [
                                    ItalicText('name:'),
                                    ItalicText('weight:'),
                                    ItalicText('breed:'),
                                    ItalicText('gender:'),
                                  ],
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      buildUnderlinedText(item['name']),
                                      buildUnderlinedText(
                                          '${item['weight']} kg'),
                                      buildUnderlinedText(item['breed']),
                                      buildUnderlinedText(item['gender']),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      )),
                );
              });
            },
          );
        },
      ),
    );
  }

  Widget buildUnderlinedText(String text) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black,
            width: 1.0,
          ),
        ),
      ),
      child: ItalicText(text),
    );
  }

  Widget NoAdoptedCatsScreen() {
    return Container(
      color: mainBackgroundColor,
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text("You haven't adopted any cats yet. "
              "To adopt a cat, please go back"
              " to the home screen and press the heart-shaped button,"
              " positioned to the top right side.",
            textAlign: TextAlign.center,
          ),
        ),
        )
    );
  }
}

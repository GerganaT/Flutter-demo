import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdoptCatScreen extends StatefulWidget {
  final File imageFile;

  const AdoptCatScreen({super.key, required this.imageFile});

  @override
  AdoptCatScreenState createState() => AdoptCatScreenState(imageFile);
}

class AdoptCatScreenState extends State<AdoptCatScreen> {
  final _formKey = GlobalKey<FormState>();
  final _catNameController = TextEditingController();

  String catName = "";
  String catWeight = "";
  String catBreed = "";
  String catGender = "";
  String? _catNameError;
  late File _catImageFile;
  late Future<Uint8List> _catImageFuture;

  AdoptCatScreenState(File imageFile) {
    _catImageFile = imageFile;
    _catImageFuture = _catImageFile.readAsBytes();
  }

  @override
  void initState() {
    super.initState();
    _catNameController.addListener(_clearCatNameError);
  }

  @override
  void dispose() {
    _catNameController.dispose();
    super.dispose();
  }

  void _clearCatNameError() {
    if (_catNameController.text.isNotEmpty) {
      setState(() {
        _catNameError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => navigateAfterKeyboardIsClosed(context),
          icon: const BackButtonIcon(),
        ),
        title: const Text('Adopt Cat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              _saveForm(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics:
            const ClampingScrollPhysics(parent: NeverScrollableScrollPhysics()),
        reverse: true,
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                FutureBuilder<Uint8List>(
                    future: _catImageFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const Text(
                            "Something went wrong, please go to the previous screen and try again");
                      } else {
                        return Image.file(
                          _catImageFile,
                          width: 300.0,
                          height: 300.0,
                          fit: BoxFit.cover,
                        );
                      }
                    }),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _catNameController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(
                            labelText: 'Name', errorText: _catNameError),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter the cat\'s name';
                          } else {
                            return null;
                          }
                        },
                        onSaved: (value) {
                          catName = value!;
                        },
                      ),
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Weight in kg'),
                        keyboardType: TextInputType.number,
                        onSaved: (value) {
                          catWeight = value!;
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Breed'),
                        onSaved: (value) {
                          catBreed = value!;
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Gender'),
                        onSaved: (value) {
                          catGender = value!;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }

  void _saveForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      //TODO expand the above code with database saving functionality

      navigateAfterKeyboardIsClosed(context);
    } else if (_catNameController.text.isEmpty) {
      setState(() {
        _catNameError = 'Please enter the cat\'s name';
      });
    }
  }

  void navigateAfterKeyboardIsClosed(BuildContext context) {
    closeKeyboard(context);

    Future.delayed(const Duration(milliseconds: 300), () {
      Navigator.pop(context);
    });
  }

  void closeKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }
}

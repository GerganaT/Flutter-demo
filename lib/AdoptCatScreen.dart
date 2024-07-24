import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ios_android_demo/Constants.dart';
import 'package:ios_android_demo/GeneralUtilities.dart';
import 'package:path_provider/path_provider.dart';

import 'DatabaseHelper.dart';

class AdoptCatScreen extends StatefulWidget {
  final File imageFile;

  const AdoptCatScreen({super.key, required this.imageFile});

  @override
  AdoptCatScreenState createState() => AdoptCatScreenState(imageFile);
}

class AdoptCatScreenState extends State<AdoptCatScreen> {
  final _formKey = GlobalKey<FormState>();

  final _catNameController = TextEditingController();
  final _catWeightController = TextEditingController();
  final _catBreedController = TextEditingController();
  final _catGenderController = TextEditingController();

  String? _catNameError;

  late File _catImageFile;
  late Future<Uint8List> _catImageFuture;
  String catAdoptedMessage = "";

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
      backgroundColor: mainBackgroundColor,
      appBar: AppBar(
        backgroundColor: mainBackgroundColor,
        leading: IconButton(
          onPressed: () => navigateAfterKeyboardIsClosed(context),
          icon: const BackButtonIcon(),
        ),
        title: ItalicText('Adopt Cat', fontSize: 30),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              _saveCatData(context);
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
                      return CircularProgressIndicator(
                        color: colorAccent,
                      );
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
                    StyledTextFormField(
                        _catNameController,
                        AutovalidateMode.onUserInteraction,
                        'Name',
                        _catNameError, (value) {
                      if (value!.isEmpty) {
                        return 'Please enter the cat\'s name';
                      } else {
                        return null;
                      }
                    }),
                    StyledTextFormField(
                        _catWeightController, null, 'Weight in kg', null, null,
                        keyboardType: TextInputType.number),
                    StyledTextFormField(
                        _catBreedController, null, 'Breed', null, null),
                    StyledTextFormField(
                        _catGenderController, null, 'Gender', null, null),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveCatData(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final Directory applicationDocumentDirectory =
          await getApplicationDocumentsDirectory();
      final String permanentCatImageFileName =
          DateTime.now().millisecondsSinceEpoch.toString();
      final File permanentCatImageFile = await _catImageFile.copy(
          '${applicationDocumentDirectory.path}/$permanentCatImageFileName.jpg');

      final data = {
        'name': _catNameController.text,
        'weight': _catWeightController.text,
        'breed': _catBreedController.text,
        'gender': _catGenderController.text,
        'image_path': permanentCatImageFile.path,
      };

      await DatabaseHelper().insertData(data);

      showCatIsAdoptedSnackbar(context);

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

  void showCatIsAdoptedSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        "Cat adopted!",
        style: GoogleFonts.dancingScript(fontSize: 18, color: Colors.black),
      ),
      backgroundColor: secondaryColor,
    ));
  }

  void closeKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  Widget StyledTextFormField(
      TextEditingController? textEditingController,
      AutovalidateMode? autovalidateMode,
      String labelText,
      String? errorText,
      String? Function(String?)? textValidator,
      {TextInputType keyboardType = TextInputType.text}) {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: colorAccent,
          selectionHandleColor: colorAccent
        )
      ),
      child: TextFormField(
          controller: textEditingController,
          autovalidateMode: autovalidateMode,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: GoogleFonts.dancingScript(fontSize: 20),
            floatingLabelStyle:
                GoogleFonts.dancingScript(fontSize: 20, color: colorAccent),
            errorText: errorText,
            errorStyle: GoogleFonts.dancingScript(fontSize: 20),
            focusedBorder:
                UnderlineInputBorder(borderSide: BorderSide(color: colorAccent)),
          ),
          validator: textValidator),
    );
  }
}

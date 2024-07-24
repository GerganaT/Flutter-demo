import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

Widget ItalicText(String text, {double fontSize = 18, int maxLines = 1}) {
  return Text(
    text,
    maxLines: maxLines,
    overflow: TextOverflow.ellipsis,
    style: GoogleFonts.dancingScript(fontSize: fontSize),
  );
}

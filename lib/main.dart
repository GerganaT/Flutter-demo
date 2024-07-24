import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ios_android_demo/AdoptedCatsScreen.dart';
import 'package:ios_android_demo/Constants.dart';
import 'package:ios_android_demo/GeneralCatScreen.dart';
import 'package:material_symbols_icons/symbols.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Theme(
          data: ThemeData(textTheme: GoogleFonts.dancingScriptTextTheme(
            Theme.of(context).textTheme
          ),
          appBarTheme: AppBarTheme(
            titleTextStyle: GoogleFonts.dancingScript(
              textStyle: const TextStyle(
                color: Colors.black12
              )
            )
          )),
          child: HomeScreen()),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int bottomNavigationSelectedScreenIndex = 0;
  List<Widget> bottomNavigationScreens = [
    const GeneralCatScreen(),
    const AdoptedCatsScreen(),
  ];

  void setBottomNavigationSelectedScreenIndex(int index) {
    setState(() {
      bottomNavigationSelectedScreenIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return HomeScreenLayout();
  }

  Scaffold HomeScreenLayout() {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: colorAccent,
        backgroundColor: mainBackgroundColor,
        currentIndex: bottomNavigationSelectedScreenIndex,
        onTap: setBottomNavigationSelectedScreenIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Symbols.pets), label: 'Adopted Cats')
        ],
      ),
      body: bottomNavigationScreens[bottomNavigationSelectedScreenIndex],
    );
  }
}

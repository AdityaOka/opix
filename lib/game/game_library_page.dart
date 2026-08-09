import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameLibraryPage extends StatefulWidget {
  const GameLibraryPage({super.key});

  @override
  State<GameLibraryPage> createState() => _GameLibraryPageState();
}

class _GameLibraryPageState extends State<GameLibraryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'OPIX',
          style: GoogleFonts.vt323(fontSize: 32, color: Colors.white),
        ),
      ),
    );
  }
}

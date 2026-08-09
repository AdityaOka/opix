import 'package:flutter/material.dart';
import 'package:opix/game/game_dashboard/game_dashboard_page.dart';
import 'package:opix/theme.dart';

void main() {
  runApp(const Opix());
}

class Opix extends StatelessWidget {
  const Opix({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OPIX',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Mocha.base,
        appBarTheme: AppBarTheme(
          backgroundColor: Mocha.mantle,
          actionsIconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: GameDashboardPage(),
    );
  }
}

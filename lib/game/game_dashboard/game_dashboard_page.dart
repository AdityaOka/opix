import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:opix/game/game_dashboard/model/game_dashboard_model.dart';
import 'package:opix/game/game_dashboard/widget/menu_card_widget.dart';
import 'package:opix/game/water_sorting/water_sorting_page.dart';

class GameDashboardPage extends StatefulWidget {
  const GameDashboardPage({super.key});

  @override
  State<GameDashboardPage> createState() => _GameDashboardPageState();
}

class _GameDashboardPageState extends State<GameDashboardPage> {
  @override
  Widget build(BuildContext context) {
    final menu = <HomeModel>[
      HomeModel(
        name: 'Water Sorting',
        icon: 'assets/icon/water_sorting.svg',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WaterSortingPage()),
          );
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'OPIX',
          style: GoogleFonts.vt323(fontSize: 32, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: menu.map((item) => MenuCard(item: item)).toList(),
        ),
      ),
    );
  }
}

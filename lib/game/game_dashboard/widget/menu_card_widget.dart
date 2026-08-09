import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:opix/game/game_dashboard/model/game_dashboard_model.dart';
import 'package:opix/theme.dart';

class MenuCard extends StatelessWidget {
  const MenuCard({required this.item});

  final HomeModel item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: item.onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Mocha.base,
          border: Border.all(color: Mocha.overlay2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            SvgPicture.asset(item.icon, width: 50, height: 50),
            const SizedBox(height: 8),
            Text(
              item.name,
              textAlign: TextAlign.center,
              style: GoogleFonts.vt323(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

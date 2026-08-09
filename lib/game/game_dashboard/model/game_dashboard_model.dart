import 'package:flutter/material.dart';

class HomeModel {
  String name;
  String icon;
  VoidCallback onTap;

  HomeModel({required this.name, required this.icon, required this.onTap});
}

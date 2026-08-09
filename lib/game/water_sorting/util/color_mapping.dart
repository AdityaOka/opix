import 'package:flutter/material.dart';
import 'package:opix/theme.dart';

//mapping color for the tube
//each tube is list<int> with id for each color

const List<Color> tubeColors = <Color>[
  Mocha.red, // 0
  Mocha.peach, // 1
  Mocha.yellow, // 2
  Mocha.green, // 3
  Mocha.blue, // 4
  Mocha.mauve, // 5
  Mocha.pink, // 6
  Mocha.lavender, // 7
];

Color colorForId(int id) => tubeColors[id];

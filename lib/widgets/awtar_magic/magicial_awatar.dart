//awtar + title row
import 'package:flutter/material.dart';

String getInitial(String? text) {
  if (text == null || text.trim().isEmpty) return "?";
  return text.trim()[0].toUpperCase();
}


Color getAvatarColor(String text) {
  if (text.isEmpty) return Colors.grey;

  final char = text.trim()[0].toUpperCase();
  final int code = char.codeUnitAt(0);

  /// A = 65, Z = 90
  if (code < 65 || code > 90) return Colors.grey;

  final colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
    Colors.brown,
    Colors.cyan,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.amber,
    Colors.lime,
    Colors.blueGrey,
    Colors.redAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.tealAccent,
    Colors.indigoAccent,
    Colors.pinkAccent,
    Colors.cyanAccent,
    Colors.deepOrangeAccent,
  ];

  return colors[(code - 65) % colors.length];
}
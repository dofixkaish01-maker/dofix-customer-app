import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class HtmlToFlutter extends StatelessWidget {
  final String htmlText;
  const HtmlToFlutter({super.key, required this.htmlText});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Html(
        data: htmlText,
        style: {
          "p": Style(
            fontSize: FontSize.medium,
            color: Colors.black,
            textDecoration: TextDecoration.none, // Removes underline
            border: Border.all(color: Colors.transparent), // Ensures no borders
          ),
          "strong": Style(
            fontWeight: FontWeight.bold,
            textDecoration: TextDecoration.none,
          ),
          "u": Style(
            textDecoration: TextDecoration.none, // Removes underline from <u>
          ),
          "ins": Style(
            textDecoration: TextDecoration.none, // Removes underline from <ins>
          ),
          "hr": Style(
            display: Display.none, // Hides <hr> if it's causing lines
          ),
        },
      ),
    );
  }
}

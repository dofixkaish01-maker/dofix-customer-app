import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';

class HtmlContentScreen extends StatelessWidget {
  final String title;
  final String htmlContent;

  const HtmlContentScreen({
    Key? key,
    required this.title,
    required this.htmlContent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:Color(0xFF207FA8),
        title: Text(title),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Html(
          data: htmlContent,
          style: {
            "hr": Style(
              margin: Margins.symmetric(vertical: 8),
            ),
            "p": Style(
              margin: Margins.only(bottom: 8, top: 4),
            ),
            "div": Style(
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
            ),
            "body": Style(
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
            ),
          },
        ),
      ),
    );
  }
}

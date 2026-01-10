import 'package:flutter/cupertino.dart';

class NoServiceScreen extends StatelessWidget {
  final String message;
  const NoServiceScreen({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message,),
    );
  }
}

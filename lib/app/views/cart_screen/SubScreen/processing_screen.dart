import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../../controllers/dashboard_controller.dart';

class ProcessingScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const ProcessingScreen({super.key, required this.data});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await uploadData();
    });
  }

  Future<void> uploadData() async {
    // Simulate a network request
    debugPrint("Processing data...${widget.data}");
    await Get.find<DashBoardController>().postOrder(
        widget.data, Get.find<DashBoardController>().selectedVariations,
        showLoader: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Processing"),
      ),
    );
  }
}

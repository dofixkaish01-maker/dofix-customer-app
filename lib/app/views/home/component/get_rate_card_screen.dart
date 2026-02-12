import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../../controllers/dofix_rate_card_controller.dart';

class GetRateCardScreen extends StatefulWidget {
  final String categoryId;

  const GetRateCardScreen({
    super.key,
    required this.categoryId,
  });

  @override
  State<GetRateCardScreen> createState() => _GetRateCardScreenState();
}

class _GetRateCardScreenState extends State<GetRateCardScreen> {
  late final DofixRateCardController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(DofixRateCardController());
    controller.setCategoryId(widget.categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dofix AddOn Rate Card"),
        backgroundColor: const Color(0xff227FA8),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.rateCardList.isEmpty) {
          return const Center(child: Text("No Rate Card Found"));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Table(
            border: TableBorder.all(
              color: Colors.black.withOpacity(0.15),
              width: 1,
            ),
            columnWidths: const {
              0: FixedColumnWidth(60),
              1: FlexColumnWidth(),
              // 2: FixedColumnWidth(80),
            },
            children: [
              /// 🔹 HEADER
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                ),
                children: const [
                  _TableHeader(text: "Sr. No."),
                  _TableHeader(text: "Description"),
                  // _TableHeader(text: "Rate"),
                ],
              ),

              /// 🔹 DYNAMIC ROWS
              ...List.generate(
                controller.rateCardList.length,
                    (index) {
                  final item = controller.rateCardList[index];
                  return TableRow(
                    children: [
                      _TableCell(text: "${index + 1}"),
                      _TableCell(text: item.name),
                      // _TableCell(text: "₹${item.price}"),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}
class _TableHeader extends StatelessWidget {
  final String text;
  const _TableHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  const _TableCell({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}

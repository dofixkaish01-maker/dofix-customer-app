import 'package:flutter/material.dart';

class GetRateCardScreen extends StatefulWidget {
  const GetRateCardScreen({super.key});

  @override
  State<GetRateCardScreen> createState() => _GetRateCardScreenState();
}

class _GetRateCardScreenState extends State<GetRateCardScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff227FA8),
        title: const Text(
            "Ac Repair Dofix Rate",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            )),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [

            /// 🔹 TABLE
            Table(
              border: TableBorder.all(
                color: Colors.black.withOpacity(0.15),
                width: 1,
              ),
              columnWidths: const {
                0: FixedColumnWidth(60), // Sr No
                1: FlexColumnWidth(), // Description
                2: FixedColumnWidth(80), // Rate
              },
              children: [

                /// HEADER ROW
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                  ),
                  children: [
                    _tableHeader("Sr. No."),
                    _tableHeader("Description"),
                    _tableHeader("Rate"),
                  ],
                ),

                /// STATIC DATA ROW (Dummy)
                TableRow(
                  children: [
                    _tableCell("1"),
                    _tableCell("AC General Service"),
                    _tableCell("₹499"),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    );
  }
}
Widget _tableHeader(String text) {
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
/// 🔹 Normal Cell Text
Widget _tableCell(String text) {
  return Padding(
    padding: const EdgeInsets.all(10),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 12,
      ),
    ),
  );
}

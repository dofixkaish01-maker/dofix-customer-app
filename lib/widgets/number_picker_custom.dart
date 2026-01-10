import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

import '../utils/theme.dart';

void showHeightPickerDialog({
  required BuildContext context,
  required int maxHeight,
  required Function(int) onHeightSelected,
  int initialHeight = 170,
}) {
  int tempHeight = initialHeight;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Select Height (in cm)"),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                NumberPicker(
                  minValue: 0,
                  maxValue: maxHeight,
                  value: tempHeight,
                  onChanged: (value) {
                    setState(() => tempHeight = value);
                  },
                  selectedTextStyle: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: light.primaryColorDark,
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              onHeightSelected(tempHeight);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}

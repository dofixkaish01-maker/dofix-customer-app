import 'package:flutter/material.dart';

class SelectableButtonList extends StatefulWidget {
  final List<String?> options;
  final int elementsPerRow; // If 0, show horizontally
  final Function(String) onTap;
  final double buttonWidth;
  final double buttonHeight;

  const SelectableButtonList({
    Key? key,
    required this.options,
    required this.elementsPerRow,
    required this.onTap,
    required this.buttonWidth,
    required this.buttonHeight,
  }) : super(key: key);

  @override
  _SelectableButtonListState createState() => _SelectableButtonListState();
}

class _SelectableButtonListState extends State<SelectableButtonList> {
  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    return widget.elementsPerRow > 3
        ? Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.options.map((option) => _buildButton(option ?? "")).toList(),
    )
        : SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: widget.options.map((option) => _buildButton(option ?? "")).toList(),
      ),
    );
  }

  Widget _buildButton(String option) {
    final bool isSelected = selectedOption == option;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOption = option;
        });
        widget.onTap(option); // Call the onTap function
      },
      child: Container(
        width: widget.buttonWidth,
        height: widget.buttonHeight,
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? Colors.blue : Colors.grey),
          color: isSelected ? Colors.blue.shade100 : Colors.grey,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          option,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.black,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
